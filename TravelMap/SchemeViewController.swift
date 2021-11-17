//
//  SchemeViewController.swift
//  TravelMap
//
//  Created by 김한빈 on 2021/11/14.
//

import UIKit
import FirebaseAuth
import SwiftyJSON
import Alamofire
import RealmSwift
import Photos

class SchemeViewController: UIViewController, LoginResultProtocol, YAJLParserDelegate {
    //var list = [EventData]()


    var data: SchemeData!
    @IBOutlet weak var msgLabel: UILabel!
    @IBOutlet weak var progressView: BorderView!
    @IBOutlet weak var progressLabel: UILabel!
    var mAuth = Auth.auth()
    let dateFormatter = DateFormatter()
    var jsonData: JsonData = JsonData()
    var key: String!
    var id: AtomicInteger!
    var trackingNum = 0
    var count = AtomicInteger(0)
    var lastTime: Date!

    override func viewDidLoad() {
        /*let realm = try! Realm()
        try! realm.write {
            realm.deleteAll()
        }*/
        if (Array(try! Realm().objects(TrackingInfo.self).filter("trackingID == \(data.id)")).count > 0) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                let alertController = UIAlertController(title: "이미 존재하는 여행기록", message: "이미 다운받은 여행기록입니다.\n여행리스트 화면에서 확인해주세요", preferredStyle: .alert)

                let okAction = UIAlertAction(title: "확인", style: .default) { [self] (_) -> Void in
                    finish()

                }


                alertController.addAction(okAction)
                alertController.setStyle()
                self.present(alertController, animated: true, completion: nil)
            }

            return
        }
        dateFormatter.dateFormat = "yyyy-MM-dd HH-mm-ss"
        id = AtomicInteger(try! Realm().objects(EventData.self).map {
            $0.id
        }.max() { i1, i2 in
            return i1 < i2
        } ?? 0)
        trackingNum = (try! Realm().objects(EventData.self).map {
            $0.trackingNum
        }.max() { i1, i2 in
            return i1 < i2
        } ?? 0) + 1
        if (data.id == -1) {
            view.makeToast("문제가 발생했습니다. 잠시후 다시 시도해주세요.")
            finish()
            return
        }
        if (mAuth.currentUser == nil) {
            ShowViewController("LoginVC")
        } else {
            next()
        }

        progressView.applyGradient(true)
        progressView.layer.sublayers![0].frame = CGRect(x: 0, y: 0, width: 0, height: progressView.frame.height)
    }

    func parserDidStartDictionary(_ parser: YAJLParser!) {
        jsonData.trackingSpeed = nil
        jsonData.lat = nil
        jsonData.lng = nil
        jsonData.pictureId = nil
        jsonData.path = nil
        jsonData.name = nil

    }

    var isb = false

    func parserDidEndDictionary(_ parser: YAJLParser!) {

        //list.append(eventData)
        let realm = try! Realm()
        try! realm.write() {
            realm.add(EventData(id: id.incrementAndGet(), trackingNum: trackingNum, eventNum: jsonData.eventNum, lat: jsonData.lat, lng: jsonData.lng, pictureId: jsonData.pictureId, name: jsonData.name, path: jsonData.path, isVideo: true, trackingSpeed: jsonData.trackingSpeed, time: jsonData.time))
        }
        let num = count.incrementAndGet()
        DispatchQueue.main.async { [self] in
            progressLabel.text = "\(num)"
        }

        print(num)
    }

    func parserDidStartArray(_ parser: YAJLParser!) {
    }

    func parserDidEndArray(_ parser: YAJLParser!) {
        //let time = list.last!.time
        //list.append()
        let realm = try! Realm()
        try! realm.write() {
            realm.add(EventData(id: id.incrementAndGet(), trackingNum: trackingNum, eventNum: 2, name: data.trackingName, time: lastTime))
            realm.add(TrackingInfo(id: trackingNum, userID: data.userID, trackingID: data.id, isFriendShare: data.shareNum == 1))
        }
        //print("1")
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [self] in
            finish()
            MainViewController.instance.view.makeToast("성공적으로 다운로드 되었습니다.")
        }
    }

    func parser(_ parser: YAJLParser!, didMapKey key: String!) {

        self.key = key
    }

    func parser(_ parser: YAJLParser!, didAdd value: Any!) {
        switch (key) {
        case "eventNum":
            jsonData.eventNum = (value as! Int)
            break
        case "trackingSpeed":
            jsonData.trackingSpeed = (value as! Int)
            break
        case "lat":
            jsonData.lat = (value as! Double)
            break
        case "lng":
            jsonData.lng = (value as! Double)
            break
        case "data":

            try! PHPhotoLibrary.shared().performChangesAndWait {
                self.jsonData.pictureId = PHAssetChangeRequest.creationRequestForAsset(from: UIImage(data: Data(base64Encoded: value as! String, options: .ignoreUnknownCharacters)!)!).placeholderForCreatedAsset?.localIdentifier
            }
            break
        default:
            lastTime = dateFormatter.date(from: value as! String)
            jsonData.time = lastTime
            break;
        }

    }


    func next() {
        showProgress()
        AlamofireSession.sendRestRequest(url: "loginCheck.do", params: nil, isPost: false) { [self] response in
            dismissProgress()
            switch response.result {
            case .success(let value):
                let result = String(data: value!, encoding: .utf8)
                if (result == "Logedin") {
                    if (data.shareNum == 1) {
                        checkPermission()
                    } else {
                        downloadFile()
                    }
                } else {
                    showProgress()
                    Auth.auth().currentUser!.getIDTokenResult(forcingRefresh: true) { [self] (result, error) in
                        if let error2 = error {

                            dismissProgress()
                            MainViewController.instance.view.makeToast("문제가 발생했습니다. 잠시후 다시 시도해주세요.")
                        } else {
                            let token = result!.token
                            let params = ["token": token]
                            AlamofireSession.sendRestRequest(url: "loginProcess.do", params: params) { [self] dataResponse in
                                dismissProgress()
                                switch dataResponse.result {
                                case .success(let value):
                                    let json = JSON(value)

                                    if json["success"].boolValue {
                                        let nickname = json["result"].stringValue
                                        MainViewController.instance.view.makeToast("\(nickname)님 환영합니다!")
                                        MenuViewController.instance?.setNickname(nickname)
                                        if (data.shareNum == 1) {
                                            checkPermission()
                                        } else {
                                            downloadFile()
                                        }
                                    } else {
                                        switch (json["result"].stringValue) {
                                        case "noUID":
                                            MainViewController.instance.view.makeToast("닉네임을 설정해주세요!")

                                            let dialog = ShowDialog("NicknameDialog") as! NicknameDialog
                                            dialog.setOnOk() { nickName in

                                                let params = ["token": token, "nickname": nickName]
                                                AlamofireSession.sendRestRequest(url: "registerUser.do", params: params, isPost: false) { [self] dataResponse in
                                                    switch dataResponse.result {
                                                    case .success(_):
                                                        MainViewController.instance.view.makeToast("\(nickName)님 환영합니다!")
                                                        MenuViewController.instance?.setNickname(nickName)
                                                        if (data.shareNum == 1) {
                                                            checkPermission()
                                                        } else {
                                                            downloadFile()
                                                        }
                                                        break;
                                                    default:
                                                        MainViewController.instance.view.makeToast("문제가 발생했습니다. 잠시후 다시 시도해주세요.")
                                                        finish()
                                                        break;
                                                    }
                                                }
                                            }

                                            break;
                                        default:
                                            MainViewController.instance.view.makeToast("문제가 발생했습니다. 잠시후 다시 시도해주세요.")
                                            finish()
                                            break;

                                        }
                                    }
                                    break;
                                default:
                                    MainViewController.instance.view.makeToast("문제가 발생했습니다. 잠시후 다시 시도해주세요.")
                                    finish()
                                    break;
                                }
                            }
                        }
                    }
                }
                break;
            default:
                view.makeToast("문제가 발생했습니다. 잠시후 다시 시도해주세요.")
                finish()
                break;
            }
        }

    }

    func checkPermission() {
        showProgress()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [self] in
            let params = ["id": data.userID]
            AlamofireSession.sendRestRequest(url: "checkPermission.do", params: params, isPost: false) { [self] response in
                dismissProgress()
                switch response.result {
                case .success(let value):
                    let result = String(data: value!, encoding: .utf8)
                    switch result {
                    case "true":
                        downloadFile()
                        break
                    case "false":
                        let alertController = UIAlertController(title: "친구공개", message: "해당 여행 기록은 친구에게만 공개되어있습니다. \(data.nickname)님에게 친구신청 하시겠습니까?", preferredStyle: .alert)

                        let okAction = UIAlertAction(title: "예", style: .default) { (_) -> Void in

                            showProgress()
                            let params = ["id": data.userID]
                            AlamofireSession.sendRestRequest(url: "addFriendRequest.do", params: params) { [self] response in
                                dismissProgress()
                                switch response.result {
                                case .success(let value):
                                    let result = String(data: value!, encoding: .utf8)
                                    switch result {
                                    case "alreadyRequested", "success":
                                        view.makeToast("신청되었습니다. 친구신청 수락 되면 다시 시도해주세요.")
                                        break;
                                    default:
                                        view.makeToast("문제가 발생했습니다. 잠시후 다시 시도해주세요.")
                                        MenuViewController.instance?.logout()
                                        break;
                                    }
                                    finish()
                                    break
                                default:
                                    view.makeToast("문제가 발생했습니다. 잠시후 다시 시도해주세요.")
                                    finish()
                                    break
                                }
                            }

                        }
                        let cancelAction = UIAlertAction(title: "아니요", style: .default) { (_) -> Void in
                            finish()
                        }
                        alertController.addAction(okAction)
                        alertController.addAction(cancelAction)
                        alertController.setStyle()
                        self.present(alertController, animated: true, completion: nil)
                        break
                    default:
                        view.makeToast("문제가 발생했습니다. 잠시후 다시 시도해주세요.")
                        finish()
                        break;
                    }
                    break;
                default:
                    view.makeToast("문제가 발생했습니다. 잠시후 다시 시도해주세요.")
                    finish()
                    break;
                }
            }
        }

    }

    var request: Request? = nil

    var fileURL: URL? = nil

    func downloadFile() {
        let params = ["trackingNum": data.id]

        request = AlamofireSession.downloadFile(url: "fileDownload.do", params: params, isPost: false) { [self] response in
            switch (response.result) {
            case .success(let url):

                if (url != nil) {
                    fileURL = url
                    //var outpurStream:FileOutputStream = FileOutputStream(url: url!)
                    if (data.shareNum == 2) {
                        decryptFile(url: url!)

                    } else {
                        DispatchQueue.global().async {

                            parse(url!)
                        }
                        finish()
                    }
                } else {

                    view.makeToast("문제가 발생했습니다. 잠시후 다시 시도해주세요.")
                    finish()
                }
                break;
            case .failure(let error):
                view.makeToast("문제가 발생했습니다. 잠시후 다시 시도해주세요.")
                finish()
                break;
            }

        }.downloadProgress { [self] progress in
            if (isStop) {
                request?.cancel()
            }
            progressView.layer.sublayers![0].frame = CGRect(x: 0, y: 0, width: progressView.frame.width * CGFloat(progress.fractionCompleted), height: progressView.frame.height)
            progressLabel.text = String(format: "%.1f%%", progress.fractionCompleted * 100)
            //print("?")
        }
    }

    func decryptFile(url: URL) {
        (ShowDialog("PasswordDialog") as! PasswordDialog).setOnOk() { [self] password in
            DispatchQueue.main.async { [self] in

                msgLabel.text = "여행기록을 복호화중입니다. 잠시만 기다려 주세요."
            }
            let directory = NSTemporaryDirectory()
            let fileName = "\(data.trackingName)_temp.json"


            let fileURL = NSURL.fileURL(withPathComponents: [directory, fileName])!
            let outputStream = AES256OutputStream(fileURL: fileURL, pswd: password, salt: data.salt!, isEncrypt: false)
            let inputStream = InputStream(url: url)!
            inputStream.open()
            let len = 102400
            let tmp_buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: len)
            let resources = try! url.resourceValues(forKeys: [.fileSizeKey])
            let fileSize = resources.fileSize!
            var count: Int64 = 0
            while (inputStream.hasBytesAvailable) {
                if (isStop) {
                    return
                }
                let n = inputStream.read(tmp_buffer, maxLength: len)
                count += Int64(n)
                let progress = Float(count) / Float(fileSize)
                DispatchQueue.main.async {
                    progressView.layer.sublayers![0].frame = CGRect(x: 0, y: 0, width: progressView.frame.width * CGFloat(progress), height: progressView.frame.height)
                    progressLabel.text = String(format: "%.1f%%", progress * 100)
                }
                let bufferPointer = UnsafeMutableBufferPointer(start: tmp_buffer, count: n)
                let array = Array(bufferPointer)
                do {
                    try outputStream.write(array)
                } catch {
                    DispatchQueue.main.async { [self] in
                        inputStream.close()
                        outputStream.close()
                        self.view.makeToast("비밀번호가 잘못되었습니다.")
                        decryptFile(url: url)
                    }
                    return
                }
            }
            inputStream.close()
            outputStream.close()
            parse(fileURL)
        }
    }

    func setLoginResult(_ isLogined: Bool) {
        if (isLogined) {
            next()
        } else {
            view.makeToast("여행기록을 다운로드하기위해선 로그인이 필요합니다.")
        }
    }

    var isStop = false

    @IBAction func cancelFun() {
        isStop = true
        try? FileManager.default.removeItem(at: fileURL!)
        request?.cancel()

        finish()
    }

    func parse(_ url: URL) {
        DispatchQueue.main.async {

            self.msgLabel.text = "여행기록을 정리하고 있습니다. 잠시만 기다려 주세요."
        }
        /*let inputStream = InputStream(url: url)!
        inputStream.open()
        let len = 1024
        let tmp_buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: len)
        let n = inputStream.read(tmp_buffer, maxLength: len)
        let bufferPointer = UnsafeMutableBufferPointer(start: tmp_buffer, count: n)
        let array = Array(bufferPointer)
        let str = String(data: Data(array), encoding: .utf8)*/
        /*let data = try! Data(contentsOf: url, options: .mappedIfSafe)
                        let json = try! JSONSerialization.jsonObject(with: data, options: .allowFragments)
                        print(json)*/
        let parser = YAJLParser(parserOptions: .allowComments)
        let data2 = try! Data(contentsOf: url, options: .mappedIfSafe)
        parser?.delegate = self
        parser?.parse(data2)
        if (parser?.parserError != nil) {
            print("error")

        }
    }

}
