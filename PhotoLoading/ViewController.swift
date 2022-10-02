//
//  ViewController.swift
//  PhotoLoading
//
//  Created by A. Zheng (github.com/aheze) on 9/30/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import Photos
import SwiftUI

class ViewController: UIViewController {
    var fetchResult: PHFetchResult<PHAsset>?

    var layout: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
//        layout.itemSize = CGSize(width: 100, height: 100)
        layout.itemSize = CGSize(width: 30, height: 30) /// lower lengths = more cells
        return layout
    }()

    lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)

    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(collectionView)
        collectionView.pinEdgesToSuperview()
        collectionView.dataSource = self
        collectionView.register(Cell.self, forCellWithReuseIdentifier: "Cell")

        switch PHPhotoLibrary.authorizationStatus(for: .readWrite) {
        case .limited, .authorized:
            fetchAssets()
        default:
            PHPhotoLibrary.requestAuthorization(for: .readWrite) { status in
                switch status {
                case .authorized, .limited:
                    self.fetchAssets()
                default:
                    print("Allow permissions in Settings.")
                }
            }
        }
    }

    func fetchAssets() {
        fetchResult = PHAsset.fetchAssets(with: nil)
        collectionView.reloadData()
    }
}

extension ViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return fetchResult?.count ?? 0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! Cell

        if let fetchResult {
            let asset = fetchResult.object(at: indexPath.item)
            let options = PHImageRequestOptions()
            options.deliveryMode = .opportunistic
            let length = cell.bounds.width * UIScreen.main.scale

            if let imageRequestID = cell.imageRequestID {
                PHImageManager.default().cancelImageRequest(imageRequestID)
                cell.imageRequestID = nil
            }

            DispatchQueue.global(qos: .userInitiated).async {
                let imageRequestID = PHImageManager.default().requestImage(
                    for: asset,
                    targetSize: .init(width: length, height: length),
                    contentMode: .aspectFill,
                    options: nil
                ) { image, _ in
                    DispatchQueue.main.async {
                        cell.imageView.image = image
                    }
                }
                cell.imageRequestID = imageRequestID
            }
        }
        return cell
    }
}

class Cell: UICollectionViewCell {
    var imageView = UIImageView()
    var imageRequestID: PHImageRequestID?

    override init(frame: CGRect) {
        super.init(frame: frame)

        addSubview(imageView)
        imageView.pinEdgesToSuperview()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension UIView {
    func pinEdgesToSuperview() {
        guard let superview = superview else { return }
        translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            topAnchor.constraint(equalTo: superview.topAnchor),
            rightAnchor.constraint(equalTo: superview.rightAnchor),
            bottomAnchor.constraint(equalTo: superview.bottomAnchor),
            leftAnchor.constraint(equalTo: superview.leftAnchor)
        ])
    }
}
