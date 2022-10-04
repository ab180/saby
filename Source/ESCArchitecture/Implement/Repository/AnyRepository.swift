//
//  AnyRepository.swift
//  SabyESCArchitecture
//
//  Created by WOF on 2022/10/05.
//

extension Repository {
    public typealias AnyRepository = SabyESCArchitecture.AnyRepository<Self.Query, Self.Result>
}

extension Repository {
    @inline(__always) @inlinable
    public func toAnyRepository() -> AnyRepository {
        AnyRepository(self)
    }
}

public struct AnyRepository<Query, Result>: Repository {
    @usableFromInline
    let repositoryBox: AnyRepositoryBoxBase<Query, Result>
    
    @inline(__always) @inlinable
    public init<ActualRepository: Repository>(_ repository: ActualRepository) where
        ActualRepository.Query == Query,
        ActualRepository.Result == Result
    {
        if let anyRepository = repository as? AnyRepository<Query, Result> {
            self.repositoryBox = anyRepository.repositoryBox
        }
        else {
            self.repositoryBox = AnyRepositoryBox(repository)
        }
    }
    
    @inline(__always) @inlinable
    public func request(_ command: Query) -> Result {
        repositoryBox.request(command)
    }
}

@usableFromInline
class AnyRepositoryBoxBase<Query, Result>: Repository {
    @inline(__always) @inlinable
    init() {}
    
    @inline(__always) @inlinable
    func request(_ command: Query) -> Result { fatalError() }
}

@usableFromInline
final class AnyRepositoryBox<ActualRepository: Repository>: AnyRepositoryBoxBase<
    ActualRepository.Query,
    ActualRepository.Result
> {
    @usableFromInline
    let repository: ActualRepository
    
    @inline(__always) @inlinable
    init(_ repository: ActualRepository) {
        self.repository = repository
    }

    @inline(__always) @inlinable
    override func request(_ command: Query) -> Result {
        repository.request(command)
    }
}
