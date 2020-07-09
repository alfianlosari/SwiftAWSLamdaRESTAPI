//
//  File.swift
//  
//
//  Created by Alfian Losari on 29/06/20.
//

import Foundation

public struct Utils {    
    
    public static let iso8601Formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        return formatter
    }()
    
}

extension Date {
    
    var iso8601: String {
        Utils.iso8601Formatter.string(from: self)
    }
}
