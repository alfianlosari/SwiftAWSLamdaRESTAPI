//
//  File.swift
//  
//
//  Created by Alfian Losari on 02/07/20.
//

import Foundation
import AWSLambdaEvents
import AWSLambdaRuntime
import AsyncHTTPClient
import NIO
import SotoDynamoDB

struct TodoLamdaHandler: EventLoopLambdaHandler {
    
    typealias In = APIGateway.Request
    typealias Out = APIGateway.Response
    
    let db: SotoDynamoDB.DynamoDB
    let todoService: TodoService
    let httpClient: HTTPClient
    
    init(context: Lambda.InitializationContext) throws {
        let timeout = HTTPClient.Configuration.Timeout(
            connect: .seconds(30),
            read: .seconds(30)
        )
        
        let httpClient = HTTPClient(
            eventLoopGroupProvider: .shared(context.eventLoop),
            configuration: HTTPClient.Configuration(timeout: timeout)
        )
        
        let tableName = Lambda.env("TODOS_TABLE_NAME") ?? ""

        let db = SotoDynamoDB.DynamoDB(client: AWSClient(httpClientProvider: .shared(httpClient)))
        let todoService = TodoService(db: db, tableName: tableName)
        
        self.httpClient = httpClient
        self.db = db
        self.todoService = todoService
    }
    
    func handle(context: Lambda.Context, event: APIGateway.Request) -> EventLoopFuture<APIGateway.Response> {
        guard let handler = Handler.current else {
            return context.eventLoop.makeSucceededFuture(APIGateway.Response(with: APIError.requestError, statusCode: .badRequest))
        }
        
        switch handler {
        case .create:
            return handleCreate(context: context, event: event)
        case .read:
            return handleRead(context: context, event: event)
        case .update:
            return handleUpdate(context: context, event: event)
        case .delete:
            return handleDelete(context: context, event: event)
        case .list:
            return handleList(context: context, event: event)
        }
    }
    
    func handleCreate(context: Lambda.Context, event: APIGateway.Request) -> EventLoopFuture<APIGateway.Response> {
        guard let newTodo: Todo = try? event.bodyObject() else {
            return context.eventLoop.makeSucceededFuture(APIGateway.Response(with: APIError.requestError, statusCode: .badRequest))
        }
        return todoService.createTodo(todo: newTodo)
            .map { todo in
                APIGateway.Response(with: todo, statusCode: .ok)
            }.flatMapError {
                self.catchError(context: context, error: $0)
            }
    }
    
    func handleRead(context: Lambda.Context, event: APIGateway.Request) -> EventLoopFuture<APIGateway.Response> {
        guard let id = event.pathParameters?[Todo.DynamoDBField.id] else {
            return context.eventLoop.makeSucceededFuture(APIGateway.Response(with: APIError.requestError, statusCode: .notFound))
        }
        return todoService.getTodo(id: id)
            .map { todo in
                APIGateway.Response(with: todo, statusCode: .ok)
            }.flatMapError {
                self.catchError(context: context, error: $0)
            }
    }
    
    func handleUpdate(context: Lambda.Context, event: APIGateway.Request) -> EventLoopFuture<APIGateway.Response> {
        guard let updatedTodo: Todo = try? event.bodyObject() else {
            return context.eventLoop.makeSucceededFuture(APIGateway.Response(with: APIError.requestError, statusCode: .badRequest))
        }
        return todoService.updateTodo(todo: updatedTodo)
            .map { todo in
                APIGateway.Response(with: todo, statusCode: .ok)
            }.flatMapError {
                self.catchError(context: context, error: $0)
            }
    }
    
    func handleDelete(context: Lambda.Context, event: APIGateway.Request) -> EventLoopFuture<APIGateway.Response> {
        guard let id = event.pathParameters?[Todo.DynamoDBField.id] else {
            return context.eventLoop.makeSucceededFuture(APIGateway.Response(with: APIError.requestError, statusCode: .badRequest))
        }
        return todoService.deleteTodo(id: id)
            .map {
                APIGateway.Response(with: EmptyResponse(), statusCode: .ok)
            }.flatMapError {
                self.catchError(context: context, error: $0)
            }
    }
    
func handleList(context: Lambda.Context, event: APIGateway.Request) -> EventLoopFuture<APIGateway.Response> {
    return todoService.getAllTodos()
        .map { todos in
            APIGateway.Response(with: todos, statusCode: .ok)
        }.flatMapError {
            self.catchError(context: context, error: $0)
        }
}
    
    func catchError(context: Lambda.Context, error: Error) -> EventLoopFuture<APIGateway.Response> {
        let response = APIGateway.Response(with: error, statusCode: .notFound)
        return context.eventLoop.makeSucceededFuture(response)
    }
}
