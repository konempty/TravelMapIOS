//
//  TrackingListViewController.swift
//  TravelMap
//
//  Created by 김한빈 on 2021/10/07.
//

import UIKit
import RealmSwift
import DropDown
import Firebase
import SwiftyJSON

class TrackingListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, LoginResultProtocol {
    @IBOutlet weak var backBtn: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    var datas = [TrackingListData]()
    var selectIndex = 0
    var data: TrackingListData!


    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        datas.count

    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "trackingListTableViewCell", for: indexPath) as! TrackingListTableViewCell

        let data = datas[indexPath.row]
        cell.trackingName.text = data.name
        let dateFormatter = DateFormatter()

        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        cell.trackingTime.text = dateFormatter.string(from: data.startTime) + " ~ " + dateFormatter.string(from: data.endTime)

        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(sender:)))
        tableView.addGestureRecognizer(longPress)

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let data = datas[indexPath.row]
        (ShowViewController("TrackingMapVC") as! TrackingMapViewController).trackingNum = data.trackingNum

    }


    override func viewDidLoad() {
        super.viewDidLoad()
        //logout()
        tableView.tableFooterView = UIView()
        tableView.contentInset = UIEdgeInsets(top: 0, left: -5, bottom: 0, right: 0)
        tableView.separatorColor = UIColor.lightGray
        tableView.rowHeight = "hello".height(withConstrainedWidth: tableView.frame.width, font: UIFont(name: "BMJUAOTF", size: 19)!) * 4
        // Do any additional setup after loading the view.

        let gesture = UITapGestureRecognizer(target: self, action: #selector(backFun))
        backBtn.isUserInteractionEnabled = true
        backBtn.addGestureRecognizer(gesture)


        loadTrackingData()
    }


    func loadTrackingData() {
        let realm = try! Realm()
        let results = realm.objects(EventData.self).filter("eventNum == 2").sorted(byKeyPath: "trackingNum")
        let infos = realm.objects(TrackingInfo.self).sorted(byKeyPath: "id")
        datas.removeAll()
        var idx = 0
        for result in results {
            let results2 = realm.objects(EventData.self).filter("trackingNum == \(result.trackingNum)")
            if (idx < infos.count && infos[idx].id == result.trackingNum) {
                let info = infos[idx]
                datas.append(TrackingListData(id: result.id, trackingNum: result.trackingNum, name: result.name!, userID: info.userID, trackingID: info.trackingID, isFriendShare: info.isFriendShare, startTime: results2.min(ofProperty: "time")!, endTime: results2.max(ofProperty: "time")!))
                idx += 1
            } else {
                datas.append(TrackingListData(id: result.id, trackingNum: result.trackingNum, name: result.name!, startTime: results2.min(ofProperty: "time")!, endTime: results2.max(ofProperty: "time")!))
            }
        }
        tableView.reloadData()
    }

    @objc func backFun() {
        finish()
    }

    @objc func handleLongPress(sender: UILongPressGestureRecognizer) {
        if sender.state == .began {
            let touchPoint = sender.location(in: tableView)
            if let indexPath = tableView.indexPathForRow(at: touchPoint) {
                selectIndex = indexPath.row
                data = datas[selectIndex]
                /*let uvc = self.storyboard?.instantiateViewController(withIdentifier: "TrackingItemMenuDia") as! TrackingItemMenuDialog
                uvc.modalPresentationStyle = .overCurrentContext
                uvc.setData(data: data)
                present(uvc, animated: true)*/

                let alertController = UIAlertController(title: data.name, message: nil, preferredStyle: .actionSheet)

                let action1 = UIAlertAction(title: "삭제", style: .default) { [self] (_) -> Void in

                    let alertController = UIAlertController(title: nil, message: "정말로 '\(data.name)'을(를) 삭제 하시겠습니까?\n삭제후 복구는 불가능 합니다.", preferredStyle: .alert)

                    let okAction = UIAlertAction(title: "예", style: .default) { (_) -> Void in
                        if (data.userID == -1) {
                            showProgress()
                            AlamofireSession.sendRestRequest(url: "loginCheck.do", params: nil, isPost: false) { [self] response in
                                dismissProgress()
                                switch response.result {
                                case .success(let value):
                                    let result = String(data: value!, encoding: .utf8)
                                    if (result == "Logedin") {
                                        dismissProgress()
                                        cancelShare(position: selectIndex, isDelete: true)
                                    } else {
                                        Auth.auth().currentUser!.getIDTokenResult(forcingRefresh: true) { [self] (result, error) in
                                            if let error2 = error {

                                                dismissProgress()
                                                view.makeToast("문제가 발생했습니다. 잠시후 다시 시도해주세요.")
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
                                                            view.makeToast("\(nickname)님 환영합니다!")
                                                            MenuViewController.instance?.setNickname(nickname)
                                                            cancelShare(position: selectIndex, isDelete: true)
                                                        } else {
                                                            switch (json["result"].stringValue) {
                                                            case "noUID":
                                                                view.makeToast("로그인 상태를 확인해주세요.")


                                                                break;
                                                            default:
                                                                view.makeToast("문제가 발생했습니다. 잠시후 다시 시도해주세요.")
                                                                break;

                                                            }
                                                        }
                                                        break;
                                                    default:
                                                        view.makeToast("문제가 발생했습니다. 잠시후 다시 시도해주세요.")
                                                        break;
                                                    }
                                                }
                                            }
                                        }
                                    }
                                    break;
                                default:
                                    break;
                                }
                            }
                        } else {

                            let realm = try! Realm()
                            let data = realm.objects(EventData.self).filter("trackingNum == \(self.data.trackingNum)")
                            let info = realm.objects(TrackingInfo.self).filter("id == \(self.data.trackingNum)")

                            try! realm.write({
                                realm.delete(data)
                                realm.delete(info)
                            })
                            self.loadTrackingData()
                        }

                    }

                    let cancelAction = UIAlertAction(title: "아니요", style: .default)


                    alertController.addAction(okAction)
                    alertController.addAction(cancelAction)
                    alertController.setStyle()
                    self.present(alertController, animated: true, completion: nil)

                }
                alertController.addAction(action1)
                if (data.userID == -1 || data.userID == nil) {
                    let action2 = UIAlertAction(title: "이름변경", style: .default) { (_) -> Void in
                        self.changeTrackingName()

                    }
                    let action3 = UIAlertAction(title: (data.userID == -1) ? "여행 공유 취소" : "여행 공유", style: .default) { (_) -> Void in
                        if (self.data.userID == -1) {
                            let alertController = UIAlertController(title: nil, message: "'\(self.data.name)'을(를) 공유취소 하시겠습니까?", preferredStyle: .alert)

                            let okAction = UIAlertAction(title: "예", style: .default) { [self] (_) in
                                showProgress()
                                AlamofireSession.sendRestRequest(url: "loginCheck.do", params: nil, isPost: false) { [self] response in
                                    dismissProgress()
                                    switch response.result {
                                    case .success(let value):
                                        let result = String(data: value!, encoding: .utf8)
                                        if (result == "Logedin") {
                                            dismissProgress()
                                            cancelShare(position: selectIndex, isDelete: false)
                                        } else {
                                            Auth.auth().currentUser!.getIDTokenResult(forcingRefresh: true) { [self] (result, error) in
                                                if let error2 = error {

                                                    dismissProgress()
                                                    view.makeToast("문제가 발생했습니다. 잠시후 다시 시도해주세요.")
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
                                                                view.makeToast("\(nickname)님 환영합니다!")
                                                                MenuViewController.instance?.setNickname(nickname)
                                                                cancelShare(position: selectIndex, isDelete: false)
                                                            } else {
                                                                switch (json["result"].stringValue) {
                                                                case "noUID":
                                                                    view.makeToast("로그인 상태를 확인해주세요.")


                                                                    break;
                                                                default:
                                                                    view.makeToast("문제가 발생했습니다. 잠시후 다시 시도해주세요.")
                                                                    break;

                                                                }
                                                            }
                                                            break;
                                                        default:
                                                            view.makeToast("문제가 발생했습니다. 잠시후 다시 시도해주세요.")
                                                            break;
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                        break;
                                    default:
                                        break;
                                    }
                                }

                            }


                            let cancelAction = UIAlertAction(title: "아니요", style: .default)


                            alertController.addAction(okAction)
                            alertController.addAction(cancelAction)
                            alertController.setStyle()
                            self.present(alertController, animated: true, completion: nil)

                        } else {

                            self.showShareDialog()
                        }

                    }
                    alertController.addAction(action2)
                    alertController.addAction(action3)
                }
                if (data.trackingID != nil) {
                    let action4 = UIAlertAction(title: "여행 공유 링크 가져오기", style: .default) { (_) -> Void in
                        let textToShare = ["https://119.69.202.23/browse.do?id=\(self.data.trackingID!)"]
                        let activityViewController = UIActivityViewController(activityItems: textToShare, applicationActivities: nil)
                        activityViewController.popoverPresentationController?.sourceView = self.view // so that iPads won't crash

                        // exclude some activity types from the list (optional)
                        activityViewController.excludedActivityTypes = [UIActivity.ActivityType.airDrop, UIActivity.ActivityType.postToFacebook]

                        // present the view controller
                        self.present(activityViewController, animated: true, completion: nil)
                    }
                    alertController.addAction(action4)
                }


                let cancelAction = UIAlertAction(title: "취소", style: .default)
                alertController.addAction(cancelAction)
                alertController.setStyle()
                present(alertController, animated: true, completion: nil)
            }
        }
    }

    func cancelShare(position: Int, isDelete: Bool) {
        let params = ["trackingNum": datas[position].trackingID]
        showProgress()
        AlamofireSession.sendRestRequest(url: "deleteFile.do", params: params, isPost: false) { [self] response in
            dismissProgress()
            switch response.result {
            case .success(let value):
                let json = try! JSON(data: value!)
                if (json["success"].boolValue) {
                    let realm = try! Realm()
                    let data = realm.objects(EventData.self).filter("trackingNum == \(self.data.trackingNum)")
                    let info = realm.objects(TrackingInfo.self).filter("id == \(self.data.trackingNum)")

                    try! realm.write({
                        if (isDelete) {
                            realm.delete(data)
                        }
                        realm.delete(info)
                    })
                    self.loadTrackingData()
                    view.makeToast("정상적으로 공유 취소 되었습니다.")
                } else if (json["result"].stringValue == "noDelete") {
                    view.makeToast("공유한 유저와 현재 로그인된 유저가 같지않습니다.")
                } else {
                    view.makeToast("문제가 발생했습니다. 잠시후 다시 시도해주세요.")
                }
                break;
            default:
                view.makeToast("문제가 발생했습니다. 잠시후 다시 시도해주세요.")
                break

            }

        }
    }

    func changeTrackingName() {
        let data = datas[selectIndex]

        let uvc = self.storyboard?.instantiateViewController(withIdentifier: "TrackingNameDialog") as! TrackingNameDialog
        uvc.modalPresentationStyle = .overCurrentContext
        uvc.setData(name: data.name, trackingNum: data.trackingNum, isEdit: true)
        uvc.setOnOk() { [self]name in
            if (!name.isEmpty) {
                let realm = try! Realm()
                let row = realm.object(ofType: EventData.self, forPrimaryKey: data.id)
                try! realm.write({
                    row?.name = name
                    loadTrackingData()
                })
            }
        }
        present(uvc, animated: true)

    }

    func showShareDialog() {
        data = datas[selectIndex]

        let alertController = UIAlertController(title: nil, message: "'\(data.name)'을(를) 다른 사람들에게 공유하시겠습니까?", preferredStyle: .alert)

        let okAction = UIAlertAction(title: "예", style: .default) { [self] (_) -> Void in
            if (Auth.auth().currentUser == nil) {

                ShowViewController("LoginVC")
            } else {
                loginAndSendData()
            }

        }

        let cancelAction = UIAlertAction(title: "아니요", style: .default)


        alertController.addAction(okAction)
        alertController.addAction(cancelAction)
        alertController.setStyle()
        present(alertController, animated: true, completion: nil)
    }


    func setLoginResult(_ isLogined: Bool) {
        if (isLogined) {
            loginAndSendData()
        } else {
            view.makeToast("여행기록을 공유하기위해선 로그인이 필요합니다.")
        }
    }

    func loginAndSendData() {
        showProgress()
        Auth.auth().currentUser!.getIDTokenResult(forcingRefresh: true) { [self] (result, error) in
            if let error2 = error {

                dismissProgress()
                view.makeToast("문제가 발생했습니다. 잠시후 다시 시도해주세요.")
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
                            view.makeToast("\(nickname)님 환영합니다!")
                            showShareSelectDialog()
                        } else {
                            switch (json["result"].stringValue) {
                            case "noUID":
                                view.makeToast("닉네임을 설정해주세요!")

                                let dialog = ShowDialog("NicknameDialog") as! NicknameDialog
                                dialog.setOnOk() { nickName in

                                    let params = ["token": token, "nickname": nickName]
                                    AlamofireSession.sendRestRequest(url: "registerUser.do", params: params, isPost: false) { [self] dataResponse in
                                        switch dataResponse.result {
                                        case .success(_):
                                            showShareSelectDialog()
                                            break;
                                        default:
                                            view.makeToast("문제가 발생했습니다. 잠시후 다시 시도해주세요.")
                                            break;
                                        }
                                    }
                                }

                                break;
                            default:
                                view.makeToast("문제가 발생했습니다. 잠시후 다시 시도해주세요.")
                                break;

                            }
                        }
                        break;
                    default:
                        view.makeToast("문제가 발생했습니다. 잠시후 다시 시도해주세요.")
                        break;
                    }
                }
            }
        }
    }

    func showShareSelectDialog() {
        let dialog1 = (ShowDialog("ShareSelectDialog") as! ShareSelectDialog)
        dialog1.setOnOk { [self] in
            let dialog2 = (ShowDialog("ShareProgressDialog") as! ShareProgressDialog)
            dialog2.name = data.name
            dialog2.trackingNum = data.trackingNum
            dialog2.share = dialog1.shareSlectrion
            dialog2.quality = dialog1.qualitySelection
            dialog2.pswd = dialog1.pswd

        }
    }

}
