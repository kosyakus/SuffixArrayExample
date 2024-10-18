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
    
    enum SortOrder: String, CaseIterable {
        case ascending = "ASC"
        case descending = "DESC"
    }
    
    var body: some View {
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
                            // Считаем только подстроки длиной >= 3 символа
                            guard suffix.count >= 3 else { continue }
                            allSuffixes[suffix, default: 0] += 1
                        }
                    }
                    
                    // Оставляем только повторяющиеся подстроки
                    suffixMatches = allSuffixes.filter { $0.value > 1 }
                    print("Final substring matches: \(suffixMatches)") // Отладка
                    
                    
                }
                .padding()
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            // Picker для выбора порядка сортировки
            Picker("Sort Order", selection: $sortOrder) {
                ForEach(SortOrder.allCases, id: \.self) { order in
                    Text(order.rawValue).tag(order)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()
            
            
            List(sortedSuffixes(), id: \.key) { suffix, count in
                HStack {
                    Text("\(suffix)")
                    Spacer()
                    if count > 1 {
                        Text("\(count)") // Показываем количество повторений
                    }
                }
            }
        }
        .padding()
    }
    
    // Функция для сортировки суффиксов в зависимости от выбранного порядка
    private func sortedSuffixes() -> [(key: String, value: Int)] {
        switch sortOrder {
        case .ascending:
            return suffixMatches.sorted { $0.key < $1.key }
        case .descending:
            return suffixMatches.sorted { $0.key > $1.key }
        }
    }
}

#Preview {
    ContentView()
}
