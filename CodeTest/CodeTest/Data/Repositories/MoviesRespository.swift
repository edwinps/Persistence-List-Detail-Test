//
//  MoviesRespository.swift
//  CodeTest
//
//  Created by Edwin Peña on 1/11/22.
//

import Foundation
import Combine
import CoreData

class MoviesRespository: MoviesRespositoryProtocol {
    private let networkService: NetworkServiceProtocol
    private let localDataSource: CoreDataManagerProtocol

    init(networkService: NetworkServiceProtocol,
         localDataSource: CoreDataManagerProtocol) {
        self.networkService = networkService
        self.localDataSource = localDataSource
    }
    
    func getMovies() -> AnyPublisher<[Movie], Never> {
        return localDataSource.fetchAllMovies()
            .map { result in
                result.map { Movie(with: $0)}
            }
            .eraseToAnyPublisher()
    }

    func searchMovies(query: String) -> AnyPublisher<Result<[Movie], Error>, Never> {
        return networkService
            .request(Resource<MovieDTO>.movies(query: query))
            .map { Movie.init(dto: $0) }
            .map { .success([$0]) }
            .catch { [weak self] error -> AnyPublisher<Result<[Movie], Error>, Never> in
                    .just(
                        .failure(self?.handleError(error: error) ?? MoviesError.generic)
                    )
            }
            .subscribe(on: Scheduler.backgroundWorkScheduler)
            .receive(on: Scheduler.mainScheduler)
            .eraseToAnyPublisher()
    }

    func getMoviesDetails(with id: String) -> AnyPublisher<Result<Movie, Error>, Never> {
        return networkService
            .request(Resource<MovieDTO>.details(id: id))
            .map { Movie.init(dto: $0) }
            .map { .success($0) }
            .catch { [weak self] error -> AnyPublisher<Result<Movie, Error>, Never> in
                    .just(
                        .failure(self?.handleError(error: error) ?? MoviesError.generic)
                    )
            }
            .subscribe(on: Scheduler.backgroundWorkScheduler)
            .receive(on: Scheduler.mainScheduler)
            .eraseToAnyPublisher()
    }

    func addOrRemoveFavorites(_ movie: Movie) -> AnyPublisher<Result<Void, Error>, Never> {
        return localDataSource.addOrRemove(movie)
    }
}

// MARK: - Inner methods

private extension MoviesRespository {
    func handleError(error: Error) -> MoviesError {
        guard let networkError = error as? NetworkError else {
            return MoviesError.notConnection
        }
        guard case .notFound = networkError else {
            return MoviesError.generic
        }
        return MoviesError.notFound
    }
}

extension CDMovie {
     func set(from movie: Movie) {
         id = movie.id
         title = movie.title
         summary = movie.description
         imageData = movie.imageData
         imageUrl = movie.imageUrl
         rating = movie.rating
         type = movie.type
         favorite = true
    }
}

private extension Movie {
    init(with cdMovie: CDMovie) {
        id = cdMovie.id
        title = cdMovie.title
        imageUrl = cdMovie.imageUrl
        imageData = cdMovie.imageData
        description = cdMovie.summary
        rating = cdMovie.rating
        type = cdMovie.type
        favorite = cdMovie.favorite
    }
}
