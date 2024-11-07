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
    
    private let jobQueue = JobQueue()
    
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
                self.searchTime = elapsedTime // Сохраняем время выполнения поиска
//                print("Filtered results: \(results)") // Отладка
            }
        }
    }
}
