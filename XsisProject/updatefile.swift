//
//  updatefile.swift
//  XsisProject
//
//  Created by Arief Ramadhan on 29/09/23.
//

import Foundation

struct MovieList2: Codable {
    let genres: [GenreMovie]
}

// MARK: - Genre
struct GenreMovie2: Codable {
    let id: Int
    let name: String
}
