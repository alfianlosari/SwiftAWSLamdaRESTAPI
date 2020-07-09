//  Created by Alfian Losari on 02/07/20.
//

import Foundation
import AWSLambdaEvents

extension APIGateway.Request {
    
    private static let jsonDecoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .formatted(Utils.iso8601Formatter)
        return decoder
    }()
    
    func bodyObject<D: Decodable>() throws -> D {
        guard let jsonData = body?.data(using: .utf8) else {
            throw APIError.requestError
        }
        let object = try APIGateway.Request.jsonDecoder.decode(D.self, from: jsonData)
        return object
    }
}

extension APIGateway.Response {
    
    private static let jsonEncoder: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .formatted(Utils.iso8601Formatter)
        return encoder
    }()
    
    public static let defaultHeaders = [
        "Content-Type": "application/json",
        "Access-Control-Allow-Origin": "*",
        "Access-Control-Allow-Methods": "OPTIONS,GET,POST,PUT,DELETE",
        "Access-Control-Allow-Credentials": "true",
    ]
    
    public init(with error: Error, statusCode: AWSLambdaEvents.HTTPResponseStatus) {
        self.init(
            statusCode: statusCode,
            headers: APIGateway.Response.defaultHeaders,
            multiValueHeaders: nil,
            body: "{\"error\":\"\(String(describing: error))\"}",
            isBase64Encoded: false
        )
    }
    
    public init<Out: Encodable>(with object: Out, statusCode: AWSLambdaEvents.HTTPResponseStatus) {
        var body: String = "{}"
        if let data = try? Self.jsonEncoder.encode(object) {
            body = String(data: data, encoding: .utf8) ?? body
        }
        self.init(
            statusCode: statusCode,
            headers: APIGateway.Response.defaultHeaders,
            multiValueHeaders: nil,
            body: body,
            isBase64Encoded: false
        )
    }
}

struct EmptyResponse: Encodable {}
