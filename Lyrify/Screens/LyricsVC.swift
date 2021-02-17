//
//  LyricsViewController.swift
//  Lyrify
//
//  Created by Kamil Bloch on 01/12/2019.
//  Copyright © 2019 Kamil Bloch. All rights reserved.
//
import UIKit

class LyricsVC: UIViewController {
    
    // MARK: - Data
    var trackData: Track? {
        didSet {
            showAllViews()
        }
    }
    let dataManager = DataManager()
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dataManager.delegate = self

        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        hasLaunchPop()
    }
    
    // MARK: Download lyrics
    func getLyrics(track: Track) {
        dataManager.getLyrics(track: track)
    }
    
    func configure(track: Track, image: UIImage) {
        trackData = track

        imageView.image = image
        addBackground(image: image)
        titleTrack.text = track.name
        album.text = track.album
        artist.text = track.artist

        getLyrics(track: track)
    }
    
    // MARK: Add song if like button was tapped
    @IBAction func didLiked(_ sender: Any) {
        PersistenceManager.updateWidth(trackData: trackData!, actionType: .add) { (error) in
            print(error)
        }
    }
    
    // MARK: Get liked tracks from UserDefaults
    func likedTracks(completion: @escaping ([Track]) -> Void) {
        
        PersistenceManager.retrieveLiked { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let liked):
                completion(liked)
            case .failure(let error):
                print(error)
            }
        }

    }
    
    @IBAction func didTappedDeezer(_ sender: UIButton) {
        Opener.openDeezerWithPath(path: "deezer://www.deezer.com/track/\(trackData?.id)?autoplay=true")
    
    }
    
    @objc func openArtist() {
        let artist = Artist(name: self.trackData!.artist, id: self.trackData!.artistID, albums: [], imageURL: self.trackData!.imageURL)
        Helper.presentArtistVC(artist: artist, parentVC: self, imageLoader: imageLoader)
    }
    
    @objc func openAlbum() {
        Helper.presentAlbumVC(albumID: self.trackData!.albumID, albumImage: self.imageView.image!, albumName: self.trackData!.album, parentVC: self, imageLoader: imageLoader)
    }
    
    // MARK: UI functions

    func setupUI() {
        scrollView.fadeView(style: .bottom, percentage: 0.25)
        showActivityIndicator()
        
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
        
        UserDefaults.standard.set(true, forKey: "showPop")
    }
    
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

    func hasLaunchPop() {
        let isshowPop: Bool = UserDefaults.standard.bool(forKey: "showPop")
        if isshowPop == true  {
            hideAllViews()
            UserDefaults.standard.set(false, forKey: "showPop")
        }
    }
    
}

//MARK: - DataRequestDelegate
extension LyricsVC: DataRequestDelegate {
    func didReceiveLyrics(lyrics: String) {
        lyricsTextView.text = "\n"+lyrics
        hideActivityIndicator()
    }
    
    func didReceivedTracks(tracks: [Track]) { }
    func didReceivedAlbums(albums: [Album]) { }
    func didReceiveData(_ data: ResponseData) { }
}
