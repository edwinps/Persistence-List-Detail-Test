//
//  DetailViewControllerTest.swift
//  CodeTestTests
//
//  Created by Edwin Peña on 9/10/22.
//

import Foundation
import XCTest
@testable import CodeTest

class DetailViewControllerTest: XCTestCase {
    // MARK: - System Under Test
    private var loadImageUseCase: LoadImageUseCaseMock!
    private var moviesUseCase: moviesUseCaseMock!
    private var coordinator: CoordinatorMock!
    private var sut: DetailViewController!

    // MARK: Mocks
    private var mockViewModel: DetailViewModel!

    // MARK: Tests Methods

    override func setUp() {
        super.setUp()
        coordinator = CoordinatorMock()
        loadImageUseCase = LoadImageUseCaseMock()
        moviesUseCase = moviesUseCaseMock()
        let movie = Movie(id: "id",
                          title: "title",
                          imageUrl: "",
                          imageData: nil,
                          description: "summary",
                          rating: "9.2",
                          type: "movie",
                          favorite: false)
        let movieVM = MovieViewModel(id: "id",
                                     title: "title",
                                     imageData: .just(Data()),
                                     imageUrl: "",
                                     summary: "summary",
                                     rating: "9.2",
                                     type: "movie",
                                     favorite: false)
        moviesUseCase.getmovieDetailsWithReturnValue = .just(.success(movie))
        loadImageUseCase.loadImageForReturnValue = .just(Data())
        mockViewModel = DetailViewModel(coordinator: coordinator,
                                        loadImageUseCase: loadImageUseCase,
                                        moviesUseCase: moviesUseCase,
                                        movie: movieVM)
        sut = DetailViewController(viewModel: mockViewModel)
    }

    override func tearDown() {
        sut = nil
        mockViewModel = nil
        super.tearDown()
    }

    func test_afterViewDidLoad() {
        let window = UIWindow()
        loadView(window)
    }

    func loadView(_ window: UIWindow) {
        window.addSubview(sut.view)
        RunLoop.current.run(until: Date())
    }
}
