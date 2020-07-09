//
//  TodoProvider.swift
//  Todo
//
//  Created by Alfian Losari on 02/07/20.
//

import CoreData

class TodoProvider {
    
    static let shared = TodoProvider()
    private init() {}
    
    static let jsonDecoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .formatted(Utils.iso8601Formatter)
        return decoder
    }()
    
    let baseURL = "PASTE_YOUR_ENDPOINT_HERE/dev/todos"
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Todo")
        container.loadPersistentStores { storeDesription, error in
            guard error == nil else {
                fatalError("Unresolved error \(error!)")
            }
        }
        container.viewContext.automaticallyMergesChangesFromParent = false
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        container.viewContext.undoManager = UndoManager()
        container.viewContext.shouldDeleteInaccessibleFaults = true
        return container
    }()
    
    private func newTaskContext() -> NSManagedObjectContext {
        let taskContext = persistentContainer.newBackgroundContext()
        taskContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        taskContext.undoManager = nil
        return taskContext
    }
    
    func createTodo(_ todo: TodoProperties, completionHandler: @escaping (Result<Todo, Error>) -> ()) {
        guard let url = URL(string: baseURL), let data = try? JSONSerialization.data(withJSONObject: todo.uploadDictionary, options: []) else {
            completionHandler(.failure(TodoError.invalidRequest))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = data
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let session = URLSession(configuration: .default)
        session.dataTask(with: request) { (data, response, urlSessionError) in
            DispatchQueue.main.async {
                if let error = urlSessionError {
                    completionHandler(.failure(error))
                    return
                }
                
                guard let data = data else {
                    completionHandler(.failure(TodoError.noConnection))
                    return
                }
                
                do {
                    let todoProperty = try TodoProvider.jsonDecoder.decode(TodoProperties.self, from: data)
                    let todo = Todo(entity: Todo.entity(), insertInto: self.persistentContainer.viewContext)
            
                    try todo.update(with: todoProperty.dictionary)
                    
                    try? self.persistentContainer.viewContext.save()
                    completionHandler(.success(todo))
                } catch {
                    completionHandler(.failure(error))
                }
            }
        }.resume()
    }
    
    func updateTodo(_ todo: Todo, completionHandler: @escaping (Result<Todo, Error>) -> ()) {
        let todoProperties = TodoProperties(id: todo.id ?? "", name: todo.name ?? "", isCompleted: todo.isCompleted, dueDate: todo.dueDate ?? Date(), createdAt: Date(), updatedAt: Date())
        
        guard let url = URL(string: baseURL)?.appendingPathComponent(todoProperties.id),
              let data = try? JSONSerialization.data(withJSONObject: todoProperties.uploadDictionary, options: []) else {
            completionHandler(.failure(TodoError.invalidRequest))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.httpBody = data
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let session = URLSession(configuration: .default)
        session.dataTask(with: request) { (data, response, urlSessionError) in
            DispatchQueue.main.async {
                if let error = urlSessionError {
                    self.persistentContainer.viewContext.undo()
                    completionHandler(.failure(error))
                    return
                }
                
                guard let data = data else {
                    self.persistentContainer.viewContext.undo()
                    completionHandler(.failure(TodoError.noConnection))
                    return
                }
                
                do {
                    let todoProperty = try TodoProvider.jsonDecoder.decode(TodoProperties.self, from: data)
                    todo.createdAt = todoProperty.createdAt
                    todo.updatedAt = todoProperty.updatedAt
                    try? self.persistentContainer.viewContext.save()
                    completionHandler(.success(todo))
                } catch {
                    completionHandler(.failure(error))
                }
            }
        }.resume()
    }
    
    
    func deleteTodo(todo: Todo, completionHandler: @escaping (Result<Void, Error>) -> ()) {
        guard let url = URL(string: baseURL)?.appendingPathComponent(todo.id ?? "") else {
            completionHandler(.failure(TodoError.invalidRequest))
            return
        }
        
        self.persistentContainer.viewContext.delete(todo)
        
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        
        let session = URLSession(configuration: .default)
        session.dataTask(with: request) { (data, response, urlSessionError) in
            DispatchQueue.main.async {
                if let error = urlSessionError {
                    self.persistentContainer.viewContext.undo()
                    completionHandler(.failure(error))
                    return
                }
                
                guard let _ = data else {
                    self.persistentContainer.viewContext.undo()
                    completionHandler(.failure(TodoError.noConnection))
                    return
                }
                
                try? self.persistentContainer.viewContext.save()
                completionHandler(.success(()))
            }
        }.resume()
    }
    
    func fetchTodoList(completionHandler: @escaping (Error?) -> Void) {
        guard let jsonURL = URL(string: baseURL) else {
            completionHandler(TodoError.invalidRequest)
            return
        }
        let session = URLSession(configuration: .default)
        
        let task = session.dataTask(with: jsonURL) { data, _, urlSessionError in
            guard urlSessionError == nil else {
                completionHandler(urlSessionError)
                return
            }
            
            guard let data = data else {
                completionHandler(TodoError.noConnection)
                return
            }
            
            self.deleteAll { (error) in
                if let error = error {
                    completionHandler(error)
                    return
                }
                
                do {
                    let todos = try TodoProvider.jsonDecoder.decode([TodoProperties].self, from: data)
                    try self.importTodos(from: todos)
                    
                } catch {
                    completionHandler(error)
                    return
                }
                completionHandler(nil)
            }
        }
        task.resume()
    }
    
    private func importTodos(from todos: [TodoProperties]) throws {
        guard !todos.isEmpty else { return }
        
        var performError: Error?
        let todosDictionaryList = todos.map { $0.dictionary }
        
        let taskContext = newTaskContext()
        taskContext.performAndWait {
            let batchInsert = self.newBatchInsertRequest(with: todosDictionaryList)
            batchInsert.resultType = .statusOnly
            
            if let batchInsertResult = try? taskContext.execute(batchInsert) as? NSBatchInsertResult,
               let success = batchInsertResult.result as? Bool, success {
                return
            }
            performError = TodoError.importError
        }
        
        if let error = performError {
            throw error
        }
    }
    
    private func newBatchInsertRequest(with todoDictionaryList: [[String: Any]]) -> NSBatchInsertRequest {
        let batchInsert: NSBatchInsertRequest
        var index = 0
        let total = todoDictionaryList.count
        batchInsert = NSBatchInsertRequest(entityName: "Todo", dictionaryHandler: { dictionary in
            guard index < total else { return true }
            dictionary.addEntries(from: todoDictionaryList[index])
            index += 1
            return false
        })
        return batchInsert
    }
    
    func deleteAll(completionHandler: @escaping (Error?) -> Void) {
        let taskContext = newTaskContext()
        taskContext.perform {
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Todo")
            let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
            batchDeleteRequest.resultType = .resultTypeCount
            
            if let batchDeleteResult = try? taskContext.execute(batchDeleteRequest) as? NSBatchDeleteResult,
               batchDeleteResult.result != nil {
                completionHandler(nil)
                
            } else {
                completionHandler(TodoError.deleteError)
            }
        }
    }
    
    func resetContext() {
        persistentContainer.viewContext.reset()
    }
}
