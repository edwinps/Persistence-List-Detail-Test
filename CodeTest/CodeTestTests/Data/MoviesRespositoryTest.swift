//
//  MoviesRespositoryTest.swift
//  CodeTestTests
//
//  Created by Edwin Peña on 2/11/22.
//

import Foundation
import XCTest
import Combine
@testable import CodeTest

class MoviesRespositoryTest: XCTestCase {
    private var sut: MoviesRespository!
    private var networkService: NetworkServiceMock!
    private var localDataSource: CoreDataManagerMock!
    private var disposables = Set<AnyCancellable>()

    override func setUp() {
        super.setUp()
        networkService = NetworkServiceMock()
        localDataSource = CoreDataManagerMock()
        sut = MoviesRespository(networkService: networkService,
                                localDataSource: localDataSource)
    }

    override func tearDown() {
        sut = nil
        networkService = nil
        localDataSource = nil
        super.tearDown()
    }

    func test_getmovies() {
        // Given
        var result: [Movie]!
        let expectation = expectation(description: "movies")
        let movies = CDMovie(context: localDataSource.container.viewContext)
        movies.set(from: MockMovies.movieMock())
        localDataSource.fetchAllMoviesReturnValue = .just([movies])

        // When
        sut.getMovies()
            .sink { value in
                result = value
                expectation.fulfill()
            }.store(in: &disposables)

        // Then
        waitForExpectations(timeout: 1.0, handler: nil)
        XCTAssert(localDataSource.fetchAllMoviesCalled)
        XCTAssertEqual(result.first?.id, MockMovies.movieMock().id)
    }

    func test_searchMovies_success() {
        // Given
        var result: Result<[Movie], Error>!
        let expectation = expectation(description: "Movie")
        let movies = MovieDTO.loadFromFile("Movie.json")
        networkService.responses[""] = movies

        // When
        sut.searchMovies(query: "id")
            .sink { value in
            result = value
            expectation.fulfill()
        }.store(in: &disposables)

        // Then
        waitForExpectations(timeout: 1.0, handler: nil)
        guard case .success = result! else {
            XCTFail()
            return
        }
        XCTAssert(networkService.requestCalled)
    }

    func test_searchMoviesFailes_onError() {
        // Given
        var result: Result<[Movie], Error>!
        let expectation = expectation(description: "Movies")
        networkService.responses[""] = NetworkError.invalidResponse

        // When
        sut.searchMovies(query: "id")
        .sink { value in
            result = value
            expectation.fulfill()
        }.store(in: &disposables)

        // Then
        waitForExpectations(timeout: 1.0, handler: nil)
        switch result! {
        case .failure(let error):
            guard let moviesError = error as? MoviesError,
               case .generic = moviesError else {
                XCTFail()
                return
            }
        default:
            XCTFail()
        }
        XCTAssert(networkService.requestCalled)
    }

    func test_searchMoviesFailes_onUnAuthorizedError() {
        // Given
        var result: Result<[Movie], Error>!
        let expectation = expectation(description: "Movies")
        networkService.responses[""] = NetworkError.unAuthorized

        // When
        sut.searchMovies(query: "id")
        .sink { value in
            result = value
            expectation.fulfill()
        }.store(in: &disposables)

        // Then
        waitForExpectations(timeout: 1.0, handler: nil)
        switch result! {
        case .failure(let error):
            guard let moviesError = error as? MoviesError,
               case .generic = moviesError else {
                XCTFail()
                return
            }
        default:
            XCTFail()
        }
        XCTAssert(networkService.requestCalled)
    }

    func test_getMovieDetails_Succeed() {
        // Given
        var result: Result<Movie, Error>!
        let expectation = expectation(description: "Movie")
        let movie = MovieDTO.loadFromFile("Movie.json")
        networkService.responses[""] = movie

        // When
        sut.getMoviesDetails(with: "id")
            .sink { value in
            result = value
            expectation.fulfill()
        }.store(in: &disposables)

        // Then
        waitForExpectations(timeout: 1.0, handler: nil)
        guard case .success = result! else {
            XCTFail()
            return
        }
        XCTAssert(networkService.requestCalled)
    }

    func test_getMovieDetails_onUnAuthorizedError() {
        // Given
        var result: Result<Movie, Error>!
        let expectation = expectation(description: "Movie")
        networkService.responses[""] = NetworkError.unAuthorized

        // When
        sut.getMoviesDetails(with: "id")
        .sink { value in
            result = value
            expectation.fulfill()
        }.store(in: &disposables)

        // Then
        waitForExpectations(timeout: 1.0, handler: nil)
        switch result! {
        case .failure(let error):
            guard let moviesError = error as? MoviesError,
               case .generic = moviesError else {
                XCTFail()
                return
            }
        default:
            XCTFail()
        }
        XCTAssert(networkService.requestCalled)
    }

    func test_getMovieDetails_onError() {
        // Given
        var result: Result<Movie, Error>!
        let expectation = expectation(description: "Movie")
        networkService.responses[""] = NetworkError.invalidResponse

        // When
        sut.getMoviesDetails(with: "id")
        .sink { value in
            result = value
            expectation.fulfill()
        }.store(in: &disposables)

        // Then
        waitForExpectations(timeout: 1.0, handler: nil)
        switch result! {
        case .failure(let error):
            guard let moviesError = error as? MoviesError,
               case .generic = moviesError else {
                XCTFail()
                return
            }
        default:
            XCTFail()
        }
        XCTAssert(networkService.requestCalled)
    }

    func test_savedMovie_success() {
        // Given
        var result: Result<Void, Error>!
        let expectation = expectation(description: "Movie")
        localDataSource.addOrRemoveReturnValue = .just(.success(()))
        let movie = MockMovies.movieMock()

        // When
        sut.addOrRemoveFavorites(movie)
            .sink { value in
            result = value
            expectation.fulfill()
        }.store(in: &disposables)

        // Then
        waitForExpectations(timeout: 1.0, handler: nil)
        guard case .success = result! else {
            XCTFail()
            return
        }
        XCTAssert(localDataSource.addOrRemoveCalled)
    }

    func test_savedMovieFailes_onError() {
        // Given
        var result: Result<Void, Error>!
        let expectation = expectation(description: "Movies")
        let movie = MockMovies.movieMock()
        localDataSource.addOrRemoveReturnValue = .just(.failure(MoviesError.errorSaving))

        // When
        sut.addOrRemoveFavorites(movie)
        .sink { value in
            result = value
            expectation.fulfill()
        }.store(in: &disposables)

        // Then
        waitForExpectations(timeout: 1.0, handler: nil)
        switch result! {
        case .failure(let error):
            guard let moviesError = error as? MoviesError,
               case .errorSaving = moviesError else {
                XCTFail()
                return
            }
        default:
            XCTFail()
        }
        XCTAssert(localDataSource.addOrRemoveCalled)
    }
}
