//
//  PersitenceManager.swift
//  Lyrify
//
//  Created by xcv on 16/02/2021.
//  Copyright © 2021 Kamil Bloch. All rights reserved.
//

import Foundation

enum PersistenceActionType {
    case add, remove
}

enum PersistenceManager {
    static private let defaults = UserDefaults.standard
    
    enum Keys { static let liked = "liked" }
    
    static func updateWidth(trackData: Track, actionType: PersistenceActionType, completed: @escaping (LYError?) -> Void) {
        retrieveLiked { result in
            switch result {
            case .success(var liked):
                switch actionType {
                case .add:
                    guard !liked.contains(trackData) else {
                        completed(.alreadyInFavorites)
                        return
                    }
                    liked.append(trackData)
                case .remove:
                    liked.removeAll { $0.id == trackData.id }
                }
                completed(save(liked: liked))

            case .failure(let error):
                completed(error as? LYError)
            }
        }
    }
    
    static func retrieveLiked(completed: @escaping (Result<[Track], LYError>) -> Void) {
        guard let likedData = defaults.object(forKey: Keys.liked) as? Data else {
            completed(.success([]))
            return
        }
        
        do {
            let decoder = JSONDecoder()
            let liked = try decoder.decode([Track].self, from: likedData)
            completed(.success(liked))
        } catch let error as NSError {
            print(error.localizedDescription)
            completed(.failure(.unableToFavorite))
        }
    }
    
    static func save(liked: [Track]) -> LYError? {
        do {
            let encoder = JSONEncoder()
            let encodedLiked = try encoder.encode(liked)
            defaults.setValue(encodedLiked, forKey: Keys.liked)
            return nil
        } catch {
            return .unableToFavorite
        }
    }
}

