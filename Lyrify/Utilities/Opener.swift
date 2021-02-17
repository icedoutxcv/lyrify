//
//  Opener.swift
//  Lyrify
//
//  Created by xcv on 16/02/2021.
//  Copyright © 2021 Kamil Bloch. All rights reserved.
//

import Foundation
import UIKit

class Opener {
    static func openDeezerWithPath(path: String) {
        let appURL = URL(string: "deezer://www.deezer.com\(path)")!
        let application = UIApplication.shared
        
        if application.canOpenURL(appURL) {
            application.open(appURL)
        }
    }
}
