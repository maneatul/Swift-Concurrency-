//
//  SearchView.swift
//  CombineFramework
//
//  Created by Atul Mane on 13/09/24.
//
// Example: Debouncing a Search TextField
//
// The debounce operator delays the emission of values from the publisher, ensuring that only the last value is emitted after a specified delay. This is useful in scenarios like searching, where you don’t want to fire a search query on every keystroke, but only after the user has stopped typing for a specified time.



import SwiftUI
import Combine

class SearchViewModel: ObservableObject {
    
    @Published var searchText: String = ""
    @Published var searchResult: [String] = []
    
    private var cancellables = Set<AnyCancellable>()
    
    private let allData = ["Apple", "Banana", "Orange", "Grapes", "Strawberry", "Blueberry", "Mango"]

    init() {
        $searchText
            .debounce(for: .seconds(0.5), scheduler: DispatchQueue.main)
            .removeDuplicates() // remove consecutive duplicate searches
            .sink { [weak self] query in
                self?.search(query)
            }
            .store(in: &cancellables)
    }
    
    private func search(_ query: String) {
        if query.isEmpty {
            searchResult = []
        } else {
            searchResult = allData.filter { $0.lowercased().contains(query.lowercased())}
        }
        
    }
}

struct SearchView: View {
    
    @StateObject private var viewModel = SearchViewModel()

    var body: some View {
        VStack {
            TextField("Search...", text: $viewModel.searchText)
                .padding()
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            List(viewModel.searchResult, id: \.self) { result in
                    Text(result)
            }
        }
        
    }
}

#Preview {
    SearchView()
}
