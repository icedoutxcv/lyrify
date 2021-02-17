//
//  DiscoverViewController.swift
//  Lyrify
//
//  Created by Kamil Bloch on 12/12/2019.
//  Copyright © 2019 Kamil Bloch. All rights reserved.
//

import UIKit

class DiscoverVC: UIViewController {
    
    // MARK: - Data
    var tracks = [Track]()
    var dataManager: DataManager = DataManager()
    
    // MARK: - UI elements
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var chartButton: UIBarButtonItem!
    
    // MARK: - Image caching
    var imageLoader = ImageCacheLoader()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dataManager.delegate = self
        
        configureViewController()
        configure()
    }
    
    // MARK: - Configure View Controller
    func configureViewController() {
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: nil)
        tableView.backgroundView = UIView()
    }
    
    // MARK: - Download tracks from API
    func configure() {
        dataManager.getTopTracks(limit: 25, genreID: String(0))
    }

    // MARK: - Load image
    func loadImage(cell: SongTableViewCell, indexPath: IndexPath, imagePath: String) {
        imageLoader.obtainImageWithPath(imagePath: imagePath) { (image) in
            if self.tableView.indexPathsForVisibleRows!.contains(indexPath) {
                cell.imageSong.image = image
            }
        }
    }
    
    // MARK: - Download new tracks after selecting genre from alert
    @IBAction func sortButtonTapped(_ sender: UIBarButtonItem) {
        let ac = UIAlertController(title: "Genres", message: "", preferredStyle: .alert)
        
        for genre in Genres.items {
            ac.addAction(UIAlertAction(title: genre.title, style: .default, handler: { (ac) in
                self.dataManager.getTopTracks(limit: 15, genreID: String(genre.id))
                self.chartButton.title = genre.title
            }))
        }
        present(ac, animated: true)
    }
}

// MARK: - DataRequestDelegate
extension DiscoverVC: DataRequestDelegate {
    func didReceivedTracks(tracks: [Track]) {
        self.tracks = tracks
        self.tableView.reloadWithAnimation()
    }
    
    func didReceivedAlbums(albums: [Album]) { }
    func didReceiveData(_ data: ResponseData) { }
    func didReceiveLyrics(lyrics: String) { }
}

