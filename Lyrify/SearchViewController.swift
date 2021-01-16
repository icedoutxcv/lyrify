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

class SearchViewController: UIViewController {
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
    
    var recentHistory: [String] {
        get {
            let recent = UserDefaults.standard.array(forKey: "recentHistory") as? [String] ?? [String]()
            return recent.reversed()
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "recentHistory")
        }
    }
    
    @objc func reload() {
        guard let searchText = searchController.searchBar.text else { return }
        self.data.request = Request(type: .all, userData: searchText)
        if !searchText.isEmpty { recentHistory.append(searchText) }
    }
    
}
// MARK: - DataRequestDelegate
extension SearchViewController: DataRequestDelegate {
    func didReceiveData(_ data: ResponseData) {
        responseData = data
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
}

// MARK: - UITableView dataSource
extension SearchViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if  searchController.isActive && !responseData.isEmpty() {
            switch section {
            case 0: return responseData.tracks.count
            case 1: return responseData.albums.count
            case 2: return responseData.artists.count
            default: return 0
            }
        }
        return recentHistory.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if searchController.isActive && !responseData.isEmpty() {
            return 3
        } else if !searchController.isActive && responseData.isEmpty() {
            return 1
        }
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "songCell", for: indexPath)
            as! SongTableViewCell
        let basicCell = tableView.dequeueReusableCell(withIdentifier: "basicCell", for: indexPath)
       
        
        if (searchController.isActive) {
            if indexPath.section == 0 && !responseData.tracks.isEmpty {
                cell.title.text = responseData.tracks[indexPath.row].name
                cell.artist.text = responseData.tracks[indexPath.row].artist
                loadImage(cell: cell, indexPath: indexPath, imagePath: responseData.tracks[indexPath.row].imageURL)
                return cell
            }
            else if indexPath.section == 1 && !responseData.albums.isEmpty {
                cell.title.text = responseData.albums[indexPath.row].name
                cell.artist.text = responseData.albums[indexPath.row].artist
                loadImage(cell: cell, indexPath: indexPath, imagePath: responseData.albums[indexPath.row].imageURL)
                return cell
            }
            else if indexPath.section == 2 && !responseData.artists.isEmpty {
                cell.title.text = responseData.artists[indexPath.row].name
                cell.artist.text = ""
                loadImage(cell: cell, indexPath: indexPath, imagePath: responseData.artists[indexPath.row].imageURL)
                return cell
            }
        }
        basicCell.textLabel?.text = recentHistory[indexPath.row]
        return basicCell
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 30))
        view.backgroundColor = .black
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: tableView.frame.width * 0.95, height: 30))
        switch section {
        case 0:
            if searchController.isActive && !responseData.isEmpty() {
                label.text = "Tracks"
            } else {
                label.text = "Recent searches"
            }
        case 1:
            label.text = "Albums"
        case 2:
            label.text = "Artists"
        default: break
        }
        label.backgroundColor = .black
        label.textColor = .white
        label.textAlignment = NSTextAlignment.right
        label.font = UIFont.boldSystemFont(ofSize: 18)
        view.addSubview(label)
        
        return view
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if let header = view as? UITableViewHeaderFooterView {
            header.contentView.backgroundColor = .black
            header.textLabel!.textColor = UIColor.white
            header.textLabel!.textAlignment = .right
        }
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 16
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 16))
        view.backgroundColor = .clear
        return view
    }
    
    func tableView(_ tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
        if let header = view as? UITableViewHeaderFooterView {
            header.contentView.backgroundColor = .black
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let songCell = tableView.dequeueReusableCell(withIdentifier: "songCell", for: indexPath)
            as! SongTableViewCell
        let basicCell = tableView.dequeueReusableCell(withIdentifier: "basicCell", for: indexPath)
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let lyricsVC = storyboard.instantiateViewController(withIdentifier: "LyricsViewController") as! LyricsViewController
        let artistVC = storyboard.instantiateViewController(withIdentifier: "ArtistViewController") as! ArtistViewController
        let albumVC = storyboard.instantiateViewController(withIdentifier: "AlbumViewController") as! AlbumViewController
        
        if indexPath.section == 0 {
            if tableView.cellForRow(at: indexPath) == songCell {
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
            } else {
                let recentItem = recentHistory[indexPath.row]
                guard searchBar != nil else { return }
                searchBar?.searchTextField.becomeFirstResponder()
                searchBar?.searchTextField.text = recentItem
                searchBar(searchBar!, textDidChange: recentItem)
                updateSearchResults(for: searchController)
            }
           
        } else if indexPath.section == 1 {
            present(albumVC, animated:true) {
                albumVC.data.getTracksFromAlbum(albumID: self.responseData.albums[indexPath.row].id)
                self.imageLoader.obtainImageWithPath(imagePath: self.responseData.albums[indexPath.row].imageURL) { (img) in
                    albumVC.albumImage.image = img
                }
         
            }
        } else if indexPath.section == 2{
            present(artistVC, animated:true) {
                artistVC.data.getAlbums(artistName: self.responseData.albums[indexPath.row].artist)
            }
        }
    }
}

// MARK: - Other functions
extension SearchViewController {
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
