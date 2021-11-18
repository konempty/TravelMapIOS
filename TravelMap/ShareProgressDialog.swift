//
//  ShareProgressDialog.swift
//  TravelMap
//
//  Created by 김한빈 on 2021/11/06.
//

import UIKit
import Alamofire
import Photos
import RealmSwift
import SwiftyJSON

class ShareProgressDialog: UIViewController {

    @IBOutlet weak var msg: UILabel!
    @IBOutlet weak var totalView: UIView!
    @IBOutlet weak var cancelBtn: GradientButton!
    @IBOutlet weak var progressLabel: UILabel!

    var trackingNum = 0
    let count = AtomicInteger(0)
    let sizes = [0.0, 1440, 960]

    var isStop = false
    var share = 0
    var quality = 0
    var name = ""
    var compress = 0
    var pswd: String? = nil
    var request: Request? = nil

    override func viewDidLoad() {
        super.viewDidLoad()

        let gesture = UITapGestureRecognizer(target: self, action: #selector(cancelFun))
        cancelBtn.isUserInteractionEnabled = true
        cancelBtn.addGestureRecognizer(gesture)

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH-mm-ss"


        let directory = NSTemporaryDirectory()
        let letters = "0123456789"
        let fileName = "compressedFile\(dateFormatter.string(from: Date()))\(String((0..<18).map { _ in letters.randomElement()! }))" + (share != 2 ? ".json" : ".enc")


        let fileURL = NSURL.fileURL(withPathComponents: [directory, fileName])!
        var outputStream: FileOutputStream
        var salt = [UInt8](repeating: 0, count: 32)


        totalView.applyGradient(true)
        totalView.layer.sublayers![0].frame = CGRect(x: 0, y: 0, width: 0, height: totalView.frame.height)

        if (share != 2) {
            outputStream = FileOutputStream(url: fileURL)
        } else {
            _ = SecRandomCopyBytes(kSecRandomDefault, salt.count, &salt)

            outputStream = AES256OutputStream(fileURL: fileURL, pswd: pswd!, salt: salt, isEncrypt: true)
        }
        try! outputStream.write("[".bytes)

        var isComma = false
        DispatchQueue.global().async { [self] in
            let s = DispatchSemaphore(value: 1)

            let realm = try! Realm()
            let datas = Array(realm.objects(EventData.self).filter("trackingNum == \(trackingNum)").sorted(byKeyPath: "id"))
            let total = AtomicInteger(Int64(datas.count))
            for data in datas {
                if (isStop) {
                    return
                }

                let tmpCount = Double(count.incrementAndGet())
                DispatchQueue.main.async { [self] in
                    let progress = tmpCount / Double(total.get())
                    totalView.layer.sublayers![0].frame = CGRect(x: 0, y: 0, width: totalView.frame.width * CGFloat(progress), height: totalView.frame.height)
                    progressLabel.text = String(format: "%.1f%%", progress * 100)
                    print("total : \(total.get()) now : \(count.get())")
                }
                if (data.eventNum == 1 || data.eventNum == 2) {
                    continue
                }
                var obj = [String: Any]()
                obj["eventNum"] = data.eventNum
                obj["time"] = dateFormatter.string(for: data.time)

                switch (data.eventNum) {
                case 3, 5:
                    obj["lat"] = data.lat
                    obj["lng"] = data.lng
                    if (data.eventNum == 5) {
                        s.wait()
                        let width = Double(data.asset!.pixelWidth)
                        let height = Double(data.asset!.pixelHeight)
                        var size: CGSize
                        if (quality == 0) {
                            size = PHImageManagerMaximumSize
                        } else {
                            if (width < height) {
                                if (height > sizes[quality]) {
                                    size = CGSize(width: width * sizes[quality] / height, height: sizes[quality])
                                } else {
                                    size = CGSize(width: width, height: height)
                                }
                            } else {
                                if (width > sizes[quality]) {
                                    size = CGSize(width: sizes[quality], height: height * sizes[quality] / width)
                                } else {
                                    size = CGSize(width: width, height: height)
                                }
                            }
                        }
                        self.requestIamge(with: data.asset, thumbnailSize: size) { image in
                            if (image != nil) {
                                let imageData: Data = image!.pngData()!
                                let encodedStr: String = imageData.base64EncodedString(options: .lineLength64Characters)
                                obj["data"] = encodedStr
                            }
                            s.signal()
                        }

                        s.wait()
                        s.signal()
                    }
                    break;
                case 4:
                    obj["trackingSpeed"] = data.trackingSpeed
                    break;
                default:
                    break;
                }

                if (isComma) {
                    try! outputStream.write(",\n".bytes)
                }
                isComma = true
                let profileJson = try! JSONSerialization.data(withJSONObject: obj, options: .prettyPrinted)

                try! outputStream.write(Array(profileJson))


            }
            try! outputStream.write("]".bytes)
            outputStream.close()
            DispatchQueue.main.async { [self] in
                msg.text = "여행기록을 서버로 전송중입니다. 잠시만 기다려 주세요."
            }
            let multipartFormData: MultipartFormData = MultipartFormData()
            multipartFormData.append(fileURL, withName: "file", fileName: fileName, mimeType: "multipart/form-data")
            multipartFormData.append(String(share).data(using: String.Encoding.utf8, allowLossyConversion: false)!, withName: "share")
            if (share == 2) {
                multipartFormData.append(Data(salt).base64EncodedData(options: .lineLength64Characters), withName: "salt")
            }
            multipartFormData.append((name.data(using: String.Encoding.utf8, allowLossyConversion: false)?.base64EncodedData(options: .lineLength64Characters))!, withName: "trackingName")
            multipartFormData.append("true".data(using: String.Encoding.utf8, allowLossyConversion: false)!, withName: "isEncoded")
            if (!isStop) {
                request = AlamofireSession.uploadFile(url: "upload.do", multipartFormData: multipartFormData) { response in
                    request = nil
                    switch response.result {
                    case .success(let value):
                        let json = JSON(value as Any)
                        if (json["success"].boolValue) {

                            print(json["result"].intValue)
                            let realm = try! Realm()
                            try? realm.write() {
                                realm.add(TrackingInfo(id: trackingNum, userID: -1, trackingID: json["result"].int64Value, isFriendShare: share == 1))
                            }
                        } else {
                            print(json["result"].stringValue)
                            view.makeToast("문제가 발생했습니다. 잠시후 다시 시도해주세요.")
                        }
                        break;
                    default:
                        view.makeToast("문제가 발생했습니다. 잠시후 다시 시도해주세요.")
                        break;
                    }
                    finish()
                    (presentingViewController as! TrackingListViewController).loadTrackingData()
                }
                request?.uploadProgress { progress in
                    if (!isStop) {
                        totalView.layer.sublayers![0].frame = CGRect(x: 0, y: 0, width: totalView.frame.width * CGFloat(progress.fractionCompleted), height: totalView.frame.height)
                        progressLabel.text = String(format: "%.1f%%", progress.fractionCompleted * 100)
                    }
                }
            }
        }


    }

    @objc func cancelFun() {
        isStop = true
        request?.cancel()
        request = nil
        finish()
    }
}
