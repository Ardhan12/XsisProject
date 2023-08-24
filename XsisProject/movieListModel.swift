//
//  movieListModel.swift
//  XsisProject
//
//  Created by Arief Ramadhan on 24/08/23.
//

import Foundation

struct MovieList: Codable {
    let genres: [GenreMovie]
}

// MARK: - Genre
struct GenreMovie: Codable {
    let id: Int
    let name: String
}
