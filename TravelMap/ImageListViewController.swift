//
//  ImageListViewController.swift
//  TravelMap
//
//  Created by 김한빈 on 2021/10/10.
//

import UIKit
import Photos

class ImageListViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var backBtn: UIImageView!
    static var imageList: [BaseData] = []
    var viewMap = [UIImageView: PHAsset]()


    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return max(2, ImageListViewController.imageList.count)
    }

    // CollectionView Cell의 Object
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "imageViewCell", for: indexPath) as! ImageViewCell

        if (indexPath.row < ImageListViewController.imageList.count) {

            let photoData = ImageListViewController.imageList[indexPath.row]
            //if (photoData.image == nil) {
            self.requestIamge(with: photoData.asset, thumbnailSize: CGSize(width: 240, height: 240)) { image in
                if (image != nil && self.viewMap[cell.image] == photoData.asset) {
                    //photoData.image = image
                    cell.image.image = image
                }
            }
            // print(cell.image.value(forKey: "asset"))
            viewMap[cell.image] = photoData.asset

            //} else {
            //   cell.image.image = photoData.image
            //}
            //cell.image.clipsToBounds = true
        }

        return cell
    }


    // CollectionView Cell의 Size
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width: CGFloat = collectionView.frame.width / 4 - 4.0

        return CGSize(width: width, height: width)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        4.0
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        4.0
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        PhotoViewController.startIdx = indexPath.row

        PhotoViewController.imageList = ImageListViewController.imageList

        ShowViewController("PhotoVC")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let gesture = UITapGestureRecognizer(target: self, action: #selector(backFun))
        backBtn.isUserInteractionEnabled = true
        backBtn.addGestureRecognizer(gesture)
    }

    @objc func backFun() {
        finish()
    }

    func refresh() {
        collectionView.reloadData()
        if (ImageListViewController.imageList.count == 0) {
            finish()
        }
    }


}
