//
//  ContentView.swift
//  Todo
//
//  Created by Alfian Losari on 02/07/20.
//

import SwiftUI

enum FormType: Identifiable {
    
    var id: String {
        switch self {
        case .add: return "add"
        case .edit(let todo): return "edit-\(todo.id ?? "")"
        }
    }
    
    case add
    case edit(Todo)
}

struct ContentView: View {
    
    @StateObject var todoList = TodoListViewModel()
    @State var formType: FormType?
    
    var body: some View {
        NavigationView {
            TodoListView(lastUpdatedAt: self.todoList.lastUpdatedAt, formType: $formType, onDelete: { todo in
                todoList.deleteTodo(todo: todo)
            })
            .navigationTitle("Todos-DynamoDB")
            .navigationBarItems(leading: Button(action: todoList.loadTodoList, label: {
                Image(systemName: "arrow.2.circlepath")
            }), trailing: Button(action: {
                formType = .add
            }, label: {
                Image(systemName: "plus")
            }))
            .sheet(item: $formType) { (formType) in
                switch formType {
                case .add:
                    TodoFormView(name: "", isCompleted: false, dueDate: Date())
                case .edit(let todoEdit):
                    TodoFormView(name: todoEdit.name ?? "", isCompleted: todoEdit.isCompleted, dueDate: todoEdit.dueDate ?? Date(), todoEdit: todoEdit)
                }
            }
            .onAppear {
                todoList.loadTodoList()
            }
        }
    }
}

struct TodoListView: View {
    
    let lastUpdatedAt: Date?
    @Binding var formType: FormType?
    @State var selection: Todo?
    var onDelete: (Todo) -> ()
    
    @FetchRequest(
        entity: Todo.entity(),
        sortDescriptors: [
            NSSortDescriptor(keyPath: \Todo.isCompleted, ascending: true),
            NSSortDescriptor(keyPath: \Todo.dueDate, ascending: false)
        ]
    )
    var todos: FetchedResults<Todo>
    
    var body: some View {
        List(selection: $selection) {
            ForEach(todos) { (todo: Todo) in
                
                Section {
                    Button {
                        self.formType = .edit(todo)
                    } label: {
                        HStack {
                            VStack(alignment: .leading, spacing: 8) {
                                Text(todo.name ?? "")
                                    .font(.headline)
                                Text("Due \(todo.formattedDueDateText)")
                                    .font(.subheadline)
                                    .foregroundColor(Color(UIColor.secondaryLabel))
                            }
                            
                            Spacer()
                            
                            if todo.isCompleted {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.green)
                            } else {
                                Image(systemName: "chevron.right")
                                    .foregroundColor(Color(UIColor.systemBlue))
                                
                            }   
                        }
                    }
                    .listRowInsets(EdgeInsets.init(top: 12, leading: 16, bottom: 12, trailing: 16))
                }
                
            }
            
            .onDelete { indexSet in
                if let index = indexSet.first {
                    let deletedTodo = todos[index]
                    self.onDelete(deletedTodo)
                }
            }
        }
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
