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

class ShareProgressDialog: UIViewController {

    @IBOutlet weak var msg: UILabel!
    @IBOutlet weak var totalView: UIView!
    @IBOutlet weak var cancelBtn: GradientButton!
    var trackingNum = 0
    let count = AtomicInteger(0)
    let sizes = [0.0, 1440, 960]

    var isStop = false
    var share = 0
    var quality = 0
    var name = ""
    var compress = 0
    var pswd: String? = nil

    override func viewDidLoad() {
        super.viewDidLoad()

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH-mm-ss"


        let directory = NSTemporaryDirectory()
        let fileName = "compressedFile\(dateFormatter.string(from: Date()))" + (share != 2 ? ".json" : ".enc")


        let fileURL = NSURL.fileURL(withPathComponents: [directory, fileName])!
        var outputStream: FileOutputStream
        var salt = [UInt8](repeating: 0, count: 32)

        
        totalView.applyGradient(true)
        totalView.layer.sublayers![0].frame = CGRect(x: 0, y: 0, width: 0, height: totalView.frame.height)

        if (share != 2) {
            outputStream = FileOutputStream(url: fileURL)
        } else {
            let status = SecRandomCopyBytes(kSecRandomDefault, salt.count, &salt)

            outputStream = AES256OutputStream(fileURL: fileURL, pswd: pswd!, salt: salt)
        }
        outputStream.write("[".bytes)

        var isComma = false
        DispatchQueue.global().async { [self] in
            let s = DispatchSemaphore(value: 1)

            let realm = try! Realm()
            let datas = Array(realm.objects(EventData.self).filter("trackingNum == \(trackingNum)").sorted(byKeyPath: "id"))
            var total = AtomicInteger(Int64(datas.count))
            for data in datas {
                if (isStop) {
                    return
                }
                
                let tmpCount = Double(count.incrementAndGet())
                DispatchQueue.main.async { [self] in
                    totalView.layer.sublayers![0].frame = CGRect(x: 0, y: 0, width: totalView.frame.width * CGFloat(tmpCount / Double(total.get())), height: totalView.frame.height)
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
                    outputStream.write(",\n".bytes)
                }
                isComma = true
                let profileJson = try! JSONSerialization.data(withJSONObject: obj, options: .prettyPrinted)

                outputStream.write(Array(profileJson))


            }
            outputStream.write("]".bytes)
            outputStream.close()
            if (true) {
                finish()
                return

            }
            AF.upload(
                    multipartFormData: { multipartFormData in
                        multipartFormData.append(fileURL, withName: "file", fileName: fileName, mimeType: "multipart/form-data")
                        multipartFormData.append(Data(String(share).utf8), withName: "share")
                        if (share == 2) {
                            multipartFormData.append(Data(Data(salt).base64EncodedString(options: .lineLength64Characters).utf8), withName: "salt")
                        }
                        multipartFormData.append(Data(name.utf8), withName: "trackingName")
                    }, to: "", method: .post

            ).responseJSON(completionHandler: { response in
                guard let statusCode = response.response?.statusCode else {
                    return
                }

                switch statusCode {

                case 200:
                    break;

                default:
                    if let responseJSON = try! response.result.get() as? [String: String] {

                        if let error = responseJSON["error"] {


                        }
                    }
                }
            })
        }


    }


}
