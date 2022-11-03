//
//  Movie.swift
//  CodeTest
//
//  Created by Edwin Peña on 7/10/22.
//

import Foundation

struct Movie {
    let id: String
    let title: String?
    let imageUrl: String?
    let imageData: Data?
    let description: String?
    let rating: String?
    let type: String?
    let favorite: Bool
}

extension Movie {
    init(dto: MovieDTO) {
        id = dto.id
        title = dto.title
        imageUrl = dto.imageUrl
        imageData = nil
        description = dto.description
        rating = dto.rating
        type = dto.type
        favorite = false
    }
}

extension Movie {
    init(viewModel: MovieViewModel, data: Data?) {
        id = viewModel.id
        title = viewModel.title
        imageUrl = viewModel.imageUrl
        imageData = data
        description = viewModel.summary
        rating = viewModel.rating
        type = viewModel.type
        favorite = true
    }
}
