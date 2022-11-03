//
//  moviesUseCaseTest.swift
//  CodeTestTests
//
//  Created by Edwin Peña on 9/10/22.
//

import Foundation
import XCTest
import Combine
@testable import CodeTest

class moviesUseCaseTest: XCTestCase {
    private var sut: MoviesUseCase!
    private var repositoryMock: RepositoryMock!
    private var disposables = Set<AnyCancellable>()

    override func setUp() {
        super.setUp()
        repositoryMock = RepositoryMock()
        sut = MoviesUseCase(repository: repositoryMock)
    }

    override func tearDown() {
        sut = nil
        repositoryMock = nil
        super.tearDown()
    }

    func test_getmovies_success() {
        // Given
        var result: Result<[Movie], Error>!
        let expectation = expectation(description: "movies")
        let movies = MockMovies.moviesMock()
        repositoryMock.getMoviesReturnValue = .just(movies)

        // When
        sut.getMovies()
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
        XCTAssert(repositoryMock.getMoviesCalled)
    }

    func test_searchMovies_success() {
        // Given
        var result: Result<[Movie], Error>!
        let expectation = expectation(description: "movies")
        let movies = MockMovies.moviesMock()
        repositoryMock.searchMoviesReturnValue = .just(.success(movies))

        // When
        sut.searchMovies(query: "")
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
        XCTAssert(repositoryMock.searchMoviesCalled)
    }

    func test_searchMovies_onError() {
        // Given
        var result: Result<[Movie], Error>!
        let expectation = expectation(description: "movies")
        repositoryMock.searchMoviesReturnValue = .just(.failure(MoviesError.generic))

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
        XCTAssert(repositoryMock.searchMoviesCalled)
    }

    func test_getmovieDetails_Succeed() {
        // Given
        var result: Result<Movie, Error>!
        let expectation = expectation(description: "movie")
        let movie = MockMovies.movieMock()
        repositoryMock.getMoviesDetailsReturnValue = .just(.success(movie))

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
        XCTAssert(repositoryMock.getMoviesDetailsCalled)
    }

    func test_getmovieDetails_onError() {
        // Given
        var result: Result<Movie, Error>!
        let expectation = expectation(description: "movie")
        repositoryMock.getMoviesDetailsReturnValue = .just(.failure(MoviesError.generic))

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
        XCTAssert(repositoryMock.getMoviesDetailsCalled)
    }

    func test_addFavorites_Succeed() {
        // Given
        var result: Result<Void, Error>!
        let expectation = expectation(description: "movie")
        let movie = MockMovies.movieMock()
        repositoryMock.addOrRemoveFavoritesReturnValue = .just(.success(()))

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
        XCTAssert(repositoryMock.addOrRemoveFavoritesCalled)
    }

    func test_addFavorites_onError() {
        // Given
        var result: Result<Void, Error>!
        let expectation = expectation(description: "movie")
        let movie = MockMovies.movieMock()
        repositoryMock
            .addOrRemoveFavoritesReturnValue = .just(.failure(MoviesError.errorSaving))

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
        XCTAssert(repositoryMock.addOrRemoveFavoritesCalled)
    }
}
