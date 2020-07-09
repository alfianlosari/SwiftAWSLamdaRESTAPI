//
//  File.swift
//  
//
//  Created by Alfian Losari on 29/06/20.
//

import AWSDynamoDB
import Foundation

extension Todo {
    
    public var dynamoDbDictionary: [String: DynamoDB.AttributeValue] {
        var dictionary = [
            DynamoDBField.id: DynamoDB.AttributeValue(s: id),
            DynamoDBField.name: DynamoDB.AttributeValue(s: name),
            DynamoDBField.isCompleted: DynamoDB.AttributeValue(bool: isCompleted)
        ]
        
        if let dueDate = dueDate {
            dictionary[DynamoDBField.dueDate] = DynamoDB.AttributeValue(s: Utils.iso8601Formatter.string(from: dueDate))
        }
        
        if let createdAt = createdAt {
            dictionary[DynamoDBField.createdAt] = DynamoDB.AttributeValue(s: Utils.iso8601Formatter.string(from: createdAt))
        }
        
        if let updatedAt = updatedAt {
            dictionary[DynamoDBField.updatedAt] = DynamoDB.AttributeValue(s: Utils.iso8601Formatter.string(from: updatedAt))
        }
        
        return dictionary
    }
    
    public init(dictionary: [String: DynamoDB.AttributeValue]) throws {
        guard let id = dictionary[DynamoDBField.id]?.s,
            let name = dictionary[DynamoDBField.name]?.s,
            let isCompleted = dictionary[DynamoDBField.isCompleted]?.bool,
            let dueDateValue = dictionary[DynamoDBField.dueDate]?.s,
            let dueDate = Utils.iso8601Formatter.date(from: dueDateValue),
            let createdAtValue = dictionary[DynamoDBField.createdAt]?.s,
            let createdAt = Utils.iso8601Formatter.date(from: createdAtValue),
            let updatedAtValue = dictionary[DynamoDBField.updatedAt]?.s,
            let updatedAt = Utils.iso8601Formatter.date(from: updatedAtValue) else {
                throw APIError.decodingError
        }

        self.id = id
        self.name = name
        self.isCompleted = isCompleted
        self.dueDate = dueDate
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
    
}

