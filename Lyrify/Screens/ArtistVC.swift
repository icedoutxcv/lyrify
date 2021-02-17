//
//  ArtistViewController.swift
//  Lyrify
//
//  Created by Kamil Bloch on 01/12/2019.
//  Copyright © 2019 Kamil Bloch. All rights reserved.
//
import UIKit

class ArtistVC: UIViewController {
    
    //MARK: Data
    var dataManager = DataManager()
    var artist: Artist = Artist()
    var imageLoader = ImageCacheLoader()
    
    //MARK: UI
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dataManager.delegate = self
        setupCollectionView()
    }
    
    func configure(artist: Artist) {
        dataManager.getAlbums(artistName: artist.name)
    }
    
    func setupCollectionView() {
        self.collectionView.register(UINib(nibName: "AlbumCollectionViewCell", bundle: nil),
                                     forCellWithReuseIdentifier: "albumCell")
        collectionView.alwaysBounceVertical = true
    }
    
    func loadImage(cell: AlbumCollectionViewCell, indexPath: IndexPath, imagePath: String) {
        imageLoader.obtainImageWithPath(imagePath: imagePath) { (image) in
            cell.albumImage?.alpha = 0
            cell.albumImage.image = image
            UIView.animate(withDuration: 0.5, animations: {
                cell.albumImage?.alpha = 1
            })
        }
    }
}

// MARK: - DataRequestDelegate
extension ArtistVC: DataRequestDelegate {
    func didReceiveLyrics(lyrics: String) { }
    func didReceivedTracks(tracks: [Track]) { }
    func didReceiveData(_ data: ResponseData) { }
    
    func didReceivedAlbums(albums: [Album]) {
        self.artist.albums = albums
        collectionView.reloadData()
    }
}
