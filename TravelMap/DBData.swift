//
//  DBData.swift
//  TravelMap
//
//  Created by 김한빈 on 2021/10/08.
//

import Foundation
import UIKit
import Photos
import RealmSwift

class BaseData: Object {
    @objc dynamic var name: String?
    @objc dynamic var path: String?
    let isVideo = RealmOptional<Bool>()
    let lat = RealmOptional<Double>()
    let lng = RealmOptional<Double>()
    /*val latLng: LatLng?
        get() {
            if (lat == nil || lng == nil)
                return nil
            return LatLng(lat!!, lng!!)
        }
    abstract val uri: Uri*/


    var asset: PHAsset?

    override static func ignoredProperties() -> [String] {
        return ["asset"]
    }

    //var image: UIImage?
}


class PhotoData: BaseData {

    @objc dynamic var id: String!
    @objc dynamic var modifyTime: Date!
    var isLoc: Bool!

    convenience init(
            id: String?,
            modifyTime: Date,
            isLoc: Bool) {
        self.init()
        self.id = id
        self.modifyTime = modifyTime
        self.isLoc = isLoc
    }

    convenience init(
            id: String?,
            name: String?,
            path: String?,
            isVideo: Bool?,
            modifyTime: Date,
            isLoc: Bool,
            lat: Double?,
            lng: Double?
    ) {
        self.init(id: id, modifyTime: modifyTime, isLoc: isLoc)
        super.name = name
        super.path = path
        super.isVideo.value = isVideo
        super.lat.value = lat
        super.lng.value = lng

    }


    override class func primaryKey() -> String? {
        return "id"
    }

    /*override val uri: Uri
        get() {
            val uri = if (isVideo == true) {
                MediaStore.Video.Media.EXTERNAL_CONTENT_URI
            } else {
                MediaStore.Images.Media.EXTERNAL_CONTENT_URI
            }

            var photoUri: Uri = Uri.withAppendedPath(
                uri,
                id.toString()
            )
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                photoUri = MediaStore.setRequireOriginal(photoUri)
            }
            return photoUri
        }*/
}

/*
* eventNum
* 0 : 트래킹 시작/재시작
* 1 : 트래킹 일시중지
* 2 : 트래킹 마침
* 3 : 위치데이터 수신
* 4 : 트래킹 속도 변경
* 5 : 이미지 등록
* */
class EventData: BaseData {
    @objc dynamic var id: Int64 = 0
    @objc dynamic var trackingNum = 0
    @objc dynamic var eventNum = 0
    @objc dynamic var pictureId: String?
    let trackingSpeed = RealmOptional<Int>()
    @objc dynamic var time: Date!

    var latlng: CLLocationCoordinate2D {
        get {
            CLLocationCoordinate2D(latitude: lat.value!, longitude: lng.value!)
        }
    }

    convenience init(other: EventData) {
        self.init()
        self.id = other.id
        self.trackingNum = other.trackingNum
        self.eventNum = other.eventNum
        self.pictureId = other.pictureId
        self.trackingSpeed.value = other.trackingSpeed.value
        self.time = other.time
        super.name = other.name
        super.path = other.path
        super.isVideo.value = other.isVideo.value
        super.lat.value = other.lat.value
        super.lng.value = other.lng.value
    }


    convenience init(
            id: Int64,
            trackingNum: Int,
            eventNum: Int,
            lat: Double? = nil,
            lng: Double? = nil,
            pictureId: String? = nil,
            name: String? = nil,
            path: String? = nil,
            isVideo: Bool? = nil,
            trackingSpeed: Int? = nil,
            time: Date = Date()
    ) {
        self.init()
        self.id = id
        self.trackingNum = trackingNum
        self.eventNum = eventNum
        self.pictureId = pictureId
        self.trackingSpeed.value = trackingSpeed
        self.time = time
        super.name = name
        super.path = path
        super.isVideo.value = isVideo
        super.lat.value = lat
        super.lng.value = lng
    }


    override class func primaryKey() -> String? {
        return "id"
    }

    override var asset: PHAsset? {
        get {
            PHAsset.fetchAssets(withLocalIdentifiers: [pictureId!], options: nil)[0]
        }
        set {

        }
    }
    /*override val uri: Uri
        get() {
            val uri = if (isVideo == true) {
                MediaStore.Video.Media.EXTERNAL_CONTENT_URI
            } else {
                MediaStore.Images.Media.EXTERNAL_CONTENT_URI
            }

            var photoUri: Uri = Uri.withAppendedPath(
                uri,
                pictureId.toString()
            )
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                photoUri = MediaStore.setRequireOriginal(photoUri)
            }
            return photoUri
        }*/


}

class TrackingInfo: Object {
    @objc dynamic var id: Int = 0
    @objc dynamic var userID: Int64 = 0
    @objc dynamic var trackingID: Int64 = 0
    @objc dynamic var isFriendShare: Bool = false

    convenience init(id: Int, userID: Int64, trackingID: Int64, isFriendShare: Bool) {
        self.init()
        self.id = id
        self.userID = userID
        self.trackingID = trackingID
        self.isFriendShare = isFriendShare
    }

    override class func primaryKey() -> String? {
        return "id"
    }
}

class TrackingListData {

    let id: Int64
    let trackingNum: Int
    let name: String
    let userID: Int64?
    let trackingID: Int64?
    let isFriendShare: Bool?
    let startTime: Date
    let endTime: Date


    init(
            id: Int64,
            trackingNum: Int,
            name: String,
            userID: Int64? = nil,
            trackingID: Int64? = nil,
            isFriendShare: Bool? = nil,
            startTime: Date,
            endTime: Date) {
        self.id = id
        self.trackingNum = trackingNum
        self.name = name
        self.userID = userID
        self.trackingID = trackingID
        self.isFriendShare = isFriendShare
        self.startTime = startTime
        self.endTime = endTime
    }
}
