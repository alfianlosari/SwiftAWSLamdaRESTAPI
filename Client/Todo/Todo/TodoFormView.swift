//
//  TodoFormView.swift
//  Todo
//
//  Created by Alfian Losari on 02/07/20.
//

import SwiftUI

struct TodoFormView: View {
    
    @State var name: String
    @State var isCompleted: Bool
    @State var dueDate: Date
    
    var todoEdit: Todo?
    
    @StateObject var todoFormVM = TodoFormViewModel()
    
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            Form {
                
                Section {
                    TextEditor(text: $name)
                        .frame(height: 160)
                }
                
                
                
                Toggle("Completed", isOn: $isCompleted)
                DatePicker("Due date", selection: self.$dueDate)
            }
            
            .navigationBarItems(leading: Button(action: {
                presentationMode.wrappedValue.dismiss()
            }, label: {
                Text("Cancel")
            }), trailing: Button(action: {
                guard !name.isEmpty else { return }
                if let todoEdit = self.todoEdit {
                    todoEdit.name = name
                    todoEdit.isCompleted = isCompleted
                    todoEdit.dueDate = dueDate
                    todoFormVM.update(todo: todoEdit)
                } else {
                    let todo = TodoProperties(id: UUID().uuidString, name: name, isCompleted: isCompleted, dueDate: dueDate, createdAt: Date(), updatedAt: Date())
                    todoFormVM.create(todo: todo)
                }
            }, label: {
                Text("Save")
            }))
            .navigationTitle(todoEdit == nil ? "Create Todo" : "Update Todo")
            .onChange(of: self.todoFormVM.isUploaded) { value in
                guard value else {
                    return
                }
                presentationMode.wrappedValue.dismiss()
            }
            .overlay(Group {
                if todoFormVM.isUploading {
                    ProgressView("Submitting...")
                } else {
                    EmptyView()
                }
            })
            .disabled(todoFormVM.isUploading)
        }
    }
    
}

struct TodoFormView_Previews: PreviewProvider {
    static var previews: some View {
        TodoFormView(name: "", isCompleted: false, dueDate: Date())
    }
}
