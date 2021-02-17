//
//  Artist.swift
//  Lyrify
//
//  Created by xcv on 16/02/2021.
//  Copyright © 2021 Kamil Bloch. All rights reserved.
//

import Foundation

struct Artist {
    let name: String
    let id: Int
    var albums: [Album]
    
    let imageURL: String
    
    static func == (lhs: Artist, rhs: Artist) -> Bool {
        return lhs.name == rhs.name && lhs.id == rhs.id
    }
    
    init(name: String = "", id: Int = 0, albums: [Album] = [], imageURL:
          String = "")  {
        self.name = name
        self.id = id
        self.albums = albums
        self.imageURL = imageURL
    }
    
}
