//
//  Album.swift
//  Lyrify
//
//  Created by xcv on 16/02/2021.
//  Copyright © 2021 Kamil Bloch. All rights reserved.
//

import Foundation

struct Album {
    let name: String
    let id: Int
    let tracks: [Track]
    let artist: String
    let artistID: Int
    
    let imageURL: String
    
    static func == (lhs: Album, rhs: Album) -> Bool {
        return lhs.name == rhs.name && lhs.artist == rhs.artist
    }
}
