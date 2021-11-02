//
//  AlbumViewController.swift
//  TravelMap
//
//  Created by 김한빈 on 2021/04/18.
//

import UIKit
import Photos

class AlbumViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    @IBOutlet weak var collectionView: UICollectionView!
    var keys: [String]!
    static var instance: AlbumViewController!
    var labelSize = 0
    var viewMap = [UIImageView: PHAsset]()

    // CollectionView item 개수
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let keyset = PhotoService.imageListMap.keys
        keys = keyset.sorted() { k1, k2 in
            return (PhotoService.imageListMap[k1]?.first?.modifyTime)! > (PhotoService.imageListMap[k2]?.first?.modifyTime)!

        }
        return PhotoService.imageListMap.count
    }

    // CollectionView Cell의 Object
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "albumViewCell", for: indexPath) as! AlbumViewCell


        let list = PhotoService.imageListMap[keys[indexPath.row]]!
        let countString = " (\(list.count))"
        let name = keys[indexPath.row].split(separator: "/").last!
        let text = "\(name)\(countString)"
        let attributedStr = NSMutableAttributedString(string: text)
        attributedStr.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor(rgb: 0x9b9b9b), range: (text as NSString).range(of: countString, options: .backwards))

        cell.albumName.attributedText = attributedStr
        let photoData = list.first!

        //if (photoData.image == nil) {
        self.requestIamge(with: photoData.asset, thumbnailSize: CGSize(width: 480, height: 480)) { image in
            if (image != nil && self.viewMap[cell.image] == photoData.asset) {
                //photoData.image = image
                cell.image.image = image
            }
        }
        //print(cell.image.value(forKey: "asset"))
        viewMap[cell.image] = photoData.asset

        //cell.image.clipsToBounds = true

        return cell
    }


    // CollectionView Cell의 Size
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {


        let width: CGFloat = collectionView.frame.width / 2 - 4.0
        return CGSize(width: width, height: width + CGFloat(labelSize))
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        4.0
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        4.0
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        ImageListViewController.imageList = PhotoService.imageListMap[keys[indexPath.row]]!
        ShowViewController("ImageListVC")
    }

    func refresh() {
        collectionView.reloadData()
    }


    override func viewDidLoad() {
        labelSize = Int("hello".height(withConstrainedWidth: collectionView.frame.width, font: UIFont(name: "BMJUAOTF", size: 17)!)) + 15
        AlbumViewController.instance = self

    }


}
