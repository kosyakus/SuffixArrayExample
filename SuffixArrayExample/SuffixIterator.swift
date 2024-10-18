//
//  SuffixIterator.swift
//  SuffixArrayExample
//
//  Created by Natalia Sinitsyna on 14.10.2024.
//

struct SuffixIterator: IteratorProtocol {
    let word: String
    var currentIndex: String.Index
    let minLength: Int
    
    init(word: String, minLength: Int = 3) {
        self.word = word
        self.currentIndex = word.startIndex
        self.minLength = minLength
    }
    
    mutating func next() -> String? {
        // Ищем подстроки начиная с текущего индекса и длиной >= minLength
        guard currentIndex < word.endIndex else { return nil }
        
        var substrings: [String] = []
        var nextIndex = currentIndex
        
        // Извлекаем подстроки от текущего индекса с длиной >= minLength
        while nextIndex < word.endIndex {
            let substring = String(word[currentIndex...nextIndex])
            if substring.count >= minLength {
                substrings.append(substring)
            }
            nextIndex = word.index(after: nextIndex)
        }
        
        // Сдвигаем индекс вперед для следующего вызова
        currentIndex = word.index(after: currentIndex)
        
        return substrings.isEmpty ? nil : substrings.first
    }
}
