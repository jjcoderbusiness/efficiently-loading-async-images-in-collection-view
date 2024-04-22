//
//  ImageCacher.swift
//  AssignmentJagdish
//
//  Created by Jagdish Jangir on 21/04/24.
//

import UIKit

class ImageDiskStorage {
    
    let fileManager = FileManager.default
    
    func getDirectoryPath() -> String {
        let paths = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }
    
    func getImage(imageId: String)  -> UIImage? {
        let imagePath = (self.getDirectoryPath() as NSString).appendingPathComponent("\(imageId).jpg")
        if fileManager.fileExists(atPath: imagePath){
            print("Image retrrived from disk \(imageId)")
            return UIImage(contentsOfFile: imagePath)
        }
        return nil
    }
    
    func saveImageDocumentDirectory(imageId: String, image: UIImage) {
        let imagePath = (self.getDirectoryPath() as NSString).appendingPathComponent("\(imageId).jpg")
        let imageData = image.jpegData(compressionQuality: 1.0)
        if fileManager.createFile(atPath: imagePath as String, contents: imageData, attributes: nil) {
            print("Image saved on disk \(imageId)")
        }
    }
}
