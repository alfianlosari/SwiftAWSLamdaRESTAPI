//
//  File.swift
//  
//
//  Created by Alfian Losari on 02/07/20.
//

import AWSLambdaRuntime

enum Handler: String {
    
    case create
    case update
    case delete
    case read
    case list
    
    static var current: Handler? {
        guard let handler = Lambda.env("_HANDLER") else {
            return nil
        }
        return Handler(rawValue: handler)
    }
}
