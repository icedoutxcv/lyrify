//
//  History.swift
//  Lyrify
//
//  Created by xcv on 16/02/2021.
//  Copyright © 2021 Kamil Bloch. All rights reserved.
//

import Foundation

class History {
    static var recentHistory: [String] {
        get {
            let recent = UserDefaults.standard.array(forKey: "recentHistory") as? [String] ?? [String]()
            return recent.reversed()
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "recentHistory")
        }
    }
}
