//
//  SearchViewControllerDatasourceDelegate.swift
//  Lyrify
//
//  Created by xcv on 12/01/2021.
//  Copyright © 2021 Kamil Bloch. All rights reserved.
//

import Foundation
import UIKit

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
        return History.recentHistory.count
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
                cell.configure(track: responseData.tracks[indexPath.row])
                loadImage(cell: cell, indexPath: indexPath, imagePath: responseData.tracks[indexPath.row].imageURL)
                return cell
            }
            else if indexPath.section == 1 && !responseData.albums.isEmpty {
                cell.configure(track: responseData.tracks[indexPath.row])
                loadImage(cell: cell, indexPath: indexPath, imagePath: responseData.albums[indexPath.row].imageURL)
                return cell
            }
            else if indexPath.section == 2 && !responseData.artists.isEmpty {
                cell.configure(track: responseData.tracks[indexPath.row])
                loadImage(cell: cell, indexPath: indexPath, imagePath: responseData.artists[indexPath.row].imageURL)
                return cell
            }
        }
        
        basicCell.textLabel?.text = History.recentHistory[indexPath.row]
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
                    label.text = Labels.tracks
                } else {
                    label.text = Labels.recentSearches
                }
            case 1:
                label.text = Labels.albums
            case 2:
                label.text = Labels.artists
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
        if indexPath.section == 0 {
            if !responseData.isEmpty() {
                presentLyricsVC(with: self.responseData.tracks[indexPath.row])
            } else {
                let recentItem = History.recentHistory[indexPath.row]
                guard searchBar != nil else { return }
                searchBar?.searchTextField.becomeFirstResponder()
                searchBar?.searchTextField.text = recentItem
                searchBar(searchBar!, textDidChange: recentItem)
                updateSearchResults(for: searchController)
            }
        } else if indexPath.section == 1 {
            presentAlbumVC(with: self.responseData.albums[indexPath.row])
           
        } else if indexPath.section == 2{
            presentArtistVC(with: self.responseData.albums[indexPath.row].artist)
        }
    }
}
