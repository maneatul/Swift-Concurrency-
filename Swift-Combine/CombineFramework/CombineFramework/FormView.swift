//
//  FormView.swift
//  CombineFramework
//
//  Created by Atul Mane on 13/09/24.
//
// combineLatest Operator:
// The combineLatest operator combines the latest values from two (or more) publishers into a tuple. It waits until each publisher emits at least one value, and then emits a new tuple every time any of the publishers update.

import SwiftUI
import Combine

class FormViewModel: ObservableObject {
    
    @Published var firstName: String = ""
    @Published var lastName: String = ""
    @Published var fullName: String = ""
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        
        Publishers.CombineLatest($firstName, $lastName)
            .map( { firstName, lastName in
                    return "\(firstName) \(lastName)"
            })
            .assign(to: \.fullName, on: self)
            .store(in: &cancellables)
        
    }
}

struct FormView: View {
    
    @StateObject private var viewModel = FormViewModel()
    
    var body: some View {
        VStack {
            TextField("First Name", text: $viewModel.firstName)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            TextField("Last Name", text: $viewModel.lastName)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            Text("Full Name: \(viewModel.fullName)")
                .font(.headline)
                .padding()
        }
    }
}

#Preview {
    FormView()
}
