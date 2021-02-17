//
//  DiscoverViewControllerDatasourceDelegate.swift
//  Lyrify
//
//  Created by xcv on 12/01/2021.
//  Copyright © 2021 Kamil Bloch. All rights reserved.
//

import Foundation
import UIKit

extension DiscoverVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tracks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "songCell", for: indexPath)
            as! SongTableViewCell
        
        // MARK: Configure and load image for each cell
        let track = tracks[indexPath.row]
        cell.configure(track: track)
        loadImage(cell: cell, indexPath: indexPath, imagePath: tracks[indexPath.row].imageURL)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let track = tracks[indexPath.row]
        Helper.presentLyricsVC(track: track, navigationController: navigationController!, imageLoader: imageLoader)
    }
}
