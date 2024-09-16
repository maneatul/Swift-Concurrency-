//
//  MergeView.swift
//  CombineFramework
//
//  Created by Atul Mane on 13/09/24.
//
//Merge Publisher
// The merge operator combines multiple publishers of the same type and emits values from any of them as soon as they are available. This is useful when you have different data sources that should be treated equally, and you want to combine their emissions into one stream.

import SwiftUI
import Combine

class MergeViewModel: ObservableObject {
    @Published var output: String = ""
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        let timer1 = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .map { _ in "Timer 1 fired" }
        
        let timer2 = Timer.publish(every: 2, on: .main, in: .common)
            .autoconnect()
            .map { _ in "Timer 2 fired" }
        
        // Merge the two timers
        Publishers.Merge(timer1, timer2)
            .sink { [weak self] value in
                self?.output = value
            }
            .store(in: &cancellables)
    }
}

struct MergeView: View {
    @StateObject private var viewModel = MergeViewModel()

    var body: some View {
        Text(viewModel.output)
            .font(.largeTitle)
            .padding()
    }
}

#Preview {
    MergeView()
}
