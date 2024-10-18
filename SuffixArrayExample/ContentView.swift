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
    
    var body: some View {
            VStack {
                TextField("Введите текст", text: $inputText)
                    .onChange(of: inputText) { _, newValue in
                        guard inputText.count > 3 else {
                            suffixMatches = [:] // Очистить, если текст слишком короткий
                            return
                        }
                        let suffixArray = SuffixArray(text: inputText)
                        suffixMatches = suffixArray.calculateSuffixMatches()
                        
                        // Разбиваем текст на слова
//                        let words = inputText.split(separator: " ").map { String($0) }
//                        var allSuffixes: [String: Int] = [:]
//                        
//                        // Для каждого слова создаем SuffixSequence
//                        for word in words {
//                            let suffixSequence = SuffixSequence(word: word)
//                            for suffix in suffixSequence {
//                                allSuffixes[suffix, default: 0] += 1
//                            }
//                        }
//                        
//                        // Сохраняем суффиксы с длиной > 3 и больше 1 совпадения
//                        suffixMatches = allSuffixes.filter { $0.key.count > 3 && $0.value > 1 }
                    }
                    .padding()
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                List(suffixMatches.keys.sorted(), id: \.self) { suffix in
                    HStack {
                        Text("\(suffix) –")
                        Spacer()
                        Text("\(suffixMatches[suffix] ?? 0)")
                    }
                }
            }
            .padding()
        }
}

#Preview {
    ContentView()
}
