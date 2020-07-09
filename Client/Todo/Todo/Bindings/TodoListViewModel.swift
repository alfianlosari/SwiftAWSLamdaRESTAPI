//
//  TodoListViewModel.swift
//  Todo
//
//  Created by Alfian Losari on 02/07/20.
//

import SwiftUI

class TodoListViewModel: ObservableObject {
    
    let service: TodoProvider
    @Published var error: Error?
    @Published var lastUpdatedAt: Date?
    
    init(service: TodoProvider = TodoProvider.shared) {
        self.service = service
    }
    
    func loadTodoList() {
        self.error = nil
        service.fetchTodoList { error in
            DispatchQueue.main.async { [weak self] in
                self?.error = error
                self?.service.resetContext()
                self?.lastUpdatedAt = error == nil ? Date() : nil
            }
        }
    }
    
    func deleteTodo(todo: Todo) {
        service.deleteTodo(todo: todo) { (_) in
//            DispatchQueue.main.async { [weak self] in
//
//            }
            
        }
    }
}

