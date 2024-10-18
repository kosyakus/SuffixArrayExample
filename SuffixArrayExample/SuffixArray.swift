//
//  SuffixArray.swift
//  SuffixArrayExample
//
//  Created by Natalia Sinitsyna on 14.10.2024.
//

struct SuffixArray {
    var text: String
    
    func buildSuffixArray(minLength: Int = 3) -> [String] {
            var suffixes: [String] = []
            for index in text.indices {
                let suffix = String(text[index...])
                if suffix.count >= minLength {
                    suffixes.append(suffix)
                }
            }
            return suffixes
        }
    
    func calculateSuffixMatches(minLength: Int = 3) -> [String: Int] {
        let suffixes = buildSuffixArray()
        var suffixCounts: [String: Int] = [:]
        
        for suffix in suffixes {
            let trimmedSuffix = String(suffix.prefix(minLength))
            if trimmedSuffix.count >= minLength {
                suffixCounts[trimmedSuffix, default: 0] += 1
            }
        }
        
        return suffixCounts.filter { $0.value > 1 } // Оставляем только повторяющиеся суффиксы
    }
}
