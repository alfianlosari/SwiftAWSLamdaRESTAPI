//
//  TodoFormViewModel.swift
//  Todo
//
//  Created by Alfian Losari on 02/07/20.
//

import SwiftUI

class TodoFormViewModel: ObservableObject {
    
    let todoService: TodoProvider
    @Published var isUploaded = false
    @Published var isUploading = false
    @Published var error: Error?
    
    init(todoService: TodoProvider = TodoProvider.shared) {
        self.todoService = todoService
    }
    
    func update(todo: Todo) {
        self.error = nil
        self.isUploaded = false
        self.isUploading = true

        todoService.updateTodo(todo) { [weak self] (result) in
            DispatchQueue.main.async {
                self?.isUploading = false
                switch result {
                case .success:
                    self?.isUploaded = true
                case .failure(let error):
                    self?.error = error
                }
            }
        }
    }
    
    func create(todo: TodoProperties) {
        self.error = nil
        self.isUploaded = false
        self.isUploading = true
        
        todoService.createTodo(todo) { [weak self] (result) in
            DispatchQueue.main.async {
                self?.isUploading = false
                switch result {
                case .success:
                    self?.isUploaded = true
                case .failure(let error):
                    self?.error = error
                }
            }
        }
    }
}
