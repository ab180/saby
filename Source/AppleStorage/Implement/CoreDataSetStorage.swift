//
//  CoreDataSetStorage.swift
//  SabyAppleStorage
//

import CoreData

import SabyConcurrency
import SabyJSON
import SabySize

private let STORAGE_VERSION = "Version1"

public final class CoreDataSetStorage<Value: Codable & Hashable>: SetStorage {
    typealias Context = NSManagedObjectContext

    let entity: NSEntityDescription

    let contextLoad: () -> Promise<Context, Error>
    let contextPromise: Atomic<Promise<Context, Error>>

    let encoder = JSONEncoder.acceptingNonConfirmingFloat()
    let decoder = JSONDecoder.acceptingNonConfirmingFloat()

    public init(
        directoryURL: URL,
        storageName: String,
        migration: @escaping () -> Promise<Void, Error>
    ) {
        let schema = SabyCoreDataSetStorageSchema()

        self.entity = schema.entity
        self.contextLoad = {
            Context.loadSetStorage(
                directoryURL: directoryURL,
                storageName: storageName,
                migration: migration,
                model: schema.model
            )
        }
        self.contextPromise = Atomic(contextLoad())
    }
}

extension CoreDataSetStorage {
    public func set(_ values: Set<Value>) -> Promise<Void, Error> {
        execute { context in
            let encodedValues = try values.map { value -> Data in
                try self.encoder.encode(value)
            }

            try context.executeSetStorageDelete(self.createAnyRequest())

            guard !encodedValues.isEmpty else { return }

            let insertRequest = self.createInsertRequest(encodedValues: encodedValues)
            insertRequest.resultType = .statusOnly

            guard
                let result = try context.execute(insertRequest) as? NSBatchInsertResult,
                result.result as? Bool == true
            else {
                throw CoreDataSetStorageError.batchInsertFailed
            }
        }
    }

    public func get() -> Promise<Set<Value>, Error> {
        execute { context in
            let dictionaries = try context.fetch(self.createDataRequest())
            var values = Set<Value>(minimumCapacity: dictionaries.count)

            for dictionary in dictionaries {
                guard let data = dictionary["data"] as? Data else {
                    throw CoreDataSetStorageError.requestResultNotFound
                }
                values.insert(try self.decoder.decode(Value.self, from: data))
            }

            return values
        }
    }

    public func clear() -> Promise<Void, Error> {
        execute { context in
            try context.executeSetStorageDelete(self.createAnyRequest())
        }
    }
}

extension CoreDataSetStorage {
    public func count() -> Promise<Int, Error> {
        execute { context in
            try context.count(for: self.createAnyRequest())
        }
    }

    public func size() -> Promise<Volume, Error> {
        execute { context in
            let result = try context.fetch(self.createSizeRequest())
            let byte = result.first?["result"] as? NSNumber ?? 0

            return Volume.byte(byte.doubleValue)
        }
    }
}

extension CoreDataSetStorage {
    fileprivate func createInsertRequest(encodedValues: [Data]) -> NSBatchInsertRequest {
        if #available(iOS 14.0, macOS 11.0, macCatalyst 14.0, tvOS 14.0, watchOS 7.0, *) {
            var index = 0

            return NSBatchInsertRequest(
                entity: entity,
                dictionaryHandler: { dictionary in
                    guard index < encodedValues.count else { return true }

                    let data = encodedValues[index]
                    dictionary["data"] = data
                    dictionary["byte"] = data.count
                    index += 1

                    return false
                }
            )
        } else {
            let dictionaries = encodedValues.map { data in
                [
                    "data": data,
                    "byte": data.count
                ] as [String: Any]
            }

            return NSBatchInsertRequest(entity: entity, objects: dictionaries)
        }
    }

    fileprivate func createAnyRequest() -> NSFetchRequest<any NSFetchRequestResult> {
        let request = NSFetchRequest<any NSFetchRequestResult>()
        request.entity = entity

        return request
    }

    fileprivate func createDataRequest() -> NSFetchRequest<NSDictionary> {
        let request = NSFetchRequest<NSDictionary>()
        request.entity = entity
        request.propertiesToFetch = ["data"]
        request.resultType = .dictionaryResultType

        return request
    }

    fileprivate func createSizeRequest() -> NSFetchRequest<NSDictionary> {
        let byteExpression = NSExpression(forKeyPath: \SabyCoreDataSetStorageItemVersion1.byte)
        let sumExpression = NSExpression(forFunction: "sum:", arguments: [byteExpression])
        let sumDescription = NSExpressionDescription()
        sumDescription.expression = sumExpression
        sumDescription.name = "result"
        sumDescription.expressionResultType = .integer64AttributeType

        let request = NSFetchRequest<NSDictionary>()
        request.entity = entity
        request.propertiesToFetch = [sumDescription]
        request.resultType = .dictionaryResultType

        return request
    }
}

extension CoreDataSetStorage {
    fileprivate func execute<Result>(
        block: @escaping (Context) throws -> Result
    ) -> Promise<Result, Error> {
        let loadPromiseCapture = contextPromise.mutate {
            let capture = !$0.isRejected ? $0 : contextLoad()
            return capture
        }

        return loadPromiseCapture.then { context in
            Promise<Result, Error> { resolve, reject in
                context.perform {
                    do {
                        resolve(try block(context))
                    } catch {
                        reject(error)
                    }
                }
            }
        }
    }
}

private extension NSManagedObjectContext {
    func executeSetStorageDelete(
        _ request: NSFetchRequest<any NSFetchRequestResult>
    ) throws {
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: request)
        deleteRequest.resultType = .resultTypeStatusOnly

        guard
            let result = try execute(deleteRequest) as? NSBatchDeleteResult,
            result.result as? Bool == true
        else {
            throw CoreDataSetStorageError.batchDeleteFailed
        }
    }

    static func loadSetStorage(
        directoryURL: URL,
        storageName: String,
        migration: @escaping () -> Promise<Void, Error>,
        model: NSManagedObjectModel
    ) -> Promise<NSManagedObjectContext, Error> {
        migration().then {
            let fileManager = FileManager.default

            guard directoryURL.isFileURL else {
                throw StorageError.directoryURLIsNotFileURL
            }

            if !fileManager.fileExists(atPath: directoryURL.path) {
                try fileManager.createDirectory(
                    at: directoryURL,
                    withIntermediateDirectories: true
                )
            }

            let url = directoryURL.appendingPathComponent("\(storageName)_\(STORAGE_VERSION)")
            let container = NSPersistentContainer(
                name: storageName,
                managedObjectModel: model
            )
            let storeDescription = NSPersistentStoreDescription(url: url)
            container.persistentStoreDescriptions = [storeDescription]

            return Promise { resolve, reject in
                container.loadPersistentStores { _, error in
                    if let error {
                        reject(error)
                        return
                    }
                    resolve(container.newBackgroundContext())
                }
            }
        }
    }
}

public enum CoreDataSetStorageError: Error {
    case batchDeleteFailed
    case batchInsertFailed
    case requestResultNotFound
}

// Must not be modified. Write new ItemVersion and write migration logic instead.
@objc(SabyCoreDataSetStorageItemVersion1)
final class SabyCoreDataSetStorageItemVersion1: NSManagedObject {
    @NSManaged var data: Data
    @NSManaged var byte: Int
}

final class SabyCoreDataSetStorageSchema {
    let entity: NSEntityDescription
    let model: NSManagedObjectModel

    init() {
        let dataAttribute = NSAttributeDescription()
        dataAttribute.name = "data"
        if #available(iOS 15.0, macOS 12.0, macCatalyst 15.0, tvOS 15.0, watchOS 8.0, *) {
            dataAttribute.type = .binaryData
        } else {
            dataAttribute.attributeType = .binaryDataAttributeType
        }

        let byteAttribute = NSAttributeDescription()
        byteAttribute.name = "byte"
        if #available(iOS 15.0, macOS 12.0, macCatalyst 15.0, tvOS 15.0, watchOS 8.0, *) {
            byteAttribute.type = .integer64
        } else {
            byteAttribute.attributeType = .integer64AttributeType
        }

        let itemEntity = NSEntityDescription()
        itemEntity.name = String(describing: SabyCoreDataSetStorageItemVersion1.self)
        itemEntity.managedObjectClassName = String(describing: SabyCoreDataSetStorageItemVersion1.self)
        itemEntity.properties = [
            dataAttribute,
            byteAttribute
        ]

        let model = NSManagedObjectModel()
        model.entities = [itemEntity]

        self.entity = itemEntity
        self.model = model
    }
}
