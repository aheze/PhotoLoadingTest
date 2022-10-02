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
        layout.itemSize = CGSize(width: 100, height: 100)
//        layout.itemSize = CGSize(width: 30, height: 30) /// lower lengths = more cells
        return layout
    }()

    let cellRegistration = UICollectionView.CellRegistration { cell, indexPath, itemIdentifier in
        cell.contentConfiguration = UIHostingConfiguration {
            CellView(model: itemIdentifier)
        }
    }

    lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)

    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(collectionView)
        collectionView.pinEdgesToSuperview()
        collectionView.dataSource = self

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
        let model = CellViewModel()
        let cell = collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: model)

        if let fetchResult {
            let asset = fetchResult.object(at: indexPath.item)
            let options = PHImageRequestOptions()
            options.deliveryMode = .opportunistic

            PHImageManager.default().requestImage(
                for: asset,
                targetSize: .init(width: cell.bounds.width, height: cell.bounds.height),
                contentMode: .aspectFill,
                options: options
            ) { image, _ in

                model.image = image
            }
        }
        return cell
    }
}

class CellViewModel: ObservableObject {
    @Published var image: UIImage?
}

struct CellView: View {
    @ObservedObject var model: CellViewModel

    var body: some View {
        VStack {
            if let image = model.image {
                Color.clear.overlay {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                }
                .clipped()
            }
        }
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
