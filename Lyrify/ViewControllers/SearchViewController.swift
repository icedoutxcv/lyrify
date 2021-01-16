//
//  ViewController.swift
//  Lyrify
//
//  Created by Kamil Bloch on 28/11/2019.
//  Copyright © 2019 Kamil Bloch. All rights reserved.
//
import UIKit
import Alamofire
import SwiftyJSON

class SearchViewController: UIViewController, DataRequestDelegate {
    
    // MARK: - API/Data
    var data: DataManager = DataManager()
    var responseData = ResponseData() {
        didSet {
            reloadData()
            hideActivityIndicator()
        }
    }
    var imageLoader = ImageCacheLoader()
    
    // MARK: - UI
    @IBOutlet weak var tableView: UITableView!
    let searchController = UISearchController(searchResultsController: nil)
    var searchBar: UISearchBar?

    override func viewDidLoad() {
        super.viewDidLoad()
        data.delegate = self
        searchBar = searchController.searchBar

        searchBar?.delegate = self
    
        setupLayout()
        setupSearchController()
    }
        
    @objc func reload() {
        guard let searchText = searchController.searchBar.text else { return }
        self.data.request = Request(type: .all, userData: searchText)
        if !searchText.isEmpty { History.recentHistory.append(searchText) }
    }
    
    func didReceiveData(_ data: ResponseData) {
        responseData = data
    }
    
    func setupLayout() {
        searchController.searchBar.tintColor = UIColor.orange
        searchController.searchBar.barTintColor = UIColor.black
        
        tableView.backgroundView = UIView()
        tableView.reloadData()
        tableView.keyboardDismissMode = .onDrag
    }
    
    func loadImage(cell: SongTableViewCell, indexPath: IndexPath, imagePath: String) {
        imageLoader.obtainImageWithPath(imagePath: imagePath) { (image) in
            if self.tableView.indexPathsForVisibleRows!.contains(indexPath) {
                cell.imageSong.image = image
            }
        }
    }
    
    func reloadData() {
        UIView.transition(with: tableView,
        duration: 0.35,
        options: .transitionCrossDissolve,
        animations: { self.tableView.reloadData() })
    }
    
}

//MARK: - UISearchBar/Results
extension SearchViewController: UISearchResultsUpdating, UISearchBarDelegate {
    func setupSearchController() {
        tableView.tableHeaderView = searchController.searchBar
        
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchBar.sizeToFit()
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        let searchText = searchController.searchBar.text!
        
        if searchText.trimmingCharacters(in: .whitespaces).isEmpty {
            responseData.removeAll()
            tableView.reloadData()
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        if !searchText.trimmingCharacters(in: .whitespaces).isEmpty {
            NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(SearchViewController.reload), object: nil)
            showActivityIndicator()
            
            self.perform(#selector(SearchViewController.reload), with: nil, afterDelay: 0.5)
        }
    }
    
    
    func presentLyricsVC(with track: Track) {
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
    
    func presentAlbumVC(with album: Album) {
        let albumVC = storyboard?.instantiateViewController(withIdentifier: "AlbumViewController") as! AlbumViewController

        present(albumVC, animated:true) {
            albumVC.data.getTracksFromAlbum(albumID: album.id)
            self.imageLoader.obtainImageWithPath(imagePath: album.imageURL) { (img) in
                albumVC.albumImage.image = img
            }
            
        }
    }
    
    func presentArtistVC(with artistName: String) {
        let artistVC = storyboard?.instantiateViewController(withIdentifier: "ArtistViewController") as! ArtistViewController

        present(artistVC, animated:true) {
            artistVC.data.getAlbums(artistName: artistName)
        }
    }
}
