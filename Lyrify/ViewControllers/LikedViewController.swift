//
//  LikedViewController.swift
//  Lyrify
//
//  Created by Kamil Bloch on 29/12/2019.
//  Copyright © 2019 Kamil Bloch. All rights reserved.
//
import UIKit

class LikedViewController: UIViewController {
    // MARK: - Data
    func likedTracks() -> [TrackData] {
        var currentTracks: [TrackData] = [TrackData]()
        if let propertylistSongs = UserDefaults.standard.array(forKey: "likedTracks") as? [[String:String]] {
            currentTracks = propertylistSongs.compactMap{ TrackData(dictionary: $0) }
        }
        print(currentTracks)
        return currentTracks
    }
    
    let imageLoader = ImageCacheLoader()
    
    // MARK: - UI
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fixNavigationBar()
        tableView.reloadData()
    }
}

// MARK: - UITableView dataSource methods
extension LikedViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return likedTracks().count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "songCell", for: indexPath)
            as! SongTableViewCell
        
        cell.title.text = self.likedTracks()[indexPath.row].name
        cell.artist.text = self.likedTracks()[indexPath.row].artist
        loadImage(cell: cell, indexPath: indexPath, imagePath: self.likedTracks()[indexPath.row].imageURL)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let lyricsVC = storyboard.instantiateViewController(withIdentifier: "LyricsViewController") as! LyricsViewController
        
        present(lyricsVC, animated: true) {
            lyricsVC.viewWillLayoutSubviews()
            
            lyricsVC.titleTrack?.text =  self.likedTracks()[indexPath.row].name
            lyricsVC.album?.text =  self.likedTracks()[indexPath.row].album
            lyricsVC.artist?.text =  self.likedTracks()[indexPath.row].artist
            
            lyricsVC.informations = Track(name: self.likedTracks()[indexPath.row].name, id: Int(self.likedTracks()[indexPath.row].id)!, artist: self.likedTracks()[indexPath.row].artist, artistID: Int(self.likedTracks()[indexPath.row].artistID)!, album: self.likedTracks()[indexPath.row].album, albumID: Int(self.likedTracks()[indexPath.row].albumID)!, imageURL: self.likedTracks()[indexPath.row].imageURL)
            lyricsVC.data.request = Request(type: .lyrics, userData: "\(self.likedTracks()[indexPath.row].artist) \(self.likedTracks()[indexPath.row].name)")
            
            self.imageLoader.obtainImageWithPath(imagePath: self.likedTracks()[indexPath.row].imageURL) { (img) in
                lyricsVC.imageView.image = img
            }
            
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            var currentlyLiked = likedTracks()
            currentlyLiked.remove(at: indexPath.row)
            
            let propertylistSongs = currentlyLiked.map{ $0.propertyListRepresentation }
            UserDefaults.standard.set(propertylistSongs, forKey: "likedTracks")
            
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
}

// MARK: - Other functions
extension LikedViewController {
    func loadImage(cell: SongTableViewCell, indexPath: IndexPath, imagePath: String) {
        imageLoader.obtainImageWithPath(imagePath: imagePath) { (image) in
            if self.tableView.indexPathsForVisibleRows!.contains(indexPath) {
                cell.imageSong.image = image
            }
        }
    }
}

