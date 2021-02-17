//
//  Track.swift
//  Lyrify
//
//  Created by xcv on 16/02/2021.
//  Copyright © 2021 Kamil Bloch. All rights reserved.
//

import Foundation

struct Track: Decodable, Encodable, Equatable {
    let name: String
    let id: Int
    let artist: String
    let artistID: Int
    let album: String
    let albumID: Int
    
    let imageURL: String
    
    static func == (lhs: Track, rhs: Track) -> Bool {
        return lhs.name == rhs.name && lhs.artist == rhs.artist
    }
}

