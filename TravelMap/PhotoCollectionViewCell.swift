//
//  PhotoCollectionViewCell.swift
//  TravelMap
//
//  Created by 김한빈 on 2021/10/11.
//

import UIKit
import ImageScrollView
import MobileCoreServices
import Photos

class PhotoCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var imageScrollView: ImageScrollView!
    var photoData: BaseData!

    @IBOutlet weak var playView: UIView!

    func setImage() {
        imageScrollView.setup()
        imageScrollView.imageContentMode = .aspectFit
        //imageScrollView.delegate = self
        var isGIFImage = false
        if let identifier = photoData.asset!.value(forKey: "uniformTypeIdentifier") as? String {
            if identifier == kUTTypeGIF as String {
                isGIFImage = true
            }
        }
        if (photoData.isVideo.value == true) {
            playView.isHidden = false
        } else {
            playView.isHidden = true
        }

        let asset = photoData.asset!
        if (isGIFImage) {
            asset.getURL() { url in
                if let img = UIImage.gifImageWithURL(url!.absoluteString) {

                    self.imageScrollView.display(image: img)
                } else {
                    let alertController = UIAlertController(title: "문제가 발생했습니다.", message: "파일에 문제가 있습니다.", preferredStyle: .alert)

                    let okAction = UIAlertAction(title: "확인", style: .default) { (_) -> Void in

                        //self.finish()

                    }

                    alertController.addAction(okAction)
                    //self.present(alertController, animated: true, completion: nil)
                }
            }
        } else {

            let requestImageOption = PHImageRequestOptions()
            requestImageOption.deliveryMode = PHImageRequestOptionsDeliveryMode.highQualityFormat

            let manager = PHImageManager.default()
            manager.requestImage(for: asset, targetSize: PHImageManagerMaximumSize, contentMode: PHImageContentMode.default, options: requestImageOption) { image, _ in

                self.imageScrollView.display(image: image!)
            }
        }
    }
}
