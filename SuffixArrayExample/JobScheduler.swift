//
//  JobScheduler.swift
//  SuffixArrayExample
//
//  Created by Natalia Sinitsyna on 07.11.2024.
//

import Foundation

actor JobScheduler {
    private var jobQueue: [() async -> Void] = [] // Очередь задач
    private var isExecuting = false               // Флаг выполнения задач

    // Метод для добавления задачи в очередь
    func addJob(_ job: @escaping () async -> Void) {
        jobQueue.append(job)
        processNextJob()
    }
    
    // Выполняем следующую задачу в очереди
    private func processNextJob() {
        // Если уже выполняется задача или очередь пуста, выходим
        guard !isExecuting, !jobQueue.isEmpty else { return }

        let nextJob = jobQueue.removeFirst()
        isExecuting = true

        Task {
            await nextJob() // Выполняем задачу
            isExecuting = false
            processNextJob() // Рекурсивно запускаем следующую задачу
        }
    }
}
