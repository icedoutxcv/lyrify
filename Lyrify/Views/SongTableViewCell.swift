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
    @IBOutlet weak var firstLabel: UILabel!
    @IBOutlet weak var secondLabel: UILabel!
    
    func setupUI() {
        guard let imageSong = imageSong else { return }
        imageSong.layer.cornerRadius = 5
        imageSong.layer.borderWidth = 1
        imageSong.layer.borderColor = UIColor.clear.cgColor
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func configure(track: Track) {
        self.firstLabel.text = track.name
        self.secondLabel.text = track.artist
    }
    
    func configure(album: Album) {
        self.firstLabel.text = album.name
        self.secondLabel.text = "Album"
    }
    
    func configure(artist: Artist) {
        self.firstLabel.text = artist.name
        self.secondLabel.text = "Artist"
    }
}
