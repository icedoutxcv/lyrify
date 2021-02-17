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
extension SearchVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchController.isActive && !allData.isEmpty() {
            switch section {
            case 0: return allData.tracks.count
            case 1: return allData.albums.count
            case 2: return allData.artists.count
            default: return 0
            }
        }
        return History.recentHistory.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if searchController.isActive && !allData.isEmpty() {
            return 3
        } else if !searchController.isActive && allData.isEmpty() {
            return 1
        }
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "songCell", for: indexPath)
            as! SongTableViewCell
        let basicCell = tableView.dequeueReusableCell(withIdentifier: "basicCell", for: indexPath)
        
        if (searchController.isActive) {
            if indexPath.section == 0 && !allData.tracks.isEmpty {
                cell.configure(track: allData.tracks[indexPath.row])
                loadImage(cell: cell, indexPath: indexPath, imagePath: allData.tracks[indexPath.row].imageURL)
                return cell
            }
            else if indexPath.section == 1 && !allData.albums.isEmpty {
                cell.configure(album: allData.albums[indexPath.row])
                loadImage(cell: cell, indexPath: indexPath, imagePath: allData.albums[indexPath.row].imageURL)
                return cell
            }
            else if indexPath.section == 2 && !allData.artists.isEmpty {
                cell.configure(artist: allData.artists[indexPath.row])
                loadImage(cell: cell, indexPath: indexPath, imagePath: allData.artists[indexPath.row].imageURL)
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
                if searchController.isActive && !allData.isEmpty() {
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
            if !allData.isEmpty() {
                Helper.presentLyricsVC(track: self.allData.tracks[indexPath.row], navigationController: navigationController!, imageLoader: imageLoader)
            } else {
                let recentItem = History.recentHistory[indexPath.row]
                guard searchBar != nil else { return }
                searchBar?.searchTextField.becomeFirstResponder()
                searchBar?.searchTextField.text = recentItem
                searchBar(searchBar!, textDidChange: recentItem)
                updateSearchResults(for: searchController)
            }
        } else if indexPath.section == 1 {
            Helper.presentAlbumVC(albumID: self.allData.albums[indexPath.row].id, albumImage: UIImage(), albumName: self.allData.albums[indexPath.row].name,parentVC: self, imageLoader: imageLoader )
           
        } else if indexPath.section == 2{
            let selectedArtist = self.allData.albums[indexPath.row]
           
            let artist = Artist(name: selectedArtist.artist , id: selectedArtist.artistID, albums: [], imageURL: selectedArtist.imageURL)
            
            Helper.presentArtistVC(artist: artist, parentVC: self, imageLoader: imageLoader)
        }
    }
}
