//
//  ViewController.swift
//  PhotoLoading
//
//  Created by A. Zheng (github.com/aheze) on 9/30/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import Photos
import SwiftUI

enum Section {
    case main
}

class ViewController: UIViewController {
    var layout: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        layout.itemSize = CGSize(width: 40, height: 40)
        return layout
    }()

    lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
    var fetchResult: PHFetchResult<PHAsset>?

    lazy var dataSource = UICollectionViewDiffableDataSource<Section, String>(collectionView: collectionView) { [weak self] collectionView, indexPath, itemIdentifier in
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! Cell
        guard let self = self else { return cell }

        if cell.imageRequestID != nil {
            cell.imageRequestID = nil
        }

        if let fetchResult = self.fetchResult {
            let asset = fetchResult.object(at: indexPath.item)
            let imageRequestID = PHImageManager.default().requestImage(
                for: asset,
                targetSize: .init(width: 5, height: 5),
                contentMode: .default,
                options: nil
            ) { image, _ in
                cell.imageView.image = image
            }
            cell.imageRequestID = imageRequestID
        }

        return cell
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(collectionView)
        collectionView.pinEdgesToSuperview()
        collectionView.register(Cell.self, forCellWithReuseIdentifier: "Cell")

        _ = dataSource

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

        var snapshot = NSDiffableDataSourceSnapshot<Section, String>()
        snapshot.appendSections([.main])
        let itemIdentifiers = (0 ..< fetchResult!.count).map { _ in UUID().uuidString }
        snapshot.appendItems(itemIdentifiers, toSection: .main)

        dataSource.apply(snapshot, animatingDifferences: false)
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
