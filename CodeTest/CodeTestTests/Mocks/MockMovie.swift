//
//  MockMovies.swift
//  CodeTestTests
//
//  Created by Edwin Peña on 9/10/22.
//

import Foundation
@testable import CodeTest

enum MockMovies {
    static func moviesMock() -> [Movie] {
        return moviesDTOMock().map { Movie(dto: $0 )}
    }

    static func movieMock() -> Movie {
        return Movie(dto: movieDTOMock()) 
    }

    static func moviesDTOMock() -> [MovieDTO] {
        return [MovieDTO].loadFromFile("Movies.json")
    }

    static func moviesViewModelMock() -> [MovieViewModel] {
        return moviesViewModelMock(moviesDTOMock())
    }

    static func movieDTOMock() -> MovieDTO {
        return MovieDTO.loadFromFile("Movie.json")
    }

    static func movieViewModelMock() -> MovieViewModel {
        return movieViewModelMock(movieDTOMock())
    }

    private static func moviesViewModelMock(_ movies: [MovieDTO]) -> [MovieViewModel]{
        return movies.map({ movie in
            MovieViewModel(id: movie.id,
                           title: movie.title,
                           imageData: .just(Data()),
                           imageUrl: movie.imageUrl,
                           summary: movie.description,
                           rating: movie.rating,
                           type: movie.type,
                           favorite: true)
        })
    }

    private static func movieViewModelMock(_ movie: MovieDTO) -> MovieViewModel {
        MovieViewModel(id: movie.id,
                       title: movie.title,
                       imageData: .just(Data()),
                       imageUrl: movie.imageUrl,
                       summary: movie.description,
                       rating: movie.rating,
                       type: movie.type,
                       favorite: true)
    }
}
