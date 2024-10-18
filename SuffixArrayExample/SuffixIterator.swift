//
//  SuffixIterator.swift
//  SuffixArrayExample
//
//  Created by Natalia Sinitsyna on 14.10.2024.
//

struct SuffixIterator: IteratorProtocol {
    let word: String
    var currentIndex: String.Index
    
    init(word: String) {
        self.word = word
        self.currentIndex = word.startIndex
    }
    
    mutating func next() -> String? {
        guard currentIndex < word.endIndex else { return nil }
        let suffix = String(word[currentIndex...])
        currentIndex = word.index(after: currentIndex)
        return suffix
    }
}
