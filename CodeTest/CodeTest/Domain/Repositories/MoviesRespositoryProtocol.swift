//
//  MoviesRespositoryProtocol.swift
//  CodeTest
//
//  Created by Edwin Peña on 1/11/22.
//

import Foundation
import Combine

enum MoviesError: Error {
    case generic
    case notConnection
    case notFound
    case errorSaving
}

protocol MoviesRespositoryProtocol {
    /// get movies
    func getMovies() -> AnyPublisher<[Movie], Never>

    /// seach movies
    func searchMovies(query: String) -> AnyPublisher<Result<[Movie], Error>, Never>
    
    /// Fetches details for movie with specified id
    func getMoviesDetails(with id: String) -> AnyPublisher<Result<Movie, Error>, Never>

    /// add Movie to favorites
    func addOrRemoveFavorites(_ movie: Movie) -> AnyPublisher<Result<Void, Error>, Never>
}
