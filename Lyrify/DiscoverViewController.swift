//
//  DiscoverViewController.swift
//  Lyrify
//
//  Created by Kamil Bloch on 12/12/2019.
//  Copyright © 2019 Kamil Bloch. All rights reserved.
//
import UIKit

class DiscoverViewController: UIViewController {
    // MARK: - Data/API
    var responseData = ResponseData()
    var data: DataManager = DataManager()
    var imageLoader = ImageCacheLoader()
    
    // MARK: - UI
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        data.delegate = self
        data.request = Request(type: .topTracks, limit: 25)
        setupLayout()
    }
    
    @IBAction func sortButtonTapped(_ sender: UIBarButtonItem) {
        let ac = UIAlertController(title: "Genres", message: "", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "All", style: .default, handler: { (ac) in
            self.showTopSongs(genreID: "0")
            self.setChartButtonTitle(title: "All")
        }))
        ac.addAction(UIAlertAction(title: "Hip Hop/Rap", style: .default, handler: { (ac) in
            self.showTopSongs(genreID: "116")
            self.setChartButtonTitle(title: "Hip Hop/Rap")
        }))
        ac.addAction(UIAlertAction(title: "R&B", style: .default, handler: { (ac) in
            self.showTopSongs(genreID: "116")
            self.setChartButtonTitle(title: "R&B")
        }))
        ac.addAction(UIAlertAction(title: "Indie Rock", style: .default, handler: { (ac) in
            self.showTopSongs(genreID: "154")
            self.setChartButtonTitle(title: "Indie Rock")
        }))
        ac.addAction(UIAlertAction(title: "Rock", style: .default, handler: { (ac) in
            self.showTopSongs(genreID: "152")
            self.setChartButtonTitle(title: "Rock")
        }))
        ac.addAction(UIAlertAction(title: "Reggae", style: .default, handler: { (ac) in
            self.showTopSongs(genreID: "144")
            self.setChartButtonTitle(title: "Reggae")
        }))
        ac.addAction(UIAlertAction(title: "Pop", style: .default, handler: { (ac) in
            self.showTopSongs(genreID: "132")
            self.setChartButtonTitle(title: "Pop")
        }))
        present(ac, animated: true)
    }
    
    @IBOutlet weak var chartButton: UIBarButtonItem!
    func setChartButtonTitle(title: String) {
        self.chartButton.title = title
    }
    
}
// MARK: DataRequestDelegate
extension DiscoverViewController: DataRequestDelegate {
    func didReceiveData(_ data: ResponseData) {
        responseData = data
        reloadData()
    }
}

// MARK: UITableView dataSource methods
extension DiscoverViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return responseData.tracks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "songCell", for: indexPath)
            as! SongTableViewCell
        
        cell.title.text = responseData.tracks[indexPath.row].name
        cell.artist.text = responseData.tracks[indexPath.row].artist
        loadImage(cell: cell, indexPath: indexPath, imagePath: responseData.tracks[indexPath.row].imageURL)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        _ = tableView.dequeueReusableCell(withIdentifier: "songCell", for: indexPath)
            as! SongTableViewCell
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let lyricsVC = storyboard.instantiateViewController(withIdentifier: "LyricsViewController") as! LyricsViewController
        
        let titleTrack = self.responseData.tracks[indexPath.row].name
        let album = self.responseData.tracks[indexPath.row].album
        let artist = self.responseData.tracks[indexPath.row].artist
        let informations = self.responseData.tracks[indexPath.row]
        
        navigationController?.present(lyricsVC, animated: true) {
            lyricsVC.viewWillLayoutSubviews()
            
            self.imageLoader.obtainImageWithPath(imagePath: self.responseData.tracks[indexPath.row].imageURL) { (img) in
                lyricsVC.imageView.image = img
                lyricsVC.addBackground(image: img)
                
                lyricsVC.titleTrack?.text = titleTrack
                lyricsVC.album?.text = album
                lyricsVC.artist?.text = artist
                
                lyricsVC.informations = informations
                lyricsVC.data.request = Request(type: .lyrics, userData: "\(self.responseData.tracks[indexPath.row].artist) \(self.responseData.tracks[indexPath.row].name)")
            }
            
        }
    }
    
}
// MARK: - Other functions
extension DiscoverViewController {
    func setupLayout() {
        navigationController?.navigationBar.prefersLargeTitles = true
        tableView.backgroundView = UIView()
    }
    
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
    
    func showTopSongs(genreID: String) {
        self.data.request = Request(type: .topTracks, userData: genreID)
    }
    
    func reloadData() {
        tableView.alpha = 0
        UIView.animate(withDuration: 2) {
            self.tableView.alpha = 1
        }
        self.tableView.reloadWithAnimation()
    }
}
