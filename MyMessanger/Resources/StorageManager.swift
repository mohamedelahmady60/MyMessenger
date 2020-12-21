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
    public typealias UploadPicyureCompletion = (Result<String, Error>) -> Void
    
    /// upload picture to firebase strogae and return a closure with URL string to download
    public func uploadProfilePicture(with data: Data, fileName: String, completion: @escaping UploadPicyureCompletion) {
        
        // upload the data
        storage.child("images/\(fileName)").putData(data,
                                                   metadata: nil) { (metaData, error) in
            guard error == nil else {
                //failed
                print("Failed to upload data to firebase for pictures")
                completion(.failure(StorageErrors.failedToUpload))
                return
            }
            
            //get the image url
            self.storage.child("images/\(fileName)").downloadURL { (url, error) in
                guard let url = url else {
                    print("Failed to get download url")
                    completion(.failure(StorageErrors.failedToGetDownloadURL))
                    return
                }
                let urlString = url.absoluteString
                print("download url returned\(urlString)")
                completion(.success(urlString))
            }
        }
    }
    
    public enum StorageErrors: Error {
        case failedToUpload
        case failedToGetDownloadURL

    }
    
}

