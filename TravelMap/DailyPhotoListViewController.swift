//
//  DailyPhotoListViewController.swift
//  TravelMap
//
//  Created by 김한빈 on 2021/04/18.
//

import UIKit

class DailyPhotoListViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    @IBOutlet weak var collectionView: UICollectionView!
    static var instance: DailyPhotoListViewController!
    var dailyKey: Array<Date> = []

    // CollectionView item 개수

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        dailyKey = Array(PhotoService.imageListDaily.keys).sorted() { d1, d2 in
            return d1 > d2
        }
        return PhotoService.imageListDaily.count
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {

        return max(2, PhotoService.imageListDaily[dailyKey[section]]!.count)
    }

    // CollectionView Cell의 Object
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "imageViewCell", for: indexPath) as! ImageViewCell

        if (indexPath.row < PhotoService.imageListDaily[dailyKey[indexPath.section]]!.count) {

            let photoData = PhotoService.imageListDaily[dailyKey[indexPath.section]]![indexPath.row]
            if (photoData.image == nil) {
                self.requestIamge(with: photoData.asset, thumbnailSize: CGSize(width: 240, height: 240)) { image in
                    if (image != nil) {
                        photoData.image = image
                        cell.image.image = photoData.image
                    }
                }

            } else {
                cell.image.image = photoData.image
            }
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

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "dateTimeReusableView", for: indexPath) as! DateTimeReusableView
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy년 MM월 dd일"

        header.label.text = dateFormatter.string(from: dailyKey[indexPath.section])
        return header
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        PhotoViewController.photoData = PhotoService.imageListDaily[dailyKey[indexPath.section]]![indexPath.row]
        ShowViewController("PhotoVC")
    }

    override func viewDidLoad() {
        DailyPhotoListViewController.instance = self
    }

    func refresh() {
        collectionView.reloadData()
    }
}
