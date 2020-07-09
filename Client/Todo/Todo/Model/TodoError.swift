//
//  TodoError.swift
//  Todo
//
//  Created by Alfian Losari on 02/07/20.
//

import Foundation

enum TodoError: Error {
    case decodingError
    case invalidRequest
    case noConnection
    case importError
    case deleteError
}
