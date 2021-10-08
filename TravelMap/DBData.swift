//
//  DBData.swift
//  TravelMap
//
//  Created by 김한빈 on 2021/10/08.
//

import Foundation
import UIKit
import Photos

class BaseData {
    var name: String?
    var path: String?
    var isVideo: Bool?
    var lat: Double?
    var lng: Double?
    /*val latLng: LatLng?
        get() {
            if (lat == nil || lng == nil)
                return nil
            return LatLng(lat!!, lng!!)
        }
    abstract val uri: Uri*/


    var asset: PHAsset?
    var image: UIImage?
}


class PhotoData: BaseData {

    let id: String?
    let modifyTime: Date?
    var isLoc: Bool?

    private init(
            id: String?,
            modifyTime: Date?,
            isLoc: Bool?) {
        self.id = id
        self.modifyTime = modifyTime
        self.isLoc = isLoc
    }

    convenience init(
            id: String?,
            name: String?,
            path: String?,
            isVideo: Bool?,
            modifyTime: Date?,
            isLoc: Bool?,
            lat: Double?,
            lng: Double?
    ) {
        self.init(id: id, modifyTime: modifyTime, isLoc: isLoc)
        super.name = name
        super.path = path
        super.isVideo = isVideo
        super.lat = lat
        super.lng = lng
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
    var id: Int64?
    var trackingNum: Int?
    var eventNum: Int?
    let pictureId: Int64?
    var trackingSpeed: Int?
    var time: Date?

    private init(id: Int64?,
                 trackingNum: Int?,
                 eventNum: Int?,
                 pictureId: Int64?,
                 trackingSpeed: Int?,
                 time: Date?) {
        self.id = id
        self.trackingNum = trackingNum
        self.eventNum = eventNum
        self.pictureId = pictureId
        self.trackingSpeed = trackingSpeed
        self.time = time
    }

    convenience init(
            id: Int64? = nil,
            trackingNum: Int? = nil,
            eventNum: Int? = nil,
            lat: Double? = nil,
            lng: Double? = nil,
            pictureId: Int64? = nil,
            name: String? = nil,
            path: String? = nil,
            isVideo: Bool? = nil,
            trackingSpeed: Int? = nil,
            time: Date
    ) {
        self.init(id: id, trackingNum: trackingNum, eventNum: eventNum, pictureId: pictureId, trackingSpeed: trackingSpeed, time: time)
        super.name = name
        super.path = path
        super.isVideo = isVideo
        super.lat = lat
        super.lng = lng
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

class TrackingListData {

    let id: Int64
    let trackingNum: Int
    let name: String
    let startTime: Date
    let endTime: Date

    init(id: Int64,
         trackingNum: Int,
         name: String,
         startTime: Date,
         endTime: Date) {
        self.id = id
        self.trackingNum = trackingNum
        self.name = name
        self.startTime = startTime
        self.endTime = endTime
    }
}
