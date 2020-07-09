# Swift Todo REST API with AWS Lambda

![Alt text](./promo.jpeg?raw=true "Swift Todo REST API with AWS Lambda")

Source code for Tutorial on building a Swift REST API to perform CRUD operations for Todo Items, learn how to persist data to AWS DynamoDB using AWS Swift SDK, handle events using Swift AWS Lambda Runtime library, and deploy to AWS Lambda using Serverless framework.

## Tutorial Video
Youtube link at https://youtu.be/HHg3fVfpj6M

## Backend App Requirement
- Xcode 11.5 
- AWS Credentials to provision resources
- Serverless Framework for deployment. https://www.serverless.com
- Docker for build and packaging. https://www.docker.com/products/docker-desktop

## Getting Started - Backend
- Copy and Clone the project
- Create the container using Dockerfile
- Build the project in release mode using the docker container
- Run the script inside scripts/package.sh to package the app into Lambda.zip inside the build folder
- Update the serverless by providing your own unique service, dynamo db table
- Deploy using sls -v deploy

## Backend Endpoints
- List Todos: /todos (GET)
- Read Todo: /todos/{id} (GET)
```
// Response JSON Body
{
"id": "String",
"name": "String",
"isCompleted": "Boolean",
"dueDate": "ISO8601 formatted String",
"createdAt": "ISO8601 formatted String",
"updatedAt": "ISO8601 formatted String"
}
```
- Create Todo: /todos (POST)
```
// Request JSON Body
{
"id": "String",
"name": "String",
"isCompleted": "Boolean",
"dueDate": "ISO8601 formatted String"
}
```
- Update Todo: /todos/{id} (PUT)
```
// Request JSON Body
{
"name": "String",
"isCompleted": "Boolean",
"dueDate": "ISO8601 formatted String"
}
```
- Delete Todo: /todos/{id} (DELETE)


## Front end App Requirement
- Xcode 12

## Getting Started - Frontend
- Paste the endpoint url from backend deployment into TodoProvider.swift
