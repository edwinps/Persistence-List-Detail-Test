//
//  MovieDTO.swift
//  CodeTest
//
//  Created by Edwin Peña on 2/11/22.
//

import Foundation

struct MovieDTO {
    let id: String
    let title: String?
    let imageUrl: String?
    let description: String?
    let rating: String?
    let type: String?
}

extension MovieDTO: Decodable {
    enum CodingKeys: String, CodingKey {
        case id = "imdbID"
        case title = "Title"
        case imageUrl = "Poster"
        case description = "Plot"
        case rating = "imdbRating"
        case type = "Type"
    }
}
