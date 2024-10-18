//
//  SuffixViewModel.swift
//  SuffixArrayExample
//
//  Created by Natalia Sinitsyna on 18.10.2024.
//

import Combine
import SwiftUI

class SuffixViewModel: ObservableObject {
    @Published var searchText: String = ""
    @Published var debouncedSearchText: String = ""
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        // Используем Combine для debounce
        $searchText
            .debounce(for: .milliseconds(500), scheduler: RunLoop.main)
            .sink { [weak self] text in
                self?.debouncedSearchText = text
            }
            .store(in: &cancellables)
    }
}
