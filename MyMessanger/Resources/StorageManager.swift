//
//  StorageManager.swift
//  MyMessanger
//
//  Created by Mo Elahmady on 20/12/2020.
//

import Foundation
import FirebaseStorage

final class StrorageManager {
    
    static let shared = StrorageManager()
    private let storage = Storage.storage().reference()
    
    //type alias to closure that uploadProfilePicture function returns
    public typealias UploadPictureCompletion = (Result<String, Error>) -> Void
    
    
    
    /// upload the profile picture to firebase strogae and return a closure with URL string to download
    public func uploadProfilePicture(with data: Data, fileName: String, completion: @escaping UploadPictureCompletion) {
        
        // 1- upload the image data
        storage.child("images/\(fileName)").putData(data, metadata: nil, completion: { [weak self] metaData, error in
            guard error == nil else {
                completion(.failure(StorageErrors.failedToUpload))
                return
            }
            // 2- get download url
            self?.storage.child("images/\(fileName)").downloadURL(completion: { url, error in
                
                guard let downloadUrl = url else {
                    completion(.failure(StorageErrors.failedToGetDownloadURL))
                    return
                }
                let downloadUrlString = downloadUrl.absoluteString
                completion(.success(downloadUrlString))
            })
        })
    }
    
    
    
    /// upload a picture  as a message to firebase strogae and return a closure with URL string to download
    public func uploadMessagePhoto(data: Data, fileName: String, completion: @escaping UploadPictureCompletion) {
        
        // 1- upload the image data
        storage.child("message_images/\(fileName)").putData(data, metadata: nil, completion: { [weak self] metaData, error in
            guard error == nil else {
                completion(.failure(StorageErrors.failedToUpload))
                return
            }
            // 2- get download url
            self?.storage.child("message_images/\(fileName)").downloadURL(completion: { url, error in
                guard let downloadUrl = url else {
                    completion(.failure(StorageErrors.failedToGetDownloadURL))
                    return
                }
                let downloadUrlString = downloadUrl.absoluteString
                completion(.success(downloadUrlString))
            })
        })
    }

    
    /// upload a Video  as a message to firebase strogae and return a closure with URL string to download
    public func uploadMessageVideo(fileUrl: URL, fileName: String, completion: @escaping UploadPictureCompletion) {
        
        // 1- upload the video
        storage.child("message_videos/\(fileName)").putFile(from: fileUrl, metadata: nil, completion: { [weak self] metaData, error in
            guard error == nil else {
                completion(.failure(StorageErrors.failedToUpload))
                return
            }
            // 2- get download url
            self?.storage.child("message_videos/\(fileName)").downloadURL(completion: { url, error in
                guard let downloadUrl = url else {
                    completion(.failure(StorageErrors.failedToGetDownloadURL))
                    return
                }
                let downloadUrlString = downloadUrl.absoluteString
                completion(.success(downloadUrlString))
            })
        })
    }

    
    /// get the download url
    public func downloadURL(path: String, completion: @escaping (Result<URL, Error>) -> Void) {
        self.storage.child(path).downloadURL { (url, error) in
            guard let url = url else {
                print("Failed to get download url")
                completion(.failure(StorageErrors.failedToGetDownloadURL))
                return
            }
            completion(.success(url))
        }
    }
    
}// end of class


//MARK: - StorageErrors enum
public enum StorageErrors: Error {
    case failedToUpload
    case failedToGetDownloadURL
    
}

