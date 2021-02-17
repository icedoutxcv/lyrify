//
//  AlbumViewController.swift
//  Lyrify
//
//  Created by Kamil Bloch on 01/12/2019.
//  Copyright © 2019 Kamil Bloch. All rights reserved.
//
import UIKit

class AlbumVC: UIViewController {
    // MARK: Data/API
    var data: DataManager = DataManager()
    var tracks: [Track] = [] {
        didSet {
            setView(view: albumImage, hidden: false)
            setView(view: albumName, hidden: false)
        }
    }
    
    let imageLoader = ImageCacheLoader()
    
    // MARK: UI
    @IBOutlet weak var albumImage: UIImageView!
    @IBOutlet weak var albumName: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        data.delegate = self
        fixNavigationBar()
        UserDefaults.standard.set(true, forKey: "showPop2")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        hasLaunchPop()
    }
    
    func configure(albumID: Int, name: String, image: UIImage) {
        data.getTracksFromAlbum(albumID: albumID)

        albumImage.image = image
        albumName.text = name        
    }
}

// MARK: - UITableView dataSource methods
extension AlbumVC: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tracks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let basicCell = tableView.dequeueReusableCell(withIdentifier: "basicCell", for: indexPath)
        basicCell.textLabel?.text = tracks[indexPath.row].name
        return basicCell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
         let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let lyricsVC = storyboard.instantiateViewController(withIdentifier: "LyricsViewController") as! LyricsVC
                
                present(lyricsVC, animated: true) {
                    lyricsVC.viewWillLayoutSubviews()
                    
                    lyricsVC.titleTrack?.text =  self.tracks[indexPath.row].name
                    lyricsVC.album?.text =  self.tracks[indexPath.row].album
                    lyricsVC.artist?.text =  self.tracks[indexPath.row].artist
                    
                    lyricsVC.trackData = self.tracks[indexPath.row]
                    lyricsVC.dataManager.getLyrics(track: self.tracks[indexPath.row])
                    
                    self.imageLoader.obtainImageWithPath(imagePath: self.tracks[indexPath.row].imageURL) { (img) in
                                            lyricsVC.imageView.image = img
                    }
                    
                }
    }
}

// MARK: - DataRequestDelegate
extension AlbumVC: DataRequestDelegate {
    func didReceiveLyrics(lyrics: String) { }

    func didReceivedAlbums(albums: [Album]) { }
    
    func didReceivedTracks(tracks: [Track]) {
        self.tracks = tracks
        UIView.transition(with: tableView,
        duration: 0.35,
        options: .transitionCrossDissolve,
        animations: { self.tableView.reloadData() })
    }
    
    func didReceiveData(_ data: ResponseData) {}
}

// MARK: - Other functions
extension AlbumVC {
    func loadImage(cell: SongTableViewCell, indexPath: IndexPath, imagePath: String) {
        imageLoader.obtainImageWithPath(imagePath: imagePath) { (image) in
            if self.tableView.indexPathsForVisibleRows!.contains(indexPath) {
                cell.imageSong.image = image
            }
        }
    }
    
    func hasLaunchPop() {
       let isshowPop: Bool = UserDefaults.standard.bool(forKey: "showPop2")
            if isshowPop == true  {
                setView(view: albumImage, hidden: true)
               setView(view: albumName
                   , hidden: true)
                UserDefaults.standard.set(false, forKey: "showPop2")
            }
        }
       
       func setView(view: UIView, hidden: Bool) {
           UIView.transition(with: view, duration: 0.5, options: .transitionCrossDissolve, animations: {
               view.isHidden = hidden
           })
       }
}
