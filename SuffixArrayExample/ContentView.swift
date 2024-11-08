//
//  ContentView.swift
//  SuffixArrayExample
//
//  Created by Natalia Sinitsyna on 14.10.2024.
//

import SwiftUI

struct ContentView: View {
    @State private var inputText: String = ""
    @State private var suffixMatches: [String: Int] = [:]
    @State private var sortOrder: SortOrder = .ascending
    
    @StateObject private var viewModel = SuffixViewModel()
    
    enum SortOrder: String, CaseIterable {
        case ascending = "ASC"
        case descending = "DESC"
        case topTen = "Top 10"
    }
    
    var body: some View {
        NavigationView {
        VStack {
            TextField("Введите текст", text: $inputText)
                .onChange(of: inputText) { _, newValue in
                    guard inputText.count > 3 else {
                        suffixMatches = [:] // Очистить, если текст слишком короткий
                        return
                    }
                    
                    let words = inputText.split(separator: " ").map { String($0) }
                    var allSuffixes: [String: Int] = [:]
                    
                    for word in words {
                        let suffixSequence = SuffixSequence(word: word)
                        
                        for suffix in suffixSequence {
                            // Приводим суффикс к нижнему регистру
                            let lowercasedSuffix = suffix.lowercased()
                            // Считаем только подстроки длиной >= 3 символа
                            guard lowercasedSuffix.count >= 3 else { continue }
                            allSuffixes[lowercasedSuffix, default: 0] += 1
                        }
                    }
                    
                    // Оставляем только повторяющиеся подстроки
                    suffixMatches = allSuffixes.filter { $0.value > 1 }
                    print("Final substring matches: \(suffixMatches)") // Отладка
                    
                    
                }
                .padding()
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            // Поле поиска
            TextField("Поиск", text: $viewModel.searchText)
                .padding()
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .onSubmit {
                    viewModel.addToHistory(viewModel.searchText) // Добавляем в историю при поиске
                    viewModel.performAsyncTask()
                }
            
            // Навигация на экран истории поиска
            NavigationLink("История поиска", destination: SearchHistoryView(history: viewModel.searchHistory))
                .padding()
            
            // Picker для переключения между сортировкой по возрастанию, убыванию и топ-10
            Picker("Sort Order", selection: $sortOrder) {
                ForEach(SortOrder.allCases, id: \.self) { tab in
                    Text(tab.rawValue).tag(tab)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()
            
            // Список для отображения результатов поиска с временем выполнения
            List(viewModel.searchResults) { result in
                VStack {
                        Text("Суффикс: \(result.suffix)")
                        Text("Время поиска: \(result.searchTime) секунд")
                            .font(.caption)
                            .foregroundColor(.gray)
                }
                .padding()
                .background(result.color)
            }
            .cornerRadius(16)
            
            if let summary = viewModel.summaryResult {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Сводка по поискам:")
                        .font(.headline)
                    Text("Всего поисков: \(summary.totalSearches)")
                    Text("Среднее время: \(String(format: "%.4f", summary.averageTime)) сек")
                    Text("Самое быстрое время: \(String(format: "%.4f", summary.fastestTime)) сек")
                    Text("Самое медленное время: \(String(format: "%.4f", summary.slowestTime)) сек")
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(8)
                .padding(.top)
            }
            
            // Отображаем контент в зависимости от выбранной вкладки
            if sortOrder == .ascending {
                List(filteredSuffixes(sortedSuffixesAsc()), id: \.key) { suffix, count in
                    HStack {
                        Text("\(suffix)")
                        Spacer()
                        if count > 1 {
                            Text("\(count)")
                        }
                    }
                }
            } else if sortOrder == .descending {
                List(filteredSuffixes(sortedSuffixesDesc()), id: \.key) { suffix, count in
                    HStack {
                        Text("\(suffix)")
                        Spacer()
                        if count > 1 {
                            Text("\(count)")
                        }
                    }
                }
            } else if sortOrder == .topTen {
                List(filteredSuffixes(topTenSuffixes()), id: \.key) { suffix, count in
                    HStack {
                        Text("\(suffix)")
                        Spacer()
                        Text("\(count)")
                    }
                }
            }
        }
        .padding()
        .navigationTitle("Поиск Суффиксов")
    }
    }
    
    // Функция для фильтрации по поиску
    private func filteredSuffixes(_ suffixes: [(key: String, value: Int)]) -> [(key: String, value: Int)] {
        if viewModel.searchText.isEmpty {
            return suffixes
        } else {
            return suffixes.filter { $0.key.lowercased().contains(viewModel.searchText.lowercased()) }
        }
    }
    
    // Функция для сортировки всех суффиксов по возрастанию (ASC)
    private func sortedSuffixesAsc() -> [(key: String, value: Int)] {
        return suffixMatches.sorted { $0.key < $1.key }
    }
    
    // Функция для сортировки всех суффиксов по убыванию (DESC)
    private func sortedSuffixesDesc() -> [(key: String, value: Int)] {
        return suffixMatches.sorted { $0.key > $1.key }
    }
    
    // Функция для получения топ-10 суффиксов по количеству
    private func topTenSuffixes() -> [(key: String, value: Int)] {
        return Array(
            suffixMatches
                .filter { $0.key.count == 3 } // Считаем только трёхбуквенные суффиксы
                .sorted { $0.value > $1.value } // Сортируем по количеству нахождений (по убыванию)
                .prefix(10) // Отбираем топ-10
        )
    }
}

#Preview {
    ContentView()
}
