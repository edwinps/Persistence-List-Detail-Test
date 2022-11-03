//
//  NetworkServiceTests.swift
//  CodeTestTests
//
//  Created by Edwin Peña on 9/10/22.
//

import Foundation
import XCTest
import Combine
@testable import CodeTest

class NetworkServiceTests: XCTestCase {

    private lazy var session: URLSession = {
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [URLProtocolMock.self]
        return URLSession(configuration: config)
    }()
    private lazy var networkService = NetworkService(session: session)
    private let resource = Resource<MovieDTO>.movies(query: "test")
    private lazy var moviesJsonData: Data = {
        let url = Bundle(for: NetworkServiceTests.self).url(forResource: "Movie",
                                                            withExtension: "json")
        guard let resourceUrl = url,
              let data = try? Data(contentsOf: resourceUrl) else {
            XCTFail("Failed to create data object from string!")
            return Data()
        }
        return data
    }()
    private var cancellables: [AnyCancellable] = []

    override func setUp() {
        URLProtocol.registerClass(URLProtocolMock.self)
    }

    func test_loadFinishedSuccessfully() {
        // Given
        var result: Result<[MovieDTO], Error>?
        let expectation = expectation(description: "networkServiceExpectation")
        URLProtocolMock.requestHandler = { request in
            let response = HTTPURLResponse(url: self.resource.url, statusCode: 200,
                                           httpVersion: nil, headerFields: nil)!
            return (response, self.moviesJsonData)
        }

        // When
        networkService.request(resource)
            .map({ movies -> Result<[MovieDTO], Error> in Result.success([movies])})
            .catch({ error -> AnyPublisher<Result<[MovieDTO], Error>, Never> in .just(.failure(error)) })
                .sink(receiveValue: { value in
                    result = value
                    expectation.fulfill()
                }).store(in: &cancellables)
                    // Then
                    waitForExpectations(timeout: 1.0, handler: nil)
                    guard case .success(let movies) = result else {
                XCTFail()
                return
            }
        XCTAssertEqual(movies.count, 1)
    }

    func test_loadFailedWithInternalError() {
        // Given
        var result: Result<[MovieDTO], Error>?
        let expectation = expectation(description: "networkServiceExpectation")
        URLProtocolMock.requestHandler = { request in
            let response = HTTPURLResponse(url: self.resource.url,
                                           statusCode: 500,
                                           httpVersion: nil,
                                           headerFields: nil)!
            return (response, Data())
        }

        // When
        networkService.request(resource)
            .map({ movies -> Result<[MovieDTO], Error> in Result.success([movies])})
            .catch({ error -> AnyPublisher<Result<[MovieDTO], Error>, Never> in .just(.failure(error)) })
                .sink(receiveValue: { value in
                    result = value
                    expectation.fulfill()
                }).store(in: &cancellables)

                    // Then
                    waitForExpectations(timeout: 1.0, handler: nil)
                    guard case .failure(let error) = result,
                  let networkError = error as? NetworkError,
                  case NetworkError.dataLoadingError(500, _) = networkError else {
                XCTFail()
                return
            }
    }

    func test_loadFailedWithJsonParsingError() {
        // Given
        var result: Result<[MovieDTO], Error>?
        let expectation = expectation(description: "networkServiceExpectation")
        URLProtocolMock.requestHandler = { request in
            let response = HTTPURLResponse(url: self.resource.url,
                                           statusCode: 200,
                                           httpVersion: nil,
                                           headerFields: nil)!
            return (response, Data())
        }

        // When
        networkService.request(resource)
            .map({ movies -> Result<[MovieDTO], Error> in Result.success([movies])})
            .catch({ error -> AnyPublisher<Result<[MovieDTO], Error>, Never> in .just(.failure(error)) })
                .sink(receiveValue: { value in
                    result = value
                    expectation.fulfill()
                }).store(in: &cancellables)

                    // Then
                    waitForExpectations(timeout: 1.0, handler: nil)
                    guard case .failure(let error) = result,
                  let networkError = error as? NetworkError,
                  case NetworkError.parsingError = networkError else {
                XCTFail()
                return
            }
    }

    func test_loadFailedWithUnAuthorizedError() {
        // Given
        var result: Result<[MovieDTO], Error>?
        let expectation = expectation(description: "networkServiceExpectation")
        URLProtocolMock.requestHandler = { request in
            let response = HTTPURLResponse(url: self.resource.url,
                                           statusCode: 401,
                                           httpVersion: nil,
                                           headerFields: nil)!
            return (response, Data())
        }

        // When
        networkService.request(resource)
            .map({ movies -> Result<[MovieDTO], Error> in Result.success([movies])})
            .catch({ error -> AnyPublisher<Result<[MovieDTO], Error>, Never> in .just(.failure(error)) })
                .sink(receiveValue: { value in
                    result = value
                    expectation.fulfill()
                }).store(in: &cancellables)

                    // Then
                    waitForExpectations(timeout: 1.0, handler: nil)
                    guard case .failure(let error) = result,
                  let networkError = error as? NetworkError,
                  case NetworkError.unAuthorized = networkError else {
                XCTFail()
                return
            }
    }
}
