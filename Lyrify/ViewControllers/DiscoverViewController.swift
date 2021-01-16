//
//  DiscoverViewController.swift
//  Lyrify
//
//  Created by Kamil Bloch on 12/12/2019.
//  Copyright © 2019 Kamil Bloch. All rights reserved.
//
import UIKit

class DiscoverViewController: UIViewController, DataRequestDelegate {
    
    // MARK: - Data/API
    var responseData = ResponseData()
    var data: DataManager = DataManager()
    var imageLoader = ImageCacheLoader()
    
    // MARK: - UI
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var chartButton: UIBarButtonItem!

    override func viewDidLoad() {
        super.viewDidLoad()
        data.delegate = self
        data.request = Request(type: .topTracks, limit: 25)
        setupLayout()
    }
    
    func setupLayout() {
        navigationController?.navigationBar.prefersLargeTitles = true
        tableView.backgroundView = UIView()
        
        navigationController?.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: nil)
    }
    
    @IBAction func sortButtonTapped(_ sender: UIBarButtonItem) {
        let ac = UIAlertController(title: "Genres", message: "", preferredStyle: .alert)
        
        for genre in Genres.items {
            ac.addAction(UIAlertAction(title: genre.title, style: .default, handler: { (ac) in
                self.data.request = Request(type: .topTracks, userData: String(genre.id))
                self.chartButton.title = self.title

            }))
        }
        present(ac, animated: true)
    }
    
    // MARK: - Data manipulation
    
    func didReceiveData(_ data: ResponseData) {
        responseData = data
        reloadData()
    }
    
    func reloadData() {
        tableView.alpha = 0
        UIView.animate(withDuration: 2) {
            self.tableView.alpha = 1
        }
        self.tableView.reloadWithAnimation()
    }
    
    func presentLyricsViewController(with track: Track) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let lyricsVC = storyboard.instantiateViewController(withIdentifier: "LyricsViewController") as! LyricsViewController
    
        navigationController?.present(lyricsVC, animated: true) {
            lyricsVC.viewWillLayoutSubviews()
            
            self.imageLoader.obtainImageWithPath(imagePath: track.imageURL) { (img) in
                lyricsVC.imageView.image = img
                lyricsVC.addBackground(image: img)
                
                lyricsVC.titleTrack?.text = track.name
                lyricsVC.album?.text = track.album
                lyricsVC.artist?.text = track.artist
                
                lyricsVC.informations = track
                lyricsVC.data.request = Request(type: .lyrics, userData: "\(track.artist) \(track.name)")
            }
            
        }
    }
    
    // MARK: - Image caching
    func loadImage(cell: SongTableViewCell, indexPath: IndexPath, imagePath: String) {
        imageLoader.obtainImageWithPath(imagePath: imagePath) { (image) in
            if self.tableView.indexPathsForVisibleRows!.contains(indexPath) {
                cell.imageSong.image = image
            }
        }
    }
    
    func openDeezerWithPath(path: String) {
        let appURL = URL(string: "deezer://www.deezer.com\(path)")!
        let application = UIApplication.shared
        
        if application.canOpenURL(appURL) {
            application.open(appURL)
        }
    }
    

    
}

