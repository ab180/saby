//
//  ConcurrencyTaskBag.swift
//  SabyConcurrency
//
//  Created by mjgu on 2026/09/14.
//

import Foundation

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
final class ConcurrencyTaskBag: @unchecked Sendable {
    private let state = Atomic(State())

    var isEmpty: Bool { state.capture { $0.tasks.isEmpty } }

    func insert(_ id: UUID, task: Task<Void, Never>) {
        var shouldCancel = false

        state.mutate { state in
            var state = state
            if state.isCanceled {
                shouldCancel = true
            }
            else if state.completedTaskIDs.contains(id) {
                state.completedTaskIDs.remove(id)
            }
            else {
                state.tasks[id] = task
            }
            return state
        }

        if shouldCancel {
            task.cancel()
        }
    }

    func remove(_ id: UUID) {
        state.mutate { state in
            var state = state
            guard !state.isCanceled else { return state }
            if state.tasks.removeValue(forKey: id) == nil {
                state.completedTaskIDs.insert(id)
            }
            return state
        }
    }

    func cancelAll() {
        var tasks = [Task<Void, Never>]()

        state.mutate { state in
            var state = state
            state.isCanceled = true
            tasks = Array(state.tasks.values)
            state.tasks.removeAll()
            state.completedTaskIDs.removeAll()
            return state
        }

        tasks.forEach { $0.cancel() }
    }

    private struct State {
        var isCanceled = false
        var tasks = [UUID: Task<Void, Never>]()
        var completedTaskIDs = Set<UUID>()
    }
}
