//
//  UIResponder+Extension.swift
//  Lyrify
//
//  Created by xcv on 16/02/2021.
//  Copyright © 2021 Kamil Bloch. All rights reserved.
//

import Foundation
import UIKit

extension UIResponder {
    func next<T:UIResponder>(ofType: T.Type) -> T? {
        let r = self.next
        if let r = r as? T ?? r?.next(ofType: T.self) {
            return r
        } else {
            return nil
        }
    }
}
