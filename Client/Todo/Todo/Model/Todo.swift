//
//  Todo.swift
//  Todo
//
//  Created by Alfian Losari on 02/07/20.
//

import Foundation

extension Todo {
        
    func update(with todoDictionary: [String: Any]) throws {
        guard let newId = todoDictionary["id"] as? String,
              let newName = todoDictionary["name"] as? String,
              let newIsCompleted = todoDictionary["isCompleted"] as? Bool,
              let newDueDate = todoDictionary["dueDate"] as? Date,
              let newUpdatedAt = todoDictionary["updatedAt"] as? Date,
              let newCreatedAt = todoDictionary["createdAt"] as? Date else {
            throw TodoError.decodingError
        }
        
        id = newId
        name = newName
        isCompleted = newIsCompleted
        dueDate = newDueDate
        createdAt = newCreatedAt
        updatedAt = newUpdatedAt
    }
}

extension Todo: Identifiable {
    
    var formattedDueDateText: String {
        Utils.listDateFormatter.string(from: dueDate ?? Date())
    }
    
}

struct TodoProperties: Decodable {
    
    let id: String
    let name: String
    let isCompleted: Bool
    let dueDate: Date
    let createdAt: Date
    let updatedAt: Date
    
    var dictionary: [String: Any] {
        return [
            "id": id,
            "name": name,
            "isCompleted": isCompleted,
            "dueDate": dueDate,
            "createdAt": createdAt,
            "updatedAt": updatedAt
        ]
    }
    
    var uploadDictionary: [String: Any] {
        return [
            "id": id,
            "name": name,
            "isCompleted": isCompleted,
            "dueDate": Utils.iso8601Formatter.string(from: dueDate)
        ]
    }
    
    
}
