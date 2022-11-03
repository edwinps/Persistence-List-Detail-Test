//
//  ListViewModel.swift
//  CodeTest
//
//  Created by Edwin Peña on 8/10/22.
//

import Foundation
import Combine

enum ListState {
    case success([MovieViewModel])
    case noResults
    case failure(Error)
}
extension ListState: Equatable {
    static func == (lhs: ListState, rhs: ListState) -> Bool {
        switch (lhs, rhs) {
        case (.success(let lhsMovies),
            .success(let rhsMovies)): return lhsMovies == rhsMovies
        case (.noResults, .noResults): return true
        case (.failure, .failure): return true
        default: return false
        }
    }
}

final class ListViewModel {
    private weak var coordinator: Coordinator?
    private let loadImageUseCase: LoadImageUseCaseProtocol
    private let moviesUseCase: MoviesUseCaseProtocol

    init(coordinator: Coordinator,
         loadImageUseCase: LoadImageUseCaseProtocol,
         moviesUseCase: MoviesUseCaseProtocol) {
        self.coordinator = coordinator
        self.loadImageUseCase = loadImageUseCase
        self.moviesUseCase = moviesUseCase
    }
}

extension ListViewModel: ViewModelType {
    struct Input {
        /// called when a screen will Appear
        let didLoad: AnyPublisher<Void, Never>
        /// called when the user selected an item from the list
        let selection: AnyPublisher<MovieViewModel, Never>
        /// called when we search
        let search: AnyPublisher<String, Never>
        /// called when we add to favorites
        let addFavorites: AnyPublisher<MovieViewModel, Never>
    }

    struct Output {
        /// return the list of Movies
        let listState: AnyPublisher<ListState, Never>
        /// return the list of Movies
        let addOrRemoveFavorites: AnyPublisher<Bool, Never>
        /// send when it's doing the login
        let isLoading: AnyPublisher<Bool, Never>
    }

    func transform(input: Input) -> Output {
        let loading = PassthroughSubject<Bool, Never>()

        let localMovies = input.didLoad
            .flatMap { [weak self] _ in
                loading.send(true)
                return self?.moviesUseCase.getMovies() ?? .empty()
            }

        let showDetail = input.selection
            .map { [weak self] movie in
                self?.coordinator?.showDetails(for: movie)
            }

        let searchMovie = input.search
            .flatMap { [weak self] query in
                loading.send(true)
                if query.isEmpty {
                    return self?.moviesUseCase.getMovies() ?? .empty()
                }
                return self?.moviesUseCase
                    .searchMovies(query: query) ?? .empty()
            }

        let addOrRemoveFavorites = input.addFavorites
            .flatMap { [weak self] viewModel in
                let imageData = self?.loadImageUseCase
                    .loadImage(for: viewModel.imageUrl) ?? .just(nil)
                return imageData
                    .map { data in
                        (viewModel, data)
                    }
            }
            .flatMap { [weak self] viewModel, imageData -> AnyPublisher<Result<Void, Error>, Never> in
                let movie = Movie.init(viewModel: viewModel,
                                       data: imageData)
                return self?.moviesUseCase
                    .addOrRemoveFavorites(movie) ?? .empty()
            }
            .map { result in
                switch result {
                case .success:
                    return true
                case .failure:
                    return false
                }
            }.eraseToAnyPublisher()

        let listState = Publishers
            .Merge(localMovies,
                   searchMovie)
            .map { [weak self] result -> ListState in
                loading.send(false)
                return self?.mapListState(result) ?? .noResults
            }
            .eraseToAnyPublisher()

        let isLoading = Publishers
            .Merge(showDetail.map { _ in false},
                    loading)
            .eraseToAnyPublisher()

        return Output(listState: listState,
                      addOrRemoveFavorites: addOrRemoveFavorites,
                      isLoading: isLoading)
    }
}

// MARK: - Inner methods

private extension ListViewModel {
    func viewModels(from movies: [Movie]) -> [MovieViewModel] {
        return movies.map({ [weak self] movie in
            let imageData = self?.loadImageUseCase
                .loadImage(for: movie.imageUrl) ?? .just(nil)
            return MovieViewModel.init(with: movie,
                                       publisherImage: imageData)
        })
    }

    func mapListState(_ result: Result<[Movie], Error>) -> ListState {
        switch result {
        case .success(let movies) where movies.isEmpty:
            return .noResults
        case .success(let movies):
            return .success(self.viewModels(from: movies))
        case .failure(let error):
            if let moviesError = error as? MoviesError {
                switch moviesError {
                case .notFound:
                    return .noResults
                default:
                    break
                }
            }
            return .failure(error)
        }
    }
}

