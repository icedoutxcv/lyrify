//
//  ResponseData.swift
//  Lyrify
//
//  Created by xcv on 16/02/2021.
//  Copyright © 2021 Kamil Bloch. All rights reserved.
//

import Foundation

struct ResponseData {
    var tracks = [Track]()
    var albums =  [Album]()
    var artists =  [Artist]()
    
    func isEmpty() -> Bool {
        if tracks.isEmpty && albums.isEmpty && artists.isEmpty {
            return true
        }
        return false
    }
    
    mutating func removeAll() {
        tracks.removeAll()
        albums.removeAll()
        artists.removeAll()
    }
}
