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

    // CollectionView item 개수
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        keys = Array(PhotoService.imageListMap.keys)
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
        let photoData = list.last!

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

    func refresh() {
        collectionView.reloadData()
    }


    override func viewDidLoad() {
        labelSize = Int("hello".height(withConstrainedWidth: collectionView.frame.width, font: UIFont(name: "BMJUAOTF", size: 17)!)) + 10
        AlbumViewController.instance = self

    }


}
