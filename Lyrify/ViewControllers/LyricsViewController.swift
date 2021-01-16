//
//  LyricsViewController.swift
//  Lyrify
//
//  Created by Kamil Bloch on 01/12/2019.
//  Copyright © 2019 Kamil Bloch. All rights reserved.
//
import UIKit

class LyricsViewController: UIViewController {
    // MARK: - Data/API
    var informations: Track? {
        didSet {
            showAllViews()
        }
    }
    let data = DataManager()
    let imageLoader = ImageCacheLoader()
    
    // MARK: - UI
    @IBOutlet weak var backgroundTopView: UIView!
    @IBOutlet weak var favouriteButton: UIButton!
    @IBOutlet weak var deezerButton: UIButton!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var artist: UILabel!
    @IBOutlet weak var titleTrack: UILabel!
    @IBOutlet weak var album: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var lyricsTextView: UITextView!
    @IBOutlet weak var containerView: UIView!
    var blurEffectView: UIVisualEffectView?
    
    @IBAction func didLiked(_ sender: Any) {
        guard let informations = informations else { return }
        addToLikedTracks(trackData: TrackData(name: informations.name, id: String(informations.id), artist: informations.artist, artistID: String(informations.artistID), album: informations.album, albumID: String(informations.albumID), imageURL: informations.imageURL))
        
        /*
         
         let name: String
         let id: Int
         let artist: String
         let artistID: Int
         let album: String
         let albumID: Int
         
         let imageURL: String
         */
        //
        
    }
    
    func addToLikedTracks(trackData: TrackData) {
        var likedTracks = self.likedTracks()
        
        if !likedTracks.contains(trackData) {
            likedTracks.append(trackData)
            let propertylistSongs = likedTracks.map{ $0.propertyListRepresentation }
            UserDefaults.standard.set(propertylistSongs, forKey: "likedTracks")
        }
        
        
    }
    
    func likedTracks() -> [TrackData] {
        var currentTracks: [TrackData] = [TrackData]()
        if let propertylistSongs = UserDefaults.standard.array(forKey: "likedTracks") as? [[String:String]] {
            currentTracks = propertylistSongs.compactMap{ TrackData(dictionary: $0) }
        }
        print(currentTracks)
        return currentTracks
    }
    
    @IBAction func didTappedDeezer(_ sender: UIButton) {
        guard let informations = informations else { return }
        if let url = URL(string: "deezer://www.deezer.com/track/\(informations.id)?autoplay=true") {
            print(url)
            UIApplication.shared.open(url)
        }
    }
    
    @objc func openArtist() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let artistVC = storyboard.instantiateViewController(withIdentifier: "ArtistViewController") as! ArtistViewController
        present(artistVC, animated:true) {
            artistVC.data.getAlbums(artistName: self.informations!.artist)
        }
    }
    
    @objc func openAlbum() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let albumVC = storyboard.instantiateViewController(withIdentifier: "AlbumViewController") as! AlbumViewController
        present(albumVC, animated:true) {
            albumVC.data.getTracksFromAlbum(albumID: self.informations!.albumID)
            albumVC.albumImage.image = self.imageView.image
            albumVC.albumName.text = self.informations?.album
        }
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        data.delegate = self
        setupUI()
        
        scrollView.fadeView(style: .bottom, percentage: 0.25)
        showActivityIndicator()
        UserDefaults.standard.set(true, forKey: "showPop")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        hasLaunchPop()
    }
}

//MARK: - DataRequestDelegate
extension LyricsViewController: DataRequestDelegate {
    func didReceiveData(_ data: ResponseData) {
        lyricsTextView.text = "\n"+data.lyrics
        hideActivityIndicator()
    }
}

//MARK: - Other functions
extension LyricsViewController {
    func addBackground(image: UIImage) {
        let backgroundImage = UIImageView(frame: backgroundTopView.bounds)
        backgroundImage.contentMode = UIView.ContentMode.scaleToFill
        backgroundImage.image = image
        self.backgroundTopView.insertSubview(backgroundImage, at: 0)
        self.backgroundTopView.addBlurEffect()
        
        backgroundTopView.alpha = 0
        UIView.animate(withDuration: 0.5) {
            self.backgroundTopView.alpha = 1
        }
    }
    
    func hideAllViews() {
        imageView.isHidden = true
        album.isHidden = true
        artist.isHidden = true
        titleTrack.isHidden = true
        favouriteButton.isHidden = true
        deezerButton.isHidden = true
    }
    
    func showAllViews() {
        imageView.isHidden = false
        album.isHidden = false
        artist.isHidden = false
        titleTrack.isHidden = false
        favouriteButton.isHidden = false
        deezerButton.isHidden = false
    }
    
    func setupUI() {
        blurEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
        fixNavigationBar()
        
        //buttons
        deezerButton.layer.cornerRadius = 5
        deezerButton.layer.borderWidth = 1
        deezerButton.layer.borderColor = UIColor.clear.cgColor
        
        favouriteButton.layer.cornerRadius = 5
        favouriteButton.layer.borderWidth = 1
        favouriteButton.layer.borderColor = UIColor.clear.cgColor
        
        imageView.layer.cornerRadius = 5
        imageView.layer.borderWidth = 1
        imageView.layer.borderColor = UIColor.clear.cgColor
        
        //make labels clickable
        let openAlbum = UITapGestureRecognizer(target: self, action: #selector(self.openAlbum))
        let openArtist = UITapGestureRecognizer(target: self, action: #selector(self.openArtist))
        album.addGestureRecognizer(openAlbum)
        artist.addGestureRecognizer(openArtist)
    }
    
    func hasLaunchPop() {
        let isshowPop: Bool = UserDefaults.standard.bool(forKey: "showPop")
        if isshowPop == true  {
            hideAllViews()
            UserDefaults.standard.set(false, forKey: "showPop")
        }
    }
}
