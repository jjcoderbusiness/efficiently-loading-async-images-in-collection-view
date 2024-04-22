//
//  ImageFetcherOperation.swift
//  AssignmentJagdish
//
//  Created by Jagdish Jangir on 21/04/24.
//

import Foundation

class ImageFetcherOperation: Operation {
   
    let identifier: String
    let imageURL: String
    
    private let stateQueue = DispatchQueue(label: "AsynchronousOperationQueue", attributes: .concurrent)
    
    enum State: String {
        case ready = "Ready"
        case executing = "Executing"
        case finished = "Finished"
        case cancelled = "Cancelled"
        var keyPath: String { return "is" + self.rawValue }
    }
    
    private var stateStore: State = .ready
    
    override var isConcurrent: Bool {
        return true
    }
    
    override var isCancelled: Bool {
        return self.stateStore == .cancelled
    }
    
    override var isFinished: Bool {
        return self.stateStore == .finished
    }
    
    override var isExecuting: Bool {
        return self.stateStore == .executing
    }
    
    override var isReady: Bool {
        return self.stateStore == .ready
    }
    
    override func cancel() {
        self.stateStore = .cancelled
        print("Download cancelled \(identifier)")
    }
    
    var state: State {
            get {
                stateQueue.sync {
                    return stateStore
                }
            }
            set {
                stateQueue.sync(flags: .barrier) {
                    stateStore = newValue
                }
            }
        }
    
    
    private(set) var imageData: Data?
    
    init(identifier: String, imageURL: String) {
        self.identifier = identifier
        self.imageURL = imageURL
    }
    
    override func start() {
        guard !self.isCancelled else { return }
        self.stateStore = .executing
        ServerConnect.shared.downloadImageDataTask(url: imageURL) { data in
            guard !self.isCancelled else { return }
            self.imageData = data
            self.stateStore = .finished
            self.completionBlock?()
        }?.resume()
    }
}
