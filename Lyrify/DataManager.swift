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

struct Track {
    let name: String
    let id: Int
    let artist: String
    let artistID: Int
    let album: String
    let albumID: Int
    
    let imageURL: String
    
    static func == (lhs: Track, rhs: Track) -> Bool {
        return lhs.name == rhs.name && lhs.artist == rhs.artist
    }
}

struct Album {
    let name: String
    let id: Int
    let tracks: [Track]
    let artist: String
    let artistID: Int
    
    let imageURL: String
    
    static func == (lhs: Album, rhs: Album) -> Bool {
        return lhs.name == rhs.name && lhs.artist == rhs.artist
    }
}

struct Artist {
    let name: String
    let id: Int
    let albums: [Album]
    
    let imageURL: String
    
    static func == (lhs: Artist, rhs: Artist) -> Bool {
        return lhs.name == rhs.name && lhs.id == rhs.id
    }
}

protocol DataRequestDelegate {
    func didReceiveData(_ data: ResponseData)
}

struct ResponseData {
    var tracks = [Track]()
    var albums =  [Album]()
    var artists =  [Artist]()
    var lyrics = String()
    
    func isEmpty() -> Bool {
        if tracks.isEmpty && albums.isEmpty && artists.isEmpty && lyrics.isEmpty {
            return true
        }
        return false
    }
    
    mutating func removeAll() {
        tracks.removeAll()
        albums.removeAll()
        artists.removeAll()
        lyrics = ""
    }
}

enum RequestType {
    case all
    case tracks
    case artists
    case album
    case topTracks
    case lyrics
}

struct Request {
    var type: RequestType
    var userData: String = ""
    var limit: Int = 25
}

class DataManager {
    var delegate: DataRequestDelegate?
    
    var request: Request? {
        didSet {
            if self.request?.type == .topTracks {
                getTopTracks(limit: self.request?.limit ?? 25, genreID: self.request?.userData ?? "0")
            } else if self.request?.type == .all, self.request != nil {
                getData(request: self.request!)
            } else if self.request?.type == .lyrics, self.request != nil {
                getLyrics(request: self.request!)
            } else if self.request?.type == .tracks {
                getData(request: self.request!)
            }
        }
    }
    
    func getTracksFromAlbum(albumID: Int) {
        let rootUrl = "https://api.deezer.com/"
        let path = "album/\(albumID)"
        guard let adress = (rootUrl+path).addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else { return }
        var responseData = ResponseData()
        
        DispatchQueue.main.async {
            Alamofire.request(adress,method: .get).responseJSON { (response) in
                switch response.result {
                case .success:
                    do {
                        if let data = response.data {
                            if let json = try JSON(data: data).dictionary {
                                guard response.data != nil else { return }
                                
                                var name: String?
                                var trackID: Int?
                                var artist: String?
                                var artistID: Int?
                                var album: String?
                                var albumID: Int?
                                var imageURL: String?
                                
                                artist = json["artist"]?["name"].string
                                artistID = json["artist"]?["id"].int
                                album = json["title"]?.string
                                albumID = json["id"]?.int
                                imageURL = json["cover_medium"]?.string
                                
                                guard json["tracks"]?["data"] != nil else {
                                    return }
                                for i in (json["tracks"]?["data"].count)! {
                                    name =  json["tracks"]?["data"][i]["title"].string
                                    trackID = json["tracks"]?["data"][i]["id"].int
                                    print(name, trackID)
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
                        self.delegate?.didReceiveData(responseData)
                    } catch {}
                case .failure: print(0)
                }
            }
        }
    }
    
    private func getLyrics(request: Request) {
        let rootUrl = "https://api.genius.com/"
        let path = "search?q=\(request.userData)"
        guard let adress = (rootUrl+path).addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else { return }
        let headers = ["Authorization":"Bearer 4Eo88FOlVGZpJ51inDGeC1zLfphPlHmD1PfQ_TVTsSM6iXwWRnLSUBjcu7vAS26k"]
        var responseData = ResponseData()
        
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
                                    //                print("HTML : \(myHTMLString)")
                                    let doc: Document = try SwiftSoup.parse(myHTMLString)
                                    let elements = try doc.getAllElements()
                                    let lyrics = try elements.select("div.lyrics").html().html2String
                                    responseData.lyrics = lyrics
                                } catch let error {
                                    print("Error: \(error)")
                                }
                            }
                        } }catch {}
                    self.delegate?.didReceiveData(responseData)
                case .failure: print("error")
                }
            }
        }
    }
    
    func getAlbums(artistName: String) {
        let rootUrl = "https://api.deezer.com/"
        let path = "search?q=\(artistName)&limit=250"
        
        var responseData = ResponseData()
        
        DispatchQueue.main.async {
            guard let adress = (rootUrl+path).addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else { return }
            Alamofire.request(adress,method: .get).responseJSON { (response) in
                switch response.result {
                case .success:
                    do {
                        if let data = response.data {
                            if let json = try JSON(data: data).dictionary {
                                guard response.data != nil else { return }
                                
                                var name: String?
                                var trackID: Int?
                                var artist: String?
                                var artistID: Int?
                                var album: String?
                                var albumID: Int?
                                var imageURL: String?
                                
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
                                        
                                        if !responseData.albums.contains(where: {
                                            (albumToCompare) -> Bool in
                                            let bool = (albumToCompare == album) ? true : false
                                            return bool
                                        }) { responseData.albums.append(album) }
                                    }
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
    
    private func getData(request: Request) {
        let rootUrl = "https://api.deezer.com/"
        let path = "search?q=\(request.userData)&limit=150"
        
        guard request.userData != "" else { return }
        
        var responseData = ResponseData()
        
        DispatchQueue.main.async {
            guard let adress = (rootUrl+path).addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else { return }
            Alamofire.request(adress,method: .get).responseJSON { (response) in
                switch response.result {
                case .success:
                    do {
                        if let data = response.data {
                            if let json = try JSON(data: data).dictionary {
                                guard response.data != nil else { return }
                                
                                var name: String?
                                var trackID: Int?
                                var artist: String?
                                var artistID: Int?
                                var album: String?
                                var albumID: Int?
                                var imageURL: String?
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
    
    private func getTopTracks(limit: Int, genreID: String) {
        let rootUrl = "https://api.deezer.com/"
        let path = "chart/\(genreID)"
        guard let adress = (rootUrl+path).addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else { return }
        var responseData = ResponseData()
        
        DispatchQueue.main.async {
            Alamofire.request(adress, method: .get).responseJSON { (response) in
                switch response.result {
                case .success:
                    do {
                        if let data = response.data {
                            if let json = try JSON(data: data).dictionary {
                                guard response.data != nil else { return }
                                
                                var name: String?
                                var trackID: Int?
                                var artist: String?
                                var artistID: Int?
                                var album: String?
                                var albumID: Int?
                                var imageURL: String?
                                
                                print(adress)
                                for i in (json["tracks"]?["data"].count)! {
                                    name =  json["tracks"]?["data"][i]["title"].string
                                    trackID = json["tracks"]?["data"][i]["id"].int
                                    artist = json["tracks"]?["data"][i]["artist"]["name"].string
                                    artistID = json["tracks"]?["data"][i]["artist"]["id"].int
                                    album = json["tracks"]?["data"][i]["title"].string
                                    albumID = json["tracks"]?["data"][i]["id"].int
                                    imageURL = json["tracks"]?["data"][i]["album"]["cover_medium"].string
                                    
                                    let track = Track(name: name!, id: trackID!, artist: artist!, artistID: artistID!, album: album!, albumID: albumID!, imageURL: imageURL ?? "" )
                                    if !responseData.tracks.contains(where: {
                                        (trackToCompare) -> Bool in
                                        let bool = (trackToCompare == track) ? true : false
                                        return bool
                                    }) { responseData.tracks.append(track) }
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
}

