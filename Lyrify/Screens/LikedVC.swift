//
//  LikedViewController.swift
//  Lyrify
//
//  Created by Kamil Bloch on 29/12/2019.
//  Copyright © 2019 Kamil Bloch. All rights reserved.
//
import UIKit

class LikedVC: UIViewController {
    // MARK: - Data
    let imageLoader = ImageCacheLoader()
    
    // MARK: - UI
    @IBOutlet weak var tableView: UITableView!
    
    private var liked: [Track] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fixNavigationBar()
        tableView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        getLiked()
    }
    
    private func getLiked() {
        PersistenceManager.retrieveLiked { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let liked):
                self.updateUI(with: liked)
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func updateUI(with liked: [Track]) {
        if liked.isEmpty {
            print("there is nothing to show")
        } else {
            self.liked = liked
            DispatchQueue.main.async {
                self.tableView.reloadData()
                self.view.bringSubviewToFront(self.tableView)
            }
        }
    }
    
    func loadImage(cell: SongTableViewCell, indexPath: IndexPath, imagePath: String) {
        imageLoader.obtainImageWithPath(imagePath: imagePath) { (image) in
            if self.tableView.indexPathsForVisibleRows!.contains(indexPath) {
                cell.imageSong.image = image
            }
        }
    }
}

// MARK: - UITableView dataSource methods
extension LikedVC: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return liked.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "songCell", for: indexPath)
            as! SongTableViewCell
        
        cell.firstLabel.text = self.liked[indexPath.row].name
        cell.secondLabel.text = self.liked[indexPath.row].artist
        loadImage(cell: cell, indexPath: indexPath, imagePath: self.liked[indexPath.row].imageURL)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let trackFromList = self.liked[indexPath.row]
        let track =  Track(name: trackFromList.name, id: trackFromList.id, artist: trackFromList.artist, artistID: trackFromList.artistID, album: trackFromList.album, albumID: trackFromList.albumID, imageURL: trackFromList.imageURL)
        
        Helper.presentLyricsVC(track: track, navigationController: navigationController!, imageLoader: imageLoader)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete else { return }
        
        PersistenceManager.updateWidth(trackData: liked[indexPath.row], actionType: .remove) { [weak self] error in
            guard let self = self else { return }
            guard let error = error else {
                self.liked.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .left)
                return
            }
            
            print("unable to remove")
        }
    }
}
