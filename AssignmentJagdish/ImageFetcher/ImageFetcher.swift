//
//  ImageFetcher.swift
//  AssignmentJagdish
//
//  Created by Jagdish Jangir on 21/04/24.
//

import UIKit


final class ImageFetcher {
    
    static let shared = ImageFetcher()
    
    private let serialAccessQueue = OperationQueue()
    private let fetchQueue = OperationQueue()
    
    private var completionHandlers = [String: [(UIImage?) -> Void]]()
    
    private let diskStorage = ImageDiskStorage()
    
    private var cache = [String: UIImage]()
    
    private init() {
        serialAccessQueue.maxConcurrentOperationCount = 1
    }
    
    func fetchAsync(_ identifier: String, imageURL: String ,completion: ((UIImage?) -> Void)? = nil) {
        serialAccessQueue.addOperation {
            if let completion = completion {
                let handlers = self.completionHandlers[identifier] ?? []
                self.completionHandlers[identifier] = handlers + [completion]
            }
            
            self.fetchData(for: identifier, imageURL: imageURL)
        }
    }
    
    func fetchedData(for identifier: String) -> UIImage? {
        if let cachedImage = cache[identifier] {
            return cachedImage
        } else if let diskImage = diskStorage.getImage(imageId: identifier) {
            cache[identifier] = diskImage
            return diskImage
        }else {
            return nil
        }
    }
    
    func cancelFetch(_ identifier: String) {
        serialAccessQueue.addOperation {
            self.fetchQueue.isSuspended = true
            defer {
                self.fetchQueue.isSuspended = false
            }
            
            self.operation(for: identifier)?.cancel()
            self.completionHandlers[identifier] = nil
        }
    }
    
    
    private func fetchData(for identifier: String, imageURL: String) {
        
        guard operation(for: identifier) == nil else { return }
        
        if let data = fetchedData(for: identifier) {
            invokeCompletionHandlers(for: identifier, with: data)
        } else {
            
            let operation = ImageFetcherOperation(identifier: identifier, imageURL: imageURL)
            
            operation.completionBlock = { [weak operation] in
                guard let fetchedData = operation?.imageData else { return }
                guard let image = UIImage(data: fetchedData) else { return }
                guard let compressImagesData = image.jpegData(compressionQuality: 0.5) else { return }
                guard let compressedImage = UIImage(data: compressImagesData) else { return }
                self.cache[identifier] = compressedImage
                self.diskStorage.saveImageDocumentDirectory(imageId: identifier, image: compressedImage)
                self.serialAccessQueue.addOperation {
                    self.invokeCompletionHandlers(for: identifier, with: compressedImage)
                }
            }
            
            fetchQueue.addOperation(operation)
        }
    }
    
    
    private func operation(for identifier: String) -> ImageFetcherOperation? {
        
        for op in  fetchQueue.operations {
            if  let fetchOperation = op as? ImageFetcherOperation {
                if !fetchOperation.isCancelled && fetchOperation.identifier == identifier {
                    return fetchOperation
                }
            }
        }
        return nil
    }
    
    private func invokeCompletionHandlers(for identifier: String, with fetchedData: UIImage) {
        let completionHandlers = self.completionHandlers[identifier] ?? []
        self.completionHandlers[identifier] = nil
        for completionHandler in completionHandlers {
            completionHandler(fetchedData)
        }
    }
}
