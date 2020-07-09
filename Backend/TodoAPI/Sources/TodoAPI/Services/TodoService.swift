//
//  File.swift
//  
//
//  Created by Alfian Losari on 30/06/20.
//

import AWSDynamoDB
import Foundation

public class TodoService {
    
    let db: DynamoDB
    let tableName: String
    
    public init(db: DynamoDB, tableName: String) {
        self.db = db
        self.tableName = tableName
    }
    
    public func getAllTodos() -> EventLoopFuture<[Todo]> {
        let input = DynamoDB.ScanInput(tableName: tableName)
        
        return db.scan(input).flatMapThrowing { (output) -> [Todo] in
            try output.items?.compactMap { try Todo(dictionary: $0) } ?? []
        }
    }
    
    public func getTodo(id: String) -> EventLoopFuture<Todo> {
        let input = DynamoDB.GetItemInput(key: [Todo.DynamoDBField.id: DynamoDB.AttributeValue(s: id)], tableName: tableName)
        
        return db.getItem(input).flatMapThrowing { (output) -> Todo in
            if output.item == nil { throw APIError.todoNotFound }
            return try Todo(dictionary: output.item ?? [:])
        }
    }
    
    public func createTodo(todo: Todo) -> EventLoopFuture<Todo> {
        var todo = todo
        let currentDate = Date()
        
        todo.updatedAt = currentDate
        todo.createdAt = currentDate
        
        let input = DynamoDB.PutItemInput(item: todo.dynamoDbDictionary, tableName: tableName)
        
        return db.putItem(input).map { (_) -> Todo in
            todo
        }
    }
    
    public func updateTodo(todo: Todo) -> EventLoopFuture<Todo> {
        var todo = todo
        
        todo.updatedAt = Date()
        
        let input = DynamoDB.UpdateItemInput(
            expressionAttributeNames: [
                "#name": Todo.DynamoDBField.name,
                "#isCompleted": Todo.DynamoDBField.isCompleted,
                "#dueDate": Todo.DynamoDBField.dueDate,
                "#updatedAt": Todo.DynamoDBField.updatedAt
            ],
            expressionAttributeValues: [
                ":name": DynamoDB.AttributeValue(s: todo.name),
                ":isCompleted": DynamoDB.AttributeValue(bool: todo.isCompleted),
                ":dueDate": DynamoDB.AttributeValue(s: todo.dueDate?.iso8601 ?? ""),
                ":updatedAt": DynamoDB.AttributeValue(s: todo.updatedAt?.iso8601 ?? ""),
            
            ],
            key: [Todo.DynamoDBField.id: DynamoDB.AttributeValue(s: todo.id)],
            returnValues: DynamoDB.ReturnValue.allNew,
            tableName: tableName,
            updateExpression: "SET #name = :name, #isCompleted = :isCompleted, #dueDate = :dueDate, #updatedAt = :updatedAt"
        )
        
        return db.updateItem(input).flatMap { (output)  in
            self.getTodo(id: todo.id)
         }
    }
    
    public func deleteTodo(id: String) -> EventLoopFuture<Void> {
        let input = DynamoDB.DeleteItemInput(
            key: [Todo.DynamoDBField.id: DynamoDB.AttributeValue(s: id)],
            tableName: tableName
        )
        
        return db.deleteItem(input).map { _ in }
    }
    
}
