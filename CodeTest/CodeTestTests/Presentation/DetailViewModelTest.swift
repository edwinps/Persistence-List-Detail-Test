//
//  DetailViewModelTest.swift
//  CodeTestTests
//
//  Created by Edwin Peña on 9/10/22.
//

import Foundation
import XCTest
import Combine
@testable import CodeTest

class DetailViewModelTest: XCTestCase {
    private var sut: DetailViewModel!
    private var loadImageUseCase: LoadImageUseCaseMock!
    private var moviesUseCase: moviesUseCaseMock!
    private var coordinator: CoordinatorMock!
    private var disposables = Set<AnyCancellable>()
    private let movie: Movie = MockMovies.movieMock()

    override func setUp() {
        super.setUp()
        coordinator = CoordinatorMock()
        loadImageUseCase = LoadImageUseCaseMock()
        moviesUseCase = moviesUseCaseMock()
        sut = DetailViewModel(coordinator: coordinator,
                              loadImageUseCase: loadImageUseCase,
                              moviesUseCase: moviesUseCase,
                              movie: MockMovies.movieViewModelMock())
    }

    override func tearDown() {
        sut = nil
        coordinator = nil
        loadImageUseCase = nil
        moviesUseCase = nil
        super.tearDown()
    }

    private func createInput(
        willAppear: AnyPublisher<Void, Never> = .empty()
    )
        -> DetailViewModel.Input
    {
        return DetailViewModel
            .Input(willAppear: willAppear)
    }

    func test_viewWillAppear_returnViewModel() {
        // Given
        let expectation = expectation(description: "Detail ViewModel")
        let trigger = PassthroughSubject<Void, Never>()
        let input = createInput(willAppear: trigger.eraseToAnyPublisher())
        let output = sut.transform(input: input)
        var actualsModel: DetailState?
        let movie = MockMovies.movieMock()
        let expectedViewModel = MockMovies.movieViewModelMock()
        loadImageUseCase.loadImageForReturnValue = .just(Data())
        moviesUseCase.getmovieDetailsWithReturnValue = .just(.success(movie))

        // When
        output.detailState
            .removeDuplicates()
            .sink { state in
            actualsModel = state
            expectation.fulfill()
        }.store(in: &disposables)

        trigger.send(())

        // Then
        waitForExpectations(timeout: 1.0, handler: nil)
        XCTAssertNotNil(actualsModel)
        XCTAssert(loadImageUseCase.loadImageForCalled)
        XCTAssert(moviesUseCase.getmovieDetailsWithCalled)
        XCTAssertEqual(actualsModel!, .success(expectedViewModel))
    }

    func test_viewWillAppear_getmovie_onError() {
        // Given
        let expectation = expectation(description: "Detail ViewModel")
        let trigger = PassthroughSubject<Void, Never>()
        let input = createInput(willAppear: trigger.eraseToAnyPublisher())
        let output = sut.transform(input: input)
        var actualsModel: DetailState?
        moviesUseCase.getmovieDetailsWithReturnValue = .just(.failure(NetworkError.invalidResponse))

        // When
        output.detailState
            .drop(while: { state in
                if case .success = state {
                    return true
                }
                return false
            })
            .first()
            .sink { state in
            actualsModel = state
            expectation.fulfill()
        }.store(in: &disposables)

        trigger.send(())

        // Then
        waitForExpectations(timeout: 1.0, handler: nil)
        XCTAssertNotNil(actualsModel)
        XCTAssert(moviesUseCase.getmovieDetailsWithCalled)
        XCTAssertEqual(actualsModel!, .failure(NetworkError.invalidResponse))
    }
}


