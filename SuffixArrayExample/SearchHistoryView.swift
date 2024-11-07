//
//  SearchHistoryView.swift
//  SuffixArrayExample
//
//  Created by Natalia Sinitsyna on 06.11.2024.
//

import SwiftUI

// Экран истории поиска
struct SearchHistoryView: View {
    let history: [String]
    
    var body: some View {
        List(history, id: \.self) { item in
            Text(item)
        }
        .navigationTitle("История поиска")
    }
}
