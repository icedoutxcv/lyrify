//
//  AlbumCollectionViewCell.swift
//  Lyrify
//
//  Created by Kamil Bloch on 03/12/2019.
//  Copyright © 2019 Kamil Bloch. All rights reserved.
//

import UIKit

class AlbumCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var albumImage: UIImageView!
    @IBOutlet weak var albumName: UILabel!
    @IBOutlet weak var albumYear: UILabel!
    
    func setupUI() {
        albumImage.layer.cornerRadius = 5
        albumImage.layer.borderWidth = 1
        albumImage.layer.borderColor = UIColor.clear.cgColor
    }
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
