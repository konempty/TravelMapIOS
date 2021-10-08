//
//  PhotoService.swift
//  TravelMap
//
//  Created by 김한빈 on 2021/10/08.
//

import Foundation
import Photos
import UIKit

class PhotoService {
    static var allPhotos: PHFetchResult<PHAsset>!
    static var imageListMap = [String: [BaseData]]()
    static var imageListDaily = [Date: [BaseData]]()
    static var imageList = [BaseData]()
    static let place = [PhotoData]()
    static var isRunning = false
    static var isInited = false

    static func refresh() {
        DispatchQueue.main.startCoroutine {
            //MainMapViewConroller.instance.refresh()
            AlbumViewController.instance.refresh()
            DailyPhotoListViewController.instance.refresh()
            //print("refresh")
            PhotoService.isRunning = false
        }
    }


    init() {
        PhotoService.isRunning = true
        if (!PhotoService.isInited) {
            PhotoService.isInited = true
        }
        DispatchQueue.global().startCoroutine {

            let fetchOptions = PHFetchOptions()
            fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
            fetchOptions.includeAssetSourceTypes = [.typeUserLibrary]
            fetchOptions.predicate = NSPredicate(format: "mediaType = %d || mediaType = %d", PHAssetMediaType.image.rawValue, PHAssetMediaType.video.rawValue)
            let allPhotos = PHAsset.fetchAssets(with: fetchOptions)
            PhotoService.allPhotos = allPhotos
            for i in 0..<allPhotos.count {
                let photo = allPhotos[i]
                let id = photo.localIdentifier
                let name = photo.value(forKey: "filename") as! String
                let dir = photo.value(forKey: "directory") as! String
                let date = Calendar.current.date(bySettingHour: 0, minute: 0, second: 0, of: photo.value(forKey: "modificationDate") as! Date)!
                let media = photo.value(forKey: "mediaType") as! Int
                let loc = photo.location?.coordinate


                if PhotoService.imageListMap[dir] == nil {
                    PhotoService.imageListMap[dir] = []
                }
                if PhotoService.imageListDaily[date] == nil {
                    PhotoService.imageListDaily[date] = []
                }

                let photoData = PhotoData(id: id, name: name, path: dir, isVideo: media == PHAssetMediaType.video.rawValue, modifyTime: date, isLoc: loc != nil, lat: loc?.latitude, lng: loc?.longitude)

                photoData.asset = photo
                PhotoService.imageListMap[dir]?.append(photoData)
                PhotoService.imageListDaily[date]?.append(photoData)
                PhotoService.imageList.append(photoData)
            }

            PhotoService.refresh()


        }
    }

}
