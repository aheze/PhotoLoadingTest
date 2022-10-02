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
    var layout: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        layout.itemSize = CGSize(width: 80, height: 80)
        return layout
    }()

    lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
    var fetchResult: PHFetchResult<PHAsset>?

    let configuration = UICollectionView.CellRegistration { cell, indexPath, itemIdentifier in
        cell.contentConfiguration = UIHostingConfiguration {
            Cell(model: itemIdentifier)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(collectionView)
        collectionView.pinEdgesToSuperview()
        collectionView.dataSource = self
//        collectionView.register(Cell.self, forCellWithReuseIdentifier: "Cell")
        
        

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
//        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! Cell
        let model = CellModel()
        let cell = collectionView.dequeueConfiguredReusableCell(using: configuration, for: indexPath, item: model)
//        if let imageRequestID = cell.imageRequestID {
//            PHImageManager.default().cancelImageRequest(imageRequestID)
//            cell.imageRequestID = nil
//        }
//
        if let fetchResult {
            let asset = fetchResult.object(at: indexPath.item)
            let options = PHImageRequestOptions()
            options.deliveryMode = .opportunistic

            let imageRequestID = PHImageManager.default().requestImage(
                for: asset,
                targetSize: .init(width: cell.bounds.width, height: cell.bounds.height),
                contentMode: .aspectFill,
                options: options
            ) { image, _ in
                DispatchQueue.main.async {
//                    cell.imageView.image = image
                    model.image = image
                }
            }
//            cell.imageRequestID = imageRequestID
        }
        return cell
    }
}

class CellModel: ObservableObject {
    @Published var image: UIImage?
}
struct Cell: View {
    @ObservedObject var model: CellModel
    
    var body: some View {
        VStack {
            if let image = model.image {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .clipped()
            }
        }
    }
}

// class Cell: UICollectionViewCell {
//    var imageView = UIImageView()
//    var imageRequestID: PHImageRequestID?
//
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//
//        addSubview(imageView)
//        imageView.pinEdgesToSuperview()
//    }
//
//    @available(*, unavailable)
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
// }

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
