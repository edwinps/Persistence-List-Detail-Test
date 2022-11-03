//
//  Resource+Movies.swift
//  CodeTest
//
//  Created by Edwin Peña on 6/10/22.
//

import Foundation

extension Resource {
    static func movies(query: String) -> Resource<MovieDTO> {
        let url = Environment.apiUrl
        let apiKey = Environment.apiKey
        return Resource<MovieDTO>(url: url,
                                   parameters: ["t": query],
                                   apiKey: apiKey)
    }

    static func details(id: String) -> Resource<MovieDTO> {
        let url = Environment.apiUrl
        let apiKey = Environment.apiKey
        return Resource<MovieDTO>(url: url,
                                 parameters: ["i": id],
                                 apiKey: apiKey)
    }
}
