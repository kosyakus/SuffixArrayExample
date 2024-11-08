//
//  SuffixViewModel.swift
//  SuffixArrayExample
//
//  Created by Natalia Sinitsyna on 18.10.2024.
//

import Combine
import SwiftUI

struct SearchResult: Identifiable {
    let id = UUID()
    let suffix: String
    let searchTime: TimeInterval
    var color: Color = .clear
    
    // Метод для вычисления цвета на основе времени выполнения
    mutating func updateColor(minTime: TimeInterval, maxTime: TimeInterval) {
        guard maxTime > minTime else {
            self.color = .green
            return
        }
        
        // Нормализуем значение searchTime к диапазону от 0 до 1
        let normalizedTime = (searchTime - minTime) / (maxTime - minTime)
        
        // Устанавливаем цвет в зависимости от нормализованного времени (от зеленого к красному)
        let redComponent = normalizedTime
        let greenComponent = 1 - normalizedTime
        self.color = Color(
            red: redComponent,
            green: greenComponent,
            blue: 0
        )
    }
}

class SuffixViewModel: ObservableObject {
    @Published var searchText: String = ""
    @Published var searchHistory: [String] = [] // История поиска
    @Published var suffixMatches: [String: Int] = [:]
    @Published var filteredSuffixMatches: [String: Int] = [:] // Отфильтрованные результаты
    @Published var debouncedSearchText: String = ""
    
    @Published var searchTime: TimeInterval? = nil // Время выполнения последнего поиска
    @Published var searchResults: [SearchResult] = [] // Массив для хранения результатов с временем выполнения
    
    private let jobQueue = JobQueue()
    private let jobScheduler = JobScheduler()
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        // Используем Combine для debounce
        $searchText
            .debounce(for: .milliseconds(500), scheduler: RunLoop.main)
            .sink { [weak self] text in
                //                self?.debouncedSearchText = text
                self?.performSearch(for: text)
            }
            .store(in: &cancellables)
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
}
