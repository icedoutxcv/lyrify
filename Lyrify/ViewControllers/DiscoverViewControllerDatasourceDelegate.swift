//
//  DiscoverViewControllerDatasourceDelegate.swift
//  Lyrify
//
//  Created by xcv on 12/01/2021.
//  Copyright © 2021 Kamil Bloch. All rights reserved.
//

import Foundation
import UIKit

extension DiscoverViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return responseData.tracks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "songCell", for: indexPath)
            as! SongTableViewCell
        
        cell.configure(track: responseData.tracks[indexPath.row])
        loadImage(cell: cell, indexPath: indexPath, imagePath: responseData.tracks[indexPath.row].imageURL)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let track = responseData.tracks[indexPath.row]
        self.presentLyricsViewController(with: track)
    }
    
}
