//
//  ViewController.swift
//  AssignmentJagdish
//
//  Created by Jagdish Jangir on 21/04/24.
//

import UIKit
import Combine

class ViewController: UIViewController {
    
    private var collectionView: UICollectionView!
    
    private var cancellables = Set<AnyCancellable>()
    
    private var data: [Thumbnail] = []
    
    private let indicator: UIActivityIndicatorView  = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.color = .red
        indicator.hidesWhenStopped = true
        return indicator
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.minimumLineSpacing = 2.0
        flowLayout.minimumInteritemSpacing = 2.0
        let itemWidth = floor((self.view.bounds.width - 4.0)/3.0)
        let itemHeight = itemWidth
        flowLayout.itemSize = .init(width: itemWidth, height: itemHeight)
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        
        collectionView.addToSuperView(superView: self.view, margin: .init())
        collectionView.register(ImageViewCollectionViewCell.self, forCellWithReuseIdentifier: ImageViewCollectionViewCell.id)
        collectionView.allowsSelection = false
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
        self.view.addSubview(indicator)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            indicator.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            indicator.centerYAnchor.constraint(equalTo: self.view.centerYAnchor)
        ])
        indicator.startAnimating()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        ServerConnect.shared.getData()
            .sink { completion in
                switch completion {
                case .finished:
                    self.indicator.stopAnimating()
                    self.collectionView.reloadData()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5){
                        self.collectionView.visibleCells.forEach { item in
                            (item as? ImageViewCollectionViewCell)?.loadImage()
                        }
                    }
                case .failure(let error):
                    let alert = UIAlertController(title: "Error", message: "\(error.localizedDescription)", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
            } receiveValue: { images in
                self.data = images
            }.store(in: &cancellables)
    }
    
}

extension ViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.data.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ImageViewCollectionViewCell.id, for: indexPath) as! ImageViewCollectionViewCell
        
        let model =  self.data[indexPath.row]
        cell.model = model
        if let fetchedData = ImageFetcher.shared.fetchedData(for: model.id  ?? "") {
            cell.setImage(image: fetchedData)
        }  else {
            cell.setImage(image: nil)
        }
        return cell
    }
}

extension ViewController: UICollectionViewDelegate {
    
    func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        let  visibleCells = self.collectionView.visibleCells
        DispatchQueue.global(qos: .userInteractive).async {
            visibleCells.forEach { item in
                (item as? ImageViewCollectionViewCell)?.cancelDownload()
            }
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let  visibleCells = self.collectionView.visibleCells
        DispatchQueue.global(qos: .utility).async {
            visibleCells.forEach { item in
                (item as? ImageViewCollectionViewCell)?.loadImage()
            }
        }
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        let  visibleCells = self.collectionView.visibleCells
        DispatchQueue.global(qos: .utility).async {
            visibleCells.forEach { item in
                (item as? ImageViewCollectionViewCell)?.loadImage()
            }
        }
    }
}

