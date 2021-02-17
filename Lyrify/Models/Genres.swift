//
//  Genres.swift
//  Lyrify
//
//  Created by xcv on 16/02/2021.
//  Copyright © 2021 Kamil Bloch. All rights reserved.
//

import Foundation

struct Genre {
    let title: String
    let id: Int
}

struct Genres {
    static let items = [
        Genre(title: "All", id: 0),
        Genre(title: "Pop", id: 132),
        Genre(title: "Rap/Hip Hop", id: 116),
        Genre(title: "Rock", id: 152),
        Genre(title: "Dance", id: 113),
        Genre(title: "R&B", id: 165),
        Genre(title: "Alternative", id: 85),
        Genre(title: "Electro", id: 106),
        Genre(title: "Folk", id: 466),
        Genre(title: "Reggae", id: 144),
        Genre(title: "Jazz", id: 129),
        Genre(title: "Classic", id: 98),
        Genre(title: "Films/Games", id: 173),
        Genre(title: "Metal", id: 464),
        Genre(title: "Soul & Funk", id: 169),
        Genre(title: "Blues", id: 153),
        Genre(title: "Metal", id: 464),
        Genre(title: "Indian Music", id: 81),
        Genre(title: "Kids", id: 95),
        Genre(title: "Latino", id: 197),
        Genre(title: "African", id: 2),
        Genre(title: "Asian", id: 16),
        Genre(title: "Brazilian", id: 75),
    ]
}
