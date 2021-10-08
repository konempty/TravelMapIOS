//
//  PhotoViewController.swift
//  TravelMap
//
//  Created by 김한빈 on 2021/10/08.
//

import UIKit
import ImageScrollView
import Photos
import MobileCoreServices

class PhotoViewController: UIViewController {


    static var photoData: BaseData!
    @IBOutlet weak var imageScrollView: ImageScrollView!
    @IBOutlet weak var backBtn: UIImageView!
    @IBOutlet weak var shareBtn: UIImageView!
    @IBOutlet weak var menuBtn: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()
        imageScrollView.setup()

        var isGIFImage = false
        if let identifier = PhotoViewController.photoData.asset!.value(forKey: "uniformTypeIdentifier") as? String {
            if identifier == kUTTypeGIF as String {
                isGIFImage = true
            }
        }
        let asset = PhotoViewController.photoData.asset!
        if (isGIFImage) {
            asset.getURL() { url in
                if let img = UIImage.gifImageWithURL(url!.absoluteString) {

                    self.imageScrollView.display(image: img)
                } else {
                    let alertController = UIAlertController(title: "문제가 발생했습니다.", message: "파일에 문제가 있습니다.", preferredStyle: .alert)

                    let okAction = UIAlertAction(title: "확인", style: .default) { (_) -> Void in

                        self.finish()

                    }

                    alertController.addAction(okAction)
                    self.present(alertController, animated: true, completion: nil)
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


        var gesture = UITapGestureRecognizer(target: self, action: #selector(backFun))
        backBtn.isUserInteractionEnabled = true
        backBtn.addGestureRecognizer(gesture)

        gesture = UITapGestureRecognizer(target: self, action: #selector(shareFun))
        shareBtn.isUserInteractionEnabled = true
        shareBtn.addGestureRecognizer(gesture)

        gesture = UITapGestureRecognizer(target: self, action: #selector(menuFun))
        menuBtn.isUserInteractionEnabled = true
        menuBtn.addGestureRecognizer(gesture)
    }

    @objc func backFun() {
        finish()
    }

    @objc func shareFun() {
    }

    @objc func menuFun() {
    }


}
