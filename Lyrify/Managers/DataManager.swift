//
//  DataManager.swift
//  Lyrify
//
//  Created by Kamil Bloch on 04/12/2019.
//  Copyright © 2019 Kamil Bloch. All rights reserved.
//

import Foundation
import UIKit
import Alamofire
import SwiftyJSON
import SwiftSoup

protocol DataRequestDelegate {
    func didReceiveData(_ data: ResponseData)
    func didReceivedAlbums(albums: [Album])
    func didReceivedTracks(tracks: [Track])
    func didReceiveLyrics(lyrics: String)
}

class DataManager {
    var delegate: DataRequestDelegate?
    
    func getTracksFromAlbum(albumID: Int) {
        let rootUrl = "https://api.deezer.com/"
        let path = "album/\(albumID)"
        guard let adress = (rootUrl+path).addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else { return }
        
        var responseData = ResponseData()
        var name: String?
        var trackID: Int?
        var artist: String?
        var artistID: Int?
        var album: String?
        var albumID: Int?
        var imageURL: String?
        
        DispatchQueue.main.async {
            Alamofire.request(adress,method: .get).responseJSON { (response) in
                switch response.result {
                case .success:
                    do {
                        if let data = response.data {
                            if let json = try JSON(data: data).dictionary {
                                guard response.data != nil else { return }
                                
                                artist = json["artist"]?["name"].string
                                artistID = json["artist"]?["id"].int
                                album = json["title"]?.string
                                albumID = json["id"]?.int
                                imageURL = json["cover_medium"]?.string
                                
                                guard json["tracks"]?["data"] != nil else { return }
                                for i in (json["tracks"]?["data"].count)! {
                                    name =  json["tracks"]?["data"][i]["title"].string
                                    trackID = json["tracks"]?["data"][i]["id"].int
                                    artist = json["artist"]?["name"].string
                                    artistID = json["artist"]?["id"].int
                                    album = json["title"]?.string
                                    albumID = json["id"]?.int
                                    imageURL = json["cover_medium"]?.string
                                    
                                    let track = Track(name: name!, id: trackID!, artist: artist!, artistID: artistID!, album: album!, albumID: albumID!, imageURL: imageURL ?? "" )
                                    if !responseData.tracks.contains(where: {
                                        (trackToCompare) -> Bool in
                                        let bool = (trackToCompare == track) ? true : false
                                        return bool
                                    }) { responseData.tracks.append(track) }
                                }
                            }
                        }
                        self.delegate?.didReceivedTracks(tracks: responseData.tracks)
                    } catch {}
                case .failure: print(0)
                }
            }
        }
    }
    
    func getLyrics(track: Track) {
        let rootUrl = "https://api.genius.com/"
        let path = "search?q=\(track.artist) \(track.name)"
        guard let adress = (rootUrl+path).addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else { return }
        let headers = ["Authorization":"Bearer 4Eo88FOlVGZpJ51inDGeC1zLfphPlHmD1PfQ_TVTsSM6iXwWRnLSUBjcu7vAS26k"]
        
        var lyrics = String()
        
        DispatchQueue.main.async {
            Alamofire.request(adress, method: .get, headers: headers).responseJSON { (response) in
                switch response.result {
                case .success:
                    do {
                        if let data = response.data {
                            
                            
                            if let json = try JSON(data: data).dictionary {
                                guard response.data != nil else { return }
                                guard let url = json["response"]?["hits"][0]["result"]["url"].string else { return }
                                
                                guard let myURL = URL(string: url) else {
                                    print("Error: \(url) doesn't seem to be a valid URL")
                                    return
                                }
                                do {
                                    let myHTMLString = try String(contentsOf: myURL, encoding: .utf8)
                                    let doc: Document = try SwiftSoup.parse(myHTMLString)
                                    let elements = try doc.getAllElements()
                                    let lyricsFromGenius = try elements.select("div.lyrics").html().html2String
                                    lyrics = lyricsFromGenius
                                } catch let error {
                                    print("Error: \(error)")
                                }
                            }
                        } }catch {}
                    self.delegate?.didReceiveLyrics(lyrics: lyrics)
                case .failure: print("error")
                }
            }
        }
        
        // SECOND API
        //        let rootUrl = "https://api.lyrics.ovh/v1/"
        //        print(request.artist, request.title)
        //        let path = "\(request.artist!)/\(request.title!))"
        //        print(rootUrl+path)
        //        guard let adress = (rootUrl+path).addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else { return }
        //        var responseData = ResponseData()
        //
        //        DispatchQueue.main.async {
        //            Alamofire.request(adress, method: .get).responseJSON { (response) in
        //                switch response.result {
        //                case .success:
        //                    do {
        //                        if let data = response.data {
        //
        //                            if let json = try JSON(data: data).dictionary {
        //                                guard response.data != nil else { return }
        //
        //                                guard json["lyrics"] != nil else {
        //                                    return }
        //                               let lyrics = json["lyrics"]?.string
        //                                responseData.lyrics = lyrics!
        //
        //                            }
        //                        } } catch {}
        //                    self.delegate?.didReceiveData(responseData)
        //                case .failure: print("error")
        //                }
        //            }
        //        }
    }
    
    func getAlbums(artistName: String) {
        let rootUrl = "https://api.deezer.com/"
        let path = "search?q=\(artistName)&limit=250"
        
        var albums = [Album]()
        var name: String?
        var trackID: Int?
        var artist: String?
        var artistID: Int?
        var album: String?
        var albumID: Int?
        var imageURL: String?
        
        DispatchQueue.main.async {
            guard let adress = (rootUrl+path).addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else { return }
            
            Alamofire.request(adress,method: .get).responseJSON { (response) in
                switch response.result {
                case .success:
                    do {
                        if let data = response.data {
                            if let json = try JSON(data: data).dictionary {
                                guard response.data != nil else { return }
                                
                                for i in json["data"]!.count {
                                    name =  json["data"]?[i]["title"].string
                                    trackID = json["data"]?[i]["id"].int
                                    artist = json["data"]?[i]["artist"]["name"].string
                                    artistID = json["data"]?[i]["artist"]["id"].int
                                    album = json["data"]?[i]["album"]["title"].string
                                    albumID = json["data"]?[i]["album"]["id"].int
                                    imageURL = json["data"]?[i]["album"]["cover_medium"].string
                                    
                                    if artist == artistName {
                                        let album = Album(name: album!, id: albumID!, tracks: [], artist: artist!, artistID: artistID!, imageURL: imageURL ?? "")
                                        
                                        if !albums.contains(where: {
                                            (albumToCompare) -> Bool in
                                            let bool = (albumToCompare == album) ? true : false
                                            return bool
                                        }) { albums.append(album) }
                                    }
                                }
                            }
                        }
                        self.delegate?.didReceivedAlbums(albums: albums)
                    } catch {}
                case .failure: print(0)
                }
            }
        }
    }
    
    func getAll(userData: String) {
        let rootUrl = "https://api.deezer.com/"
        let path = "search?q=\(userData)&limit=150"
        
        guard userData != "" else { return }
        var responseData = ResponseData()
        var name: String?
        var trackID: Int?
        var artist: String?
        var artistID: Int?
        var album: String?
        var albumID: Int?
        var imageURL: String?
        
        DispatchQueue.main.async {
            guard let adress = (rootUrl+path).addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else { return }
            Alamofire.request(adress,method: .get).responseJSON { (response) in
                switch response.result {
                case .success:
                    do {
                        if let data = response.data {
                            if let json = try JSON(data: data).dictionary {
                                guard response.data != nil else { return }
                            
                                print(adress)
                                for i in json["data"]!.count {
                                    name =  json["data"]?[i]["title"].string
                                    trackID = json["data"]?[i]["id"].int
                                    artist = json["data"]?[i]["artist"]["name"].string
                                    artistID = json["data"]?[i]["artist"]["id"].int
                                    album = json["data"]?[i]["album"]["title"].string
                                    albumID = json["data"]?[i]["album"]["id"].int
                                    imageURL = json["data"]?[i]["album"]["cover_medium"].string
                                    
                                    let track = Track(name: name!, id: trackID!, artist: artist!, artistID: artistID!, album: album!, albumID: albumID!, imageURL: imageURL ?? "" )
                                    let album = Album(name: album!, id: albumID!, tracks: [], artist: artist!, artistID: artistID!, imageURL: imageURL ?? "")
                                    let artist = Artist(name: artist!, id: artistID!, albums: [], imageURL: imageURL ?? "")
                                    
                                    if !responseData.artists.contains(where: {
                                        (artistToCompare) -> Bool in
                                        let bool = (artistToCompare == artist) ? true : false
                                        return bool
                                    }) { responseData.artists.append(artist) }
                                    
                                    if !responseData.tracks.contains(where: {
                                        (trackToCompare) -> Bool in
                                        let bool = (trackToCompare == track) ? true : false
                                        return bool
                                    }) { responseData.tracks.append(track) }
                                    
                                    if !responseData.albums.contains(where: {
                                        (albumToCompare) -> Bool in
                                        let bool = (albumToCompare == album) ? true : false
                                        return bool
                                    }) { responseData.albums.append(album) }
                                    
                                }
                            }
                        }
                        self.delegate?.didReceiveData(responseData)
                    } catch {}
                case .failure: print(0)
                }
            }
        }
        
    }
    
    func getTopTracks(limit: Int, genreID: String) {
        let rootUrl = "https://api.deezer.com/"
        let path = "chart/\(genreID)"
        guard let adress = (rootUrl+path).addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else { return }
        
        var tracks = [Track]()
        var name: String?
        var trackID: Int?
        var artist: String?
        var artistID: Int?
        var album: String?
        var albumID: Int?
        var imageURL: String?
        
        DispatchQueue.main.async {
            Alamofire.request(adress, method: .get).responseJSON { (response) in
                switch response.result {
                case .success:
                    do {
                        if let data = response.data {
                            if let json = try JSON(data: data).dictionary {
                                guard response.data != nil else { return }
                        
                                print(adress)
                                for i in (json["tracks"]?["data"].count)! {
                                    name =  json["tracks"]?["data"][i]["title"].string
                                    trackID = json["tracks"]?["data"][i]["id"].int
                                    artist = json["tracks"]?["data"][i]["artist"]["name"].string
                                    artistID = json["tracks"]?["data"][i]["artist"]["id"].int
                                    album = json["tracks"]?["data"][i]["title"].string
                                    albumID = json["tracks"]?["data"][i]["album"]["id"].int
                                    imageURL = json["tracks"]?["data"][i]["album"]["cover_medium"].string
                                    
                                    let track = Track(name: name!, id: trackID!, artist: artist!, artistID: artistID!, album: album!, albumID: albumID!, imageURL: imageURL ?? "" )
                                    if !tracks.contains(where: {
                                        (trackToCompare) -> Bool in
                                        let bool = (trackToCompare == track) ? true : false
                                        return bool
                                    }) { tracks.append(track) }
                                }
                            }
                        }
                        self.delegate?.didReceivedTracks(tracks: tracks)
                    } catch {}
                case .failure: print(0)
                }
            }
        }
    }
}

