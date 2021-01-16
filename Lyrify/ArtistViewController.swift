//
//  ArtistViewController.swift
//  Lyrify
//
//  Created by Kamil Bloch on 01/12/2019.
//  Copyright © 2019 Kamil Bloch. All rights reserved.
//
import UIKit

class ArtistViewController: UIViewController {
    //MARK: Data/API
    var data = DataManager()
    var responseData = ResponseData()
    var imageLoader = ImageCacheLoader()
    
    //MARK: UI
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        data.delegate = self
        setupCollectionView()
    }
}

// MARK: - DataRequestDelegate
extension ArtistViewController: DataRequestDelegate {
    func didReceiveData(_ data: ResponseData) {
        responseData = data
        collectionView.reloadData()
    }
}

// MARK: - CollectionView dataSource methods
extension ArtistViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return responseData.albums.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell : AlbumCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "albumCell", for: indexPath) as! AlbumCollectionViewCell
        
        cell.albumName.text = responseData.albums[indexPath.row].name
        loadImage(cell: cell, indexPath: indexPath, imagePath: responseData.albums[indexPath.row].imageURL)
        return cell
    }
    
}


//MARK: - UICollectionViewDelegateFlowLayout
extension ArtistViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 140, height: 220)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 35, left: 35, bottom: 35, right: 35)
    }
}

// MARK: - Other functions
extension ArtistViewController {
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

