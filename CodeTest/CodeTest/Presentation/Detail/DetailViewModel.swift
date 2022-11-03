//
//  DetailViewModel.swift
//  CodeTest
//
//  Created by Edwin Peña on 8/10/22.
//

import Foundation
import Combine

enum DetailState {
    case success(MovieViewModel)
    case failure(Error)
}

extension DetailState: Equatable {
    static func == (lhs: DetailState, rhs: DetailState) -> Bool {
        switch (lhs, rhs) {
        case (.success(let lhsMovie),
            .success(let rhsMovie)): return lhsMovie == rhsMovie
        case (.failure, .failure): return true
        default: return false
        }
    }
}

final class DetailViewModel {
    private weak var coordinator: Coordinator?
    private let loadImageUseCase: LoadImageUseCaseProtocol
    private let moviesUseCase: MoviesUseCaseProtocol
    private let movie: MovieViewModel

    init(coordinator: Coordinator,
         loadImageUseCase: LoadImageUseCaseProtocol,
         moviesUseCase: MoviesUseCaseProtocol,
         movie: MovieViewModel) {
        self.coordinator = coordinator
        self.loadImageUseCase = loadImageUseCase
        self.moviesUseCase = moviesUseCase
        self.movie = movie
    }
}

extension DetailViewModel: ViewModelType {
    struct Input {
        /// called when a screen will Appear
        let willAppear: AnyPublisher<Void, Never>
    }

    struct Output {
        /// return movie
        let detailState: AnyPublisher<DetailState, Never>
    }

    func transform(input: Input) -> Output {

        let details = input.willAppear
            .flatMap { [weak self] _ -> AnyPublisher<Result<Movie, Error>, Never> in
                guard let self = self else {
                    return .empty()
                }
                return self.moviesUseCase
                    .getMoviesDetails(with: self.movie.id)
            }
            .map { [weak self] result -> DetailState? in
                guard let self = self else {
                    return nil
                }
                switch result {
                case .success(let movie):
                    return .success(self.viewModel(from: movie))
                case .failure(let error):
                    return .failure(error)
                }
            }
            .compactMap { $0 }
            .eraseToAnyPublisher()

        let initModel = input.willAppear
            .map { [weak self] _  -> DetailState? in
                guard let self = self else {
                    return nil
                }
                return .success(self.movie)
            }
            .compactMap { $0 }
            .eraseToAnyPublisher()

        let detailState = Publishers
            .Merge(initModel,
                   details)
            .eraseToAnyPublisher()

        return Output(detailState: detailState)
    }
}

// MARK: - Inner methods

private extension DetailViewModel {
    private func viewModel(from movie: Movie) -> MovieViewModel {
        let imageData = self.loadImageUseCase
            .loadImage(for: movie.imageUrl)
        return MovieViewModel.init(with: movie,
                                   publisherImage: imageData)
    }
}
