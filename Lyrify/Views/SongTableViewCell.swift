//
//  SongTableViewCell.swift
//  Lyrify
//
//  Created by Kamil Bloch on 28/11/2019.
//  Copyright © 2019 Kamil Bloch. All rights reserved.
//

import UIKit

class SongTableViewCell: UITableViewCell {
    @IBOutlet weak var imageSong: UIImageView!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var artist: UILabel!
    
    func setupUI() {
        imageSong.layer.cornerRadius = 5
        imageSong.layer.borderWidth = 1
        imageSong.layer.borderColor = UIColor.clear.cgColor
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func configure(track: Track) {
        self.title.text = track.name
        self.artist.text = track.artist
    }
}
