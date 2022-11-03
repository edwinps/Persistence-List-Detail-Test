//
//  ListViewModelTest.swift
//  CodeTestTests
//
//  Created by Edwin Peña on 9/10/22.
//

import Foundation
import XCTest
import Combine
@testable import CodeTest

class ListViewModelTest: XCTestCase {
    private var sut: ListViewModel!
    private var moviesUseCase: moviesUseCaseMock!
    private var loadImageUseCase: LoadImageUseCaseMock!
    private var coordinator: CoordinatorMock!
    private var disposables = Set<AnyCancellable>()

    override func setUp() {
        super.setUp()
        coordinator = CoordinatorMock()
        moviesUseCase = moviesUseCaseMock()
        loadImageUseCase = LoadImageUseCaseMock()
        sut = ListViewModel(coordinator: coordinator,
                            loadImageUseCase: loadImageUseCase,
                            moviesUseCase: moviesUseCase)
    }

    override func tearDown() {
        sut = nil
        coordinator = nil
        moviesUseCase = nil
        loadImageUseCase = nil
        super.tearDown()
    }

    private func createInput(
        didLoad: AnyPublisher<Void, Never> = .empty(),
        selection: AnyPublisher<MovieViewModel, Never> = .empty(),
        search: AnyPublisher<String, Never> = .empty(),
        addFavorites: AnyPublisher<MovieViewModel, Never> = .empty()
    )
        -> ListViewModel.Input
    {
        return ListViewModel
            .Input(didLoad: didLoad,
                   selection: selection,
                   search: search,
                   addFavorites: addFavorites)
    }

    func test_didLoad_getmoviesSuccess() {
        // Given
        let expectation = expectation(description: "list State")
        let trigger = PassthroughSubject<Void, Never>()
        let input = createInput(didLoad: trigger.eraseToAnyPublisher())
        let output = sut.transform(input: input)
        var actualsModel: ListState?
        let movies = MockMovies.moviesMock()
        let expectedViewModels = MockMovies.moviesViewModelMock()
        moviesUseCase.getmoviesReturnValue = .just(.success(movies))
        loadImageUseCase.loadImageForReturnValue = .just(Data())

        // When
        output.listState.sink { state in
            actualsModel = state
            expectation.fulfill()
        }.store(in: &disposables)

        trigger.send(())

        // Then
        waitForExpectations(timeout: 1.0, handler: nil)
        XCTAssertNotNil(actualsModel)
        XCTAssert(moviesUseCase.getmoviesCalled)
        XCTAssertEqual(actualsModel!, .success(expectedViewModels))
    }

    func test_didLoad_getmovies_hasErrorState() {
        // Given
        let expectation = expectation(description: "list State")
        let trigger = PassthroughSubject<Void, Never>()
        let input = createInput(didLoad: trigger.eraseToAnyPublisher())
        let output = sut.transform(input: input)
        var actualsModel: ListState?
        moviesUseCase.getmoviesReturnValue = .just(.failure(NetworkError.invalidResponse))

        // When
        output.listState.sink { state in
            actualsModel = state
            expectation.fulfill()
        }.store(in: &disposables)

        trigger.send(())

        // Then
        waitForExpectations(timeout: 1.0, handler: nil)
        XCTAssertNotNil(actualsModel)
        XCTAssert(moviesUseCase.getmoviesCalled)
        XCTAssertEqual(actualsModel!, .failure(NetworkError.invalidResponse))
    }


    func test_didLoad_getmovies_noResults() {
        // Given
        let expectation = expectation(description: "list State")
        let trigger = PassthroughSubject<Void, Never>()
        let input = createInput(didLoad: trigger.eraseToAnyPublisher())
        let output = sut.transform(input: input)
        var actualsModel: ListState?
        moviesUseCase.getmoviesReturnValue = .just(.success([]))

        // When
        output.listState.sink { state in
            actualsModel = state
            expectation.fulfill()
        }.store(in: &disposables)

        trigger.send(())

        // Then
        waitForExpectations(timeout: 1.0, handler: nil)
        XCTAssertNotNil(actualsModel)
        XCTAssert(moviesUseCase.getmoviesCalled)
        XCTAssertEqual(actualsModel!, .noResults)
    }

    func test_search_getmoviesSuccess() {
        // Given
        let expectation = expectation(description: "list State")
        let trigger = PassthroughSubject<String, Never>()
        let input = createInput(search: trigger.eraseToAnyPublisher())
        let output = sut.transform(input: input)
        var actualsModel: ListState?
        let movies = MockMovies.moviesMock()
        let expectedViewModels = MockMovies.moviesViewModelMock()
        moviesUseCase.searchMoviesReturnValue = .just(.success(movies))
        loadImageUseCase.loadImageForReturnValue = .just(Data())

        // When
        output.listState.sink { state in
            actualsModel = state
            expectation.fulfill()
        }.store(in: &disposables)

        trigger.send("harry")

        // Then
        waitForExpectations(timeout: 1.0, handler: nil)
        XCTAssertNotNil(actualsModel)
        XCTAssert(moviesUseCase.searchMoviesCalled)
        XCTAssertEqual(actualsModel!, .success(expectedViewModels))
    }

    func test_search_empty_getmoviesSuccess() {
        // Given
        let expectation = expectation(description: "list State")
        let trigger = PassthroughSubject<String, Never>()
        let input = createInput(search: trigger.eraseToAnyPublisher())
        let output = sut.transform(input: input)
        var actualsModel: ListState?
        let movies = MockMovies.moviesMock()
        let expectedViewModels = MockMovies.moviesViewModelMock()
        moviesUseCase.getmoviesReturnValue = .just(.success(movies))
        loadImageUseCase.loadImageForReturnValue = .just(Data())

        // When
        output.listState.sink { state in
            actualsModel = state
            expectation.fulfill()
        }.store(in: &disposables)

        trigger.send("")

        // Then
        waitForExpectations(timeout: 1.0, handler: nil)
        XCTAssertNotNil(actualsModel)
        XCTAssertFalse(moviesUseCase.searchMoviesCalled)
        XCTAssert(moviesUseCase.getmoviesCalled)
        XCTAssertEqual(actualsModel!, .success(expectedViewModels))
    }

    func test_search_getmovies_hasErrorState() {
        // Given
        let expectation = expectation(description: "list State")
        let trigger = PassthroughSubject<String, Never>()
        let input = createInput(search: trigger.eraseToAnyPublisher())
        let output = sut.transform(input: input)
        var actualsModel: ListState?
        moviesUseCase
            .searchMoviesReturnValue = .just(.failure(NetworkError.invalidResponse))

        // When
        output.listState.sink { state in
            actualsModel = state
            expectation.fulfill()
        }.store(in: &disposables)

        trigger.send("Harry")

        // Then
        waitForExpectations(timeout: 1.0, handler: nil)
        XCTAssertNotNil(actualsModel)
        XCTAssert(moviesUseCase.searchMoviesCalled)
        XCTAssertEqual(actualsModel!, .failure(NetworkError.invalidResponse))
    }


    func test_search_getmovies_noResults() {
        // Given
        let expectation = expectation(description: "list State")
        let trigger = PassthroughSubject<String, Never>()
        let input = createInput(search: trigger.eraseToAnyPublisher())
        let output = sut.transform(input: input)
        var actualsModel: ListState?
        moviesUseCase.searchMoviesReturnValue = .just(.failure(MoviesError.notFound))

        // When
        output.listState.sink { state in
            actualsModel = state
            expectation.fulfill()
        }.store(in: &disposables)

        trigger.send("harry")

        // Then
        waitForExpectations(timeout: 1.0, handler: nil)
        XCTAssertNotNil(actualsModel)
        XCTAssert(moviesUseCase.searchMoviesCalled)
        XCTAssertEqual(actualsModel!, .noResults)
    }

    func test_selectmovie_showDetail() {
        // Given
        let expectation = expectation(description: "show Detail")
        let trigger = PassthroughSubject<MovieViewModel, Never>()
        let input = createInput(selection: trigger.eraseToAnyPublisher())
        let output = sut.transform(input: input)
        let viewModel = MockMovies.movieViewModelMock()

        // When
        output.isLoading.sink { _ in
            expectation.fulfill()
        }.store(in: &disposables)

        trigger.send(viewModel)

        // Then
        waitForExpectations(timeout: 1.0, handler: nil)
        XCTAssert(coordinator.showDetailsForCalled)
    }

    func test_addFavorite_Success() {
        // Given
        let expectation = expectation(description: "list State")
        let trigger = PassthroughSubject<MovieViewModel, Never>()
        let input = createInput(addFavorites: trigger.eraseToAnyPublisher())
        let output = sut.transform(input: input)
        var actualsModel = false
        let model = MockMovies.movieViewModelMock()
        moviesUseCase
            .addOrRemoveFavoritesReturnValue = .just(.success(()))

        // When
        output.addOrRemoveFavorites.sink { added in
            actualsModel = added
            expectation.fulfill()
        }.store(in: &disposables)

        trigger.send(model)

        // Then
        waitForExpectations(timeout: 1.0, handler: nil)
        XCTAssertTrue(actualsModel)
        XCTAssert(moviesUseCase.addOrRemoveFavoritesCalled)
    }

    func test_addFavorite_hasErrorState() {
        // Given
        let expectation = expectation(description: "list State")
        let trigger = PassthroughSubject<MovieViewModel, Never>()
        let input = createInput(addFavorites: trigger.eraseToAnyPublisher())
        let output = sut.transform(input: input)
        var actualsModel = true
        let model = MockMovies.movieViewModelMock()
        moviesUseCase
            .addOrRemoveFavoritesReturnValue = .just(.failure(MoviesError.errorSaving))

        // When
        output.addOrRemoveFavorites.sink { added in
            actualsModel = added
            expectation.fulfill()
        }.store(in: &disposables)

        trigger.send(model)

        // Then
        waitForExpectations(timeout: 1.0, handler: nil)
        XCTAssertFalse(actualsModel)
        XCTAssert(moviesUseCase.addOrRemoveFavoritesCalled)
    }
}
