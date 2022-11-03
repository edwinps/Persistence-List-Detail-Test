//
//  MovieViewModel.swift
//  CodeTest
//
//  Created by Edwin Peña on 8/10/22.
//

import Foundation
import Combine

struct MovieViewModel {
    let id: String
    let title: String?
    let imageData: AnyPublisher<Data?, Never>
    let imageUrl: String?
    let summary: String?
    let rating: String?
    let type: String?
    let favorite: Bool
}

extension MovieViewModel: Hashable {
    static func == (lhs: MovieViewModel, rhs: MovieViewModel) -> Bool {
        return lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

extension MovieViewModel {
    init(with movie: Movie, publisherImage: AnyPublisher<Data?, Never>) {
        id = movie.id
        title = movie.title
        imageData = publisherImage
        imageUrl = movie.imageUrl
        summary = movie.description
        rating = movie.rating
        type = movie.type
        favorite = movie.favorite
    }
}
