//
//  MocksProtocoles.swift
//  CodeTestTests
//
//  Created by Edwin Peña on 9/10/22.
//

import Foundation
import XCTest
import Combine
@testable import CodeTest
import CoreData

class ImageLoaderServiceMock: ImageLoaderServiceProtocol {

    //MARK: - loadImage
    var loadImageFromCalled = false
    var loadImageFromReturnValue: AnyPublisher<Data?, Never>!
    var loadImageFromClosure: ((URL) -> AnyPublisher<Data?, Never>)?

    func loadImage(from url: URL) -> AnyPublisher<Data?, Never> {
        loadImageFromCalled = true
        return loadImageFromClosure.map({ $0(url) }) ?? loadImageFromReturnValue
    }
}

class CoordinatorMock: Coordinator {

    //MARK: - Coordinator
    var startCalled = false
    var moviesCalled = false
    var showDetailsForCalled = false
    var showDetailsForReturnValue: MovieViewModel!

    func start() {
        startCalled = true
    }

    func showDetails(for movie: MovieViewModel) {
        showDetailsForCalled = true
    }
}

class LoadImageUseCaseMock: LoadImageUseCaseProtocol {

    // MARK: - loadImage

    var loadImageForCalled = false
    var loadImageForReturnValue: AnyPublisher<Data?, Never>!

    func loadImage(for url: String?) -> AnyPublisher<Data?, Never> {
        loadImageForCalled = true
        return loadImageForReturnValue
    }

}

class moviesUseCaseMock: MoviesUseCaseProtocol {
    // MARK: - getMovies

    var getmoviesCalled = false
    var getmoviesReturnValue: AnyPublisher<Result<[Movie], Error>, Never>!

    func getMovies() -> AnyPublisher<Result<[CodeTest.Movie], Error>, Never> {
        getmoviesCalled = true
        return getmoviesReturnValue
    }

    var searchMoviesCalled = false
    var searchMoviesReturnValue: AnyPublisher<Result<[Movie], Error>, Never>!

    func searchMovies(query: String) -> AnyPublisher<Result<[Movie], Error>, Never>
    {
        searchMoviesCalled = true
        return searchMoviesReturnValue
    }

    // MARK: - getmovieDetails

    var getmovieDetailsWithCalled = false
    var getmovieDetailsWithReturnValue: AnyPublisher<Result<Movie, Error>, Never>!

    func getMoviesDetails(with id: String) -> AnyPublisher<Result<CodeTest.Movie, Error>, Never> {
        getmovieDetailsWithCalled = true
        return getmovieDetailsWithReturnValue
    }

    var addOrRemoveFavoritesCalled = false
    var addOrRemoveFavoritesReturnValue: AnyPublisher<Result<Void, Error>, Never>!

    func addOrRemoveFavorites(_ movie: Movie) -> AnyPublisher<Result<Void, Error>, Never> {
        addOrRemoveFavoritesCalled = true
        return addOrRemoveFavoritesReturnValue
    }
}

class NetworkServiceMock: NetworkServiceProtocol {
    var requestCalled = false
    var responses = [String: Any]()

    func request<T>(_ resource: Resource<T>) -> AnyPublisher<T, Error> {
        requestCalled = true
        if let response = responses[resource.url.path] as? T {
            return .just(response)
        } else if let error = responses[resource.url.path] as? NetworkError {
            return .fail(error)
        } else {
            return .fail(NetworkError.invalidRequest)
        }
    }
}

class RepositoryMock: MoviesRespositoryProtocol {
    var getMoviesCalled = false
    var getMoviesReturnValue: AnyPublisher<[Movie], Never>!

    func getMovies() -> AnyPublisher<[Movie], Never> {
        getMoviesCalled = true
        return getMoviesReturnValue
    }

    var searchMoviesCalled = false
    var searchMoviesReturnValue: AnyPublisher<Result<[Movie], Error>, Never>!

    func searchMovies(query: String) -> AnyPublisher<Result<[Movie], Error>, Never> {
        searchMoviesCalled = true
        return searchMoviesReturnValue
    }

    var getMoviesDetailsCalled = false
    var getMoviesDetailsReturnValue: AnyPublisher<Result<Movie, Error>, Never>!

    func getMoviesDetails(with id: String) -> AnyPublisher<Result<Movie, Error>, Never> {
        getMoviesDetailsCalled = true
        return getMoviesDetailsReturnValue
    }

    var addOrRemoveFavoritesCalled = false
    var addOrRemoveFavoritesReturnValue: AnyPublisher<Result<Void, Error>, Never>!

    func addOrRemoveFavorites(_ movie: Movie) -> AnyPublisher<Result<Void, Error>, Never> {
        addOrRemoveFavoritesCalled = true
        return addOrRemoveFavoritesReturnValue
    }

}


class CoreDataManagerMock: CoreDataManagerProtocol {
    var container = NSPersistentContainer(name: "Model")

    var fetchAllMoviesCalled = false
    var fetchAllMoviesReturnValue: AnyPublisher<[CDMovie], Never>!

    func fetchAllMovies() -> AnyPublisher<[CDMovie], Never> {
        fetchAllMoviesCalled = true
        return fetchAllMoviesReturnValue
    }

    var fetchMovieCalled = false
    var fetchMovieReturnValue: AnyPublisher<CDMovie, Never>!

    func fetchMovie(with id: String) -> AnyPublisher<CDMovie, Never> {
        fetchMovieCalled = true
        return fetchMovieReturnValue
    }

    var addOrRemoveCalled = false
    var addOrRemoveReturnValue: AnyPublisher<Result<Void, Error>, Never>!

    func addOrRemove(_ movie: Movie) -> AnyPublisher<Result<Void, Error>, Never> {
        addOrRemoveCalled = true
        return addOrRemoveReturnValue
    }
}
