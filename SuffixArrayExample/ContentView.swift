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
                    
                    let words = inputText.split(separator: " ").map { String($0) }
                    var allSubstrings: [String: Int] = [:]
                    
                    for word in words {
                        let suffixSequence = SuffixSequence(word: word)
                        
                        for substring in suffixSequence {
                            // Считаем только подстроки длиной >= 3 символа
                            guard substring.count >= 3 else { continue }
                            allSubstrings[substring, default: 0] += 1
                        }
                    }
                    
                    // Оставляем только повторяющиеся подстроки
                    suffixMatches = allSubstrings.filter { $0.value > 1 }
                    print("Final substring matches: \(suffixMatches)") // Отладка
                    
                    
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
