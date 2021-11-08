//
//  PhotoViewController.swift
//  TravelMap
//
//  Created by 김한빈 on 2021/10/08.
//

import UIKit
import Photos
import AVKit
import DropDown
import RealmSwift

class PhotoViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {


    static var startIdx = 0
    static var imageList: [BaseData]!
    var onceOnly = false
    let dropDown = DropDown()

    @IBOutlet weak var backBtn: UIImageView!
    @IBOutlet weak var shareBtn: UIImageView!
    @IBOutlet weak var menuBtn: UIImageView!
    @IBOutlet weak var photoCollectionView: UICollectionView!

    var viewMap = [UIView: PHAsset]()

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return PhotoViewController.imageList.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "photoCollectionViewCell", for: indexPath) as! PhotoCollectionViewCell

        cell.photoData = PhotoViewController.imageList[indexPath.row]

        cell.setImage()
        //} else {
        //   cell.image.image = photoData.image
        //}
        //cell.image.clipsToBounds = true


        return cell
    }


    // CollectionView Cell의 Size
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        return CGSize(width: collectionView.frame.width - 2.0, height: collectionView.frame.height)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        2.0
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        2.0
    }


    internal func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if !onceOnly {

            photoCollectionView.scrollToItem(at: IndexPath(row: PhotoViewController.startIdx, section: 0), at: .centeredHorizontally, animated: false)
            onceOnly = true
        }
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        let photoDataAsset = PhotoViewController.imageList[indexPath.row].asset

        photoDataAsset?.getURL() { url in
            DispatchQueue.main.async {
                if (url != nil) {
                    let playerController = AVPlayerViewController()
                    // 비디오 URL로 초기화된 AVPlayer의 인스턴스 생성
                    let player = AVPlayer(url: url!)
                    // AVPlayerViewController의 player 속성에 위에서 생성한 AVPlayer 인스턴스를 할당
                    playerController.player = player

                    self.present(playerController, animated: true) {
                        player.play() // 비디오 재생
                    }
                }

            }
        }

    }


    //let storyboard = UIStoryboard(name: "Main", bundle: nil)

    override func viewDidLoad() {
        super.viewDidLoad()


        var gesture = UITapGestureRecognizer(target: self, action: #selector(backFun))
        backBtn.isUserInteractionEnabled = true
        backBtn.addGestureRecognizer(gesture)

        gesture = UITapGestureRecognizer(target: self, action: #selector(shareFun))
        shareBtn.isUserInteractionEnabled = true
        shareBtn.addGestureRecognizer(gesture)

        gesture = UITapGestureRecognizer(target: self, action: #selector(menuFun))
        menuBtn.isUserInteractionEnabled = true
        menuBtn.addGestureRecognizer(gesture)

        photoCollectionView.contentMode = .scaleAspectFit


        dropDown.dataSource = ["삭제"]
        dropDown.anchorView = shareBtn
        dropDown.backgroundColor = UIColor(named: "dusk_light")
        dropDown.textColor = UIColor.white
    }


    @objc func backFun() {
        finish()
    }

    @objc func shareFun() {


        let requestImageOption = PHImageRequestOptions()
        requestImageOption.deliveryMode = PHImageRequestOptionsDeliveryMode.highQualityFormat

        let manager = PHImageManager.default()
        manager.requestImage(for: PhotoViewController.imageList[photoCollectionView.indexPathsForVisibleItems[0].row].asset!, targetSize: PHImageManagerMaximumSize, contentMode: PHImageContentMode.default, options: requestImageOption) { image, _ in
            let imageToShare = [image!]
            let activityViewController = UIActivityViewController(activityItems: imageToShare, applicationActivities: nil)
            activityViewController.popoverPresentationController?.sourceView = self.view // so that iPads won't crash


            // present the view controller
            self.present(activityViewController, animated: true, completion: nil)
        }

    }

    @objc func menuFun() {
        let idx = photoCollectionView.indexPathsForVisibleItems[0].row
        let data = PhotoViewController.imageList[idx]
        if data is PhotoData {
            PHPhotoLibrary.shared().performChanges({
                PHAssetChangeRequest.deleteAssets([data.asset!] as NSArray)
            }, completionHandler: { success, error in
                if (success) {
                    DispatchQueue.main.async {
                        if let index = ImageListViewController.imageList.firstIndex(of: data) {

                            ImageListViewController.imageList.remove(at: index)
                        }
                        if let index = PhotoService.imageList.firstIndex(of: data as! PhotoData) {

                            PhotoService.imageList.remove(at: index)
                        }
                        for key in PhotoService.imageListMap.keys {
                            if let index = PhotoService.imageListMap[key]!.firstIndex(of: data as! PhotoData) {

                                PhotoService.imageListMap[key]!.remove(at: index)
                                if (PhotoService.imageListMap[key]?.count == 0) {
                                    PhotoService.imageListMap.removeValue(forKey: key)
                                }
                                break
                            }
                        }
                        for key in PhotoService.imageListDaily.keys {
                            if let index = PhotoService.imageListDaily[key]!.firstIndex(of: data as! PhotoData) {

                                PhotoService.imageListDaily[key]!.remove(at: index)
                                if (PhotoService.imageListDaily[key]?.count == 0) {
                                    PhotoService.imageListDaily.removeValue(forKey: key)
                                }
                                break
                            }
                        }
                        PhotoService.refresh()
                        (self.presentingViewController as! ImageListViewController).refresh()
                        self.finish()
                    }
                }

            })
        } else {
            let realm = try! Realm()
            let item = realm.object(ofType: EventData.self, forPrimaryKey: (data as! EventData).id)
            try! realm.write({
                realm.delete(item!)
            })
            TrackingMapViewController.instance.initCluster()
        }

        //dropDown.show()
    }


}
