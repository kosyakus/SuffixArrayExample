//
//  SuffixSequence.swift
//  SuffixArrayExample
//
//  Created by Natalia Sinitsyna on 14.10.2024.
//

struct SuffixSequence: Sequence {
    let word: String
    
    func makeIterator() -> SuffixIterator {
        return SuffixIterator(word: word)
    }
}
