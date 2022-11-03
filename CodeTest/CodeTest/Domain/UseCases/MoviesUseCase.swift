//
//  MoviesUseCase.swift
//  CodeTest
//
//  Created by Edwin Peña on 7/10/22.
//

import Foundation
import Combine


protocol MoviesUseCaseProtocol {
    /// get movies
    func getMovies() -> AnyPublisher<Result<[Movie], Error>, Never>

    /// seach movies
    func searchMovies(query: String) -> AnyPublisher<Result<[Movie], Error>, Never>

    /// Fetches details for movie with specified id
    func getMoviesDetails(with id: String) -> AnyPublisher<Result<Movie, Error>, Never>

    /// add Movie to favorites
    func addOrRemoveFavorites(_ movie: Movie) -> AnyPublisher<Result<Void, Error>, Never>
}

final class MoviesUseCase: MoviesUseCaseProtocol {
    private let repository: MoviesRespositoryProtocol

    init(repository: MoviesRespositoryProtocol) {
        self.repository = repository
    }

    func getMovies() -> AnyPublisher<Result<[Movie], Error>, Never> {
        repository.getMovies()
            .map { .success($0) }
            .eraseToAnyPublisher()
    }

    func searchMovies(query: String) -> AnyPublisher<Result<[Movie], Error>, Never> {
        repository.searchMovies(query: query)
    }

    func getMoviesDetails(with id: String) -> AnyPublisher<Result<Movie, Error>, Never> {
        repository.getMoviesDetails(with: id)
    }

    func addOrRemoveFavorites(_ movie: Movie) -> AnyPublisher<Result<Void, Error>, Never> {
        repository.addOrRemoveFavorites(movie)
    }
}

