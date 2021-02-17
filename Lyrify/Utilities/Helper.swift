//
//  Helper.swift
//  Lyrify
//
//  Created by xcv on 16/02/2021.
//  Copyright © 2021 Kamil Bloch. All rights reserved.
//

import Foundation
import UIKit

class Helper {
    static func presentLyricsVC(track: Track, navigationController: UINavigationController,
                         imageLoader: ImageCacheLoader) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let lyricsVC = storyboard.instantiateViewController(withIdentifier: "LyricsViewController") as! LyricsVC
    
        navigationController.present(lyricsVC, animated: true) {
            lyricsVC.viewWillLayoutSubviews()
            
            imageLoader.obtainImageWithPath(imagePath: track.imageURL) { (img) in
                lyricsVC.configure(track: track, image: img)
            }
            
        }
    }
    
    static func presentAlbumVC(albumID: Int, albumImage: UIImage, albumName:String, parentVC: UIViewController, imageLoader: ImageCacheLoader) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)

        let albumVC = storyboard.instantiateViewController(withIdentifier: "AlbumViewController") as! AlbumVC
        
        parentVC.present(albumVC, animated:true) {
            albumVC.configure(albumID: albumID, name: albumName, image: albumImage)
        }
    }
     
    static func presentArtistVC(artist: Artist, parentVC: UIViewController, imageLoader: ImageCacheLoader) {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let artistVC = storyboard.instantiateViewController(withIdentifier: "ArtistViewController") as! ArtistVC
        parentVC.present(artistVC, animated:true) {
            artistVC.configure(artist: artist)
        }
    }

    
}
