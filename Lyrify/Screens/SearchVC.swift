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

class SearchVC: UIViewController {
    
    // MARK: - Data
    var dataManager: DataManager = DataManager()
    var allData = ResponseData()
    let searchController = UISearchController(searchResultsController: nil)

    // MARK: - UI elements
    @IBOutlet weak var tableView: UITableView!
    var searchBar: UISearchBar?

    //MARK: - Image caching
    var imageLoader = ImageCacheLoader()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        dataManager.delegate = self
        configureTableView()
        configureSearchController()
    }
        
    func configureTableView() {
        tableView.backgroundView = UIView()
        tableView.reloadData()
        tableView.keyboardDismissMode = .onDrag
    }
    
    func configureSearchController() {
        searchBar = searchController.searchBar
        searchBar?.delegate = self
        
        tableView.tableHeaderView = searchController.searchBar

        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchBar.sizeToFit()
        searchController.searchBar.tintColor = UIColor.orange
        searchController.searchBar.barTintColor = UIColor.black
    }
    
    @objc func fetchNewData() {
        guard let searchText = searchController.searchBar.text else { return }
        self.dataManager.getAll(userData: searchText)
        if !searchText.isEmpty { History.recentHistory.append(searchText) }
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

extension SearchVC: DataRequestDelegate {
    func didReceiveLyrics(lyrics: String) { }
    func didReceivedTracks(tracks: [Track]) { }
    func didReceivedAlbums(albums: [Album]) { }
    
    func didReceiveData(_ data: ResponseData) {
        allData = data
        reloadData()
        hideActivityIndicator()
    }
}

extension SearchVC: UISearchResultsUpdating, UISearchBarDelegate {
    
    // MARK: Update search results
    func updateSearchResults(for searchController: UISearchController) {
        let searchText = searchController.searchBar.text!
        
        if searchText.trimmingCharacters(in: .whitespaces).isEmpty {
            allData.removeAll()
            reloadData()
        }
    }
    
    // MARK: Reload data after text change
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if !searchText.trimmingCharacters(in: .whitespaces).isEmpty {
            NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(SearchVC.fetchNewData), object: nil)
            
            DispatchQueue.main.async {
                self.showActivityIndicator()
            }
            
            self.perform(#selector(SearchVC.fetchNewData), with: nil, afterDelay: 0.5)
        }
    }
    
   
}
