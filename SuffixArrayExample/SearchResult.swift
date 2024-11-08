//
//  SearchResult.swift
//  SuffixArrayExample
//
//  Created by Natalia Sinitsyna on 08.11.2024.
//

import Foundation
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
