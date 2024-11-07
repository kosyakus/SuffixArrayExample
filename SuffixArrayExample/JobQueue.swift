//
//  JobQueue.swift
//  SuffixArrayExample
//
//  Created by Natalia Sinitsyna on 06.11.2024.
//

import SwiftUI
import Combine

class JobQueue {
    private var tasks: [() async -> Void] = []
    private var isExecuting = false

    func addJob(_ job: @escaping () async -> Void) {
        tasks.append(job)
        processNextJob()
    }
    
    private func processNextJob() {
        guard !isExecuting, !tasks.isEmpty else { return }

        let nextJob = tasks.removeFirst()
        isExecuting = true

        Task {
            await nextJob()
            isExecuting = false
            processNextJob()
        }
    }
}
