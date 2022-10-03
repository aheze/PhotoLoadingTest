# PhotoLoadingTest

Demo repo of a photo gallery with lag during scroll.

The lag gets worse when the cells are smaller.

All code is in [ViewController.swift](https://github.com/aheze/PhotoLoadingTest/blob/main/PhotoLoading/ViewController.swift)

Video:

https://user-images.githubusercontent.com/49819455/193663240-098db1b4-bd55-4c8a-ac65-19b666654ba6.mp4

Deleting the `requestImage` call results in much smooth scrolling.

```swift
func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! Cell

    if let fetchResult {
        /// Cancel the request if the cell was reused.
        if let imageRequestID = cell.imageRequestID {
            imageManager.cancelImageRequest(imageRequestID)
            cell.imageRequestID = nil
        }

        DispatchQueue.global(qos: .default).async {
            let asset = fetchResult.object(at: indexPath.item)

            /// Request the image. This is where the lag happens - if you delete this, scrolling will be smooth again.
            let imageRequestID = self.imageManager.requestImage(
                for: asset,
                targetSize: self.thumbnailSize,
                contentMode: .aspectFill,
                options: self.options
            ) { image, _ in

                DispatchQueue.main.async {
                    cell.imageView.image = image
                }
            }

            cell.imageRequestID = imageRequestID /// Save the ID for canceling if necessary
        }
    }
    return cell
}
```

