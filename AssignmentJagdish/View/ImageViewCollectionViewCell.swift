//
//  ImageViewCollectionViewCell.swift
//  AssignmentJagdish
//
//  Created by Jagdish Jangir on 21/04/24.
//

import UIKit


struct Margin {
    let top: CGFloat
    let bottom: CGFloat
    let leading: CGFloat
    let trailing: CGFloat
    
    init(top: CGFloat = 0, bottom: CGFloat = 0, leading: CGFloat = 0, trailing: CGFloat = 0) {
        self.top = top
        self.bottom = bottom
        self.leading = leading
        self.trailing = trailing
    }
}

class ImageViewCollectionViewCell: UICollectionViewCell {
    
    static let id: String = "ImageViewCollectionViewCell"
    
    var model: Thumbnail?
    
    var isImageSet = false
    
    private let imageView: UIImageView = {
       let imageView = UIImageView()
        imageView.contentMode = .center
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        imageView.addToSuperView(superView: self, margin: .init())
        layer.borderColor = UIColor.black.cgColor
        layer.borderWidth = 1.0
        layer.cornerRadius =  2.0
    }
    
    func setImage(image: UIImage?) {
        guard !isImageSet else  {return}
        isImageSet = image !=  nil
        self.imageView.image = image ?? UIImage(named: "placeHolder")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        isImageSet = false
        print("Cell Reused")
    }
    
    func loadImage() {
        guard !isImageSet else  {return}
        ImageFetcher.shared.fetchAsync(model?.id ?? "", imageURL: model?.downloadURL ?? "") { image in
            DispatchQueue.main.async {
                self.setImage(image: image)
            }
        }
    }
    
    func cancelDownload() {
        ImageFetcher.shared.cancelFetch(model?.id ?? "")
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

extension  UIView {
    func addToSuperView(superView: UIView, margin: Margin) {
        superView.addSubview(self)
        self.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.leadingAnchor.constraint(equalTo: superView.leadingAnchor, constant: margin.leading),
            self.trailingAnchor.constraint(equalTo: superView.trailingAnchor, constant: -margin.trailing),
            self.topAnchor.constraint(equalTo: superView.topAnchor, constant: margin.top),
            self.bottomAnchor.constraint(equalTo: superView.bottomAnchor, constant: -margin.bottom)
        ])
    }
}
