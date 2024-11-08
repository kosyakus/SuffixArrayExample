//
//  SuffixViewModel.swift
//  SuffixArrayExample
//
//  Created by Natalia Sinitsyna on 18.10.2024.
//

import Combine
import SwiftUI

class SuffixViewModel: ObservableObject {
    @Published var searchText: String = ""
    @Published var searchHistory: [String] = [] // История поиска
    @Published var suffixMatches: [String: Int] = [:]
    @Published var filteredSuffixMatches: [String: Int] = [:] // Отфильтрованные результаты
    @Published var debouncedSearchText: String = ""
    
    @Published var searchTime: TimeInterval? = nil // Время выполнения последнего поиска
    @Published var searchResults: [SearchResult] = [] // Массив для хранения результатов с временем выполнения
    @Published var summaryResult: SummaryResult? // Результат для отображения Summary
    
    private let jobQueue = JobQueue()
    private let jobScheduler = JobScheduler()
    
    private var cancellables = Set<AnyCancellable>()
    private var timerCancellable: AnyCancellable?
    
    init() {
        // Используем Combine для debounce
        $searchText
            .debounce(for: .milliseconds(500), scheduler: RunLoop.main)
            .sink { [weak self] text in
                //                self?.debouncedSearchText = text
                self?.performSearch(for: text)
            }
            .store(in: &cancellables)
        
        // Запуск задачи SummaryJob с интервалом
        startSummaryJob()
    }
    
    func addToHistory(_ search: String) {
        if !search.isEmpty && !searchHistory.contains(search) {
            searchHistory.append(search)
        }
    }
    
    // Асинхронный поиск по результату
    func performSearch(for query: String) {
        jobQueue.addJob { [weak self] in
            guard let self = self else { return }
            
            let startTime = Date() // Время начала поиска
            
            // Выполняем фильтрацию асинхронно
            let results = self.suffixMatches.filter { $0.key.lowercased().contains(query.lowercased()) }
            
            // Измеряем время выполнения
            let endTime = Date()
            let elapsedTime = endTime.timeIntervalSince(startTime)
            
            // Обновляем отфильтрованные данные на главном потоке
            await MainActor.run {
                self.filteredSuffixMatches = results
                
                if self.searchText != "" {
                    self.searchResults.append(SearchResult(suffix: self.searchText, searchTime: elapsedTime))
                }
                self.searchTime = elapsedTime // Сохраняем время выполнения поиска
                
                //                print("Search Results: \(self.searchResults)")
                //                print("Filtered results: \(results)") // Отладка
            }
        }
    }
    
    func performAsyncTask() {
        Task { [weak self] in
            guard let self = self else { return }
            await self.jobScheduler.addJob {
                await self.asyncColor()
            }
        }
    }
    
    private func asyncColor() async {
        // Реализация асинхронной задачи
        let minTime = searchResults.map { $0.searchTime }.min() ?? 0
        let maxTime = searchResults.map { $0.searchTime }.max() ?? 1
        
        await MainActor.run {
            // Обновляем цвета для каждого результата на основе времени выполнения
            self.searchResults = self.searchResults.map { result in
                var updatedResult = result
                updatedResult.updateColor(minTime: minTime, maxTime: maxTime)
                return updatedResult
            }
        }
    }
    
    // Запуск задачи SummaryJob с интервалом в 1-2 минуты
    private func startSummaryJob() {
        timerCancellable = Timer.publish(every: Double.random(in: 20...30), on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                Task {
                    await self?.jobScheduler.addJob {
                        await self?.calculateSummary()
                    }
                }
            }
    }
    
    // Расчет Summary по поискам
    private func calculateSummary() async {
        let totalSearches = searchResults.count
        let totalTime = searchResults.reduce(0) { $0 + $1.searchTime }
        let averageTime = totalSearches > 0 ? totalTime / Double(totalSearches) : 0
        let fastestTime = searchResults.map { $0.searchTime }.min() ?? 0
        let slowestTime = searchResults.map { $0.searchTime }.max() ?? 0
        
        let summary = SummaryResult(
            totalSearches: totalSearches,
            averageTime: averageTime,
            fastestTime: fastestTime,
            slowestTime: slowestTime
        )
        
        await MainActor.run {
            self.summaryResult = summary
            print("Summary updated: \(summary)")
        }
    }
}
