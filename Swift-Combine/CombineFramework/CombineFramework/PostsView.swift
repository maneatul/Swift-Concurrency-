//
//  PostsView.swift
//  CombineFramework
//
//  Created by Atul Mane on 13/09/24.
//
// Publisher example

import SwiftUI
import Combine

struct Post: Codable, Identifiable {
    let id: Int
    let title: String
}

class PostsViewModel: ObservableObject {
    
    @Published var posts: [Post] = []
    private var cancellables = Set<AnyCancellable>()
    
    func fetchPosts() {
            let url = URL(string: "https://jsonplaceholder.typicode.com/posts")!
        URLSession.shared.dataTaskPublisher(for: url)
            .map({$0.data})
            .decode(type: [Post].self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { _ in }, receiveValue: { [weak self ] posts in
                self?.posts = posts
            })
            .store(in: &cancellables)
        
    }
}
/// Here, the fetchPosts() method uses Combine’s dataTaskPublisher to fetch data from an API and update the SwiftUI list.

struct PostsView: View {
    
    @StateObject private var vm = PostsViewModel()
    
    var body: some View {
        List(vm.posts) { post in
            Text(post.title)
        }
        .task {
            vm.fetchPosts()
        }
    }
}

#Preview {
    PostsView()
}
