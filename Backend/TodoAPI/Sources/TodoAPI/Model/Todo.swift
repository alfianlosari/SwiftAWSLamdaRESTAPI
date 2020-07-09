//
//  File.swift
//  
//
//  Created by Alfian Losari on 29/06/20.
//

import Foundation

public struct Todo: Codable {
    public let id: String
    public let name: String
    public let isCompleted: Bool
    public var dueDate: Date?
    public var createdAt: Date?
    public var updatedAt: Date?
    
    public struct DynamoDBField {
        static let id = "id"
        static let name = "name"
        static let isCompleted = "isCompleted"
        static let dueDate = "dueDate"
        static let createdAt = "createdAt"
        static let updatedAt = "updatedAt"
    }
}
