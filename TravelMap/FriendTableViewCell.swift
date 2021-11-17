//
//  FriendTableViewCell.swift
//  TravelMap
//
//  Created by 김한빈 on 2021/11/13.
//

import UIKit

class FriendTableViewCell: UITableViewCell {

    @IBOutlet weak var nicknameLabel: UILabel!
    @IBOutlet weak var acceptBtn: UIButton!
    @IBOutlet weak var deleteBtn: UIButton!
    var data: FriendItem!
    var isFriendList = true

    override func layoutSubviews() {
        var gesture = UITapGestureRecognizer(target: self, action: #selector(acceptFun))
        acceptBtn.isUserInteractionEnabled = true
        acceptBtn.addGestureRecognizer(gesture)

        gesture = UITapGestureRecognizer(target: self, action: #selector(deleteFun))
        deleteBtn.isUserInteractionEnabled = true
        deleteBtn.addGestureRecognizer(gesture)
    }

    func setData(data: FriendItem, isFriendList: Bool) {
        backgroundColor = data.isPartially ? UIColor.gray : UIColor(named: "dark")

        self.isFriendList = isFriendList
        acceptBtn.isHidden = isFriendList
        self.data = data
        nicknameLabel.text = data.nickname

    }

    func showProgress() {
        FriendViewController.instance.showProgress()
    }

    func dismissProgress() {
        FriendViewController.instance.dismissProgress()
    }

    func showToast(_ msg: String) {
        FriendViewController.instance.view.makeToast(msg)
    }

    func refreshData() {

        FriendViewController.instance.refreshData()
    }

    @objc func acceptFun() {
        showProgress()
        let params = ["id": data.id]
        AlamofireSession.sendRestRequest(url: "addFriendRequest.do", params: params) { [self] dataResponse in
            dismissProgress()
            switch dataResponse.result {
            case .success(let value):
                let result = String(data: value!, encoding: .utf8)
                switch result {
                case "alreadyRequested":
                    showToast("이미 친구신청이 되어있습니다.")
                    refreshData()
                    break;
                case "success":
                    showToast("친구가 되었습니다.")
                    refreshData()
                    break;
                default:
                    break;
                }
                break;
            default:
                showToast("문제가 발생했습니다. 잠시후 다시 시도해주세요.")
                FriendViewController.instance.finish()
                break;
            }
        }
    }

    @objc func deleteFun() {
        let alertController = UIAlertController(title: "친구 리스트", message: data.nickname + (isFriendList ? (data.isPartially ? "님 친구신청을 취소하시겠습니까?" : "님을 친구 삭제하시겠습니까?") : "님 친구신청을 거절하시겠습니까?"), preferredStyle: .alert)

        let okAction = UIAlertAction(title: "예", style: .default) { [self] (_) -> Void in
            showProgress()
            let params = ["id": data.id]
            AlamofireSession.sendRestRequest(url: "deleteFriend.do", params: params) { [self] dataResponse in
                dismissProgress()
                switch dataResponse.result {
                case .success(let value):
                    let result = String(data: value!, encoding: .utf8)
                    if (result == "noUID") {
                        showToast("문제가 발생했습니다. 잠시후 다시 시도해주세요.")
                        FriendViewController.instance.finish()
                        MainViewController.instance.menuController.logout()
                    } else {
                        refreshData()
                    }
                    break;
                default:
                    showToast("문제가 발생했습니다. 잠시후 다시 시도해주세요.")
                    FriendViewController.instance.finish()
                    break;
                }
            }

        }
        let cancelAction = UIAlertAction(title: "아니요", style: .default)


        alertController.addAction(okAction)
        alertController.addAction(cancelAction)
        alertController.setStyle()
        FriendViewController.instance.present(alertController, animated: true, completion: nil)
    }

}
