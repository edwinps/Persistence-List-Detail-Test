//
//  CoreDataManagerTest.swift
//  CodeTestTests
//
//  Created by Edwin Peña on 2/11/22.
//

import Foundation
import XCTest
import Combine
import CoreData
@testable import CodeTest

class CoreDataManagerTest: XCTestCase {
    private var sut: CoreDataManager!
    private var disposables = Set<AnyCancellable>()
    private let mockMovies = MockMovies.moviesMock()

    override func setUp() {
        super.setUp()
        sut = CoreDataManager(inMemory: true)
    }

    override func tearDown() {
        removeAll()
        sut = nil
        super.tearDown()
    }

    func test_fetchAllMovies() {
        // Given
        addModel()
        let expectation = expectation(description: "movies")
        var result = [CDMovie]()

        // When
        sut.fetchAllMovies()
            .sink { value in
                result = value
                expectation.fulfill()
            }.store(in: &disposables)

        // Then
        waitForExpectations(timeout: 1.0, handler: nil)
        XCTAssertEqual(result.first?.id, mockMovies.first?.id)
    }

    func test_removeMovie() {
        // Given
        addModel()
        let expectationAdded = expectation(description: "added")
        let expectationRemoved = expectation(description: "removed")
        let expectationFetch = expectation(description: "movies")
        var result = [CDMovie]()

        // When
        sut.addOrRemove(mockMovies.last!)
            .sink { value in
                expectationAdded.fulfill()
            }.store(in: &disposables)

        sut.addOrRemove(mockMovies.first!)
            .sink { value in
                expectationRemoved.fulfill()
            }.store(in: &disposables)

        sut.fetchAllMovies()
            .sink { value in
                result = value
                expectationFetch.fulfill()
            }.store(in: &disposables)

        // Then
        waitForExpectations(timeout: 1.0, handler: nil)
        XCTAssertEqual(result.first?.id, mockMovies.last?.id)
        XCTAssertEqual(result.count, 1)
    }

    func test_savedMovie() {
        // Given
        addModel()
        let expectationAdded = expectation(description: "added")
        let expectationFetch = expectation(description: "movies")
        var result = [CDMovie]()

        // When
        sut.addOrRemove(mockMovies.last!)
            .sink { value in
                expectationAdded.fulfill()
            }.store(in: &disposables)

        sut.fetchAllMovies()
            .sink { value in
                result = value
                expectationFetch.fulfill()
            }.store(in: &disposables)

        // Then
        waitForExpectations(timeout: 1.0, handler: nil)
        XCTAssertEqual(result.count, 2)
        XCTAssertEqual(result.first?.id, mockMovies.first?.id)
        XCTAssertEqual(result.last?.id, mockMovies.last?.id)
    }

    private func addModel() {
        let context = sut.container.viewContext
        let cdMovie = CDMovie(context: context)
        cdMovie.set(from: mockMovies.first!)
        try? context.save()
    }

    private func removeAll() {
        let context = sut.container.viewContext
        let fetchRequest: NSFetchRequest<CDMovie> = CDMovie.fetchRequest()
        let result = try? context.fetch(fetchRequest)
        if let items = result {
            // remove movie from core data
            for object in items {
                context.delete(object)
            }
        }
        try? context.save()
    }
}


