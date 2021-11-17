//
//  AddFriendDialog.swift
//  TravelMap
//
//  Created by 김한빈 on 2021/11/13.
//

import UIKit

class AddFriendDialog: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var nicknameTF: BorderTextField!
    @IBOutlet var outside: UIView!

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if string == "" {
            return true
        }
        if (string.count > 10) {
            view.makeToast("10자이상 입력이 불가능 합니다.", position: .top)
            return false
        }
        return true

    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        nicknameTF.resignFirstResponder()
        return true
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        nicknameTF.delegate = self
        let gesture = UITapGestureRecognizer(target: self, action: #selector(onClickOutside))
        outside.isUserInteractionEnabled = true
        outside.addGestureRecognizer(gesture)
    }

    @IBAction func okFun(_ sender: Any) {
        nicknameTF.resignFirstResponder()
        showProgress()
        let nickname = nicknameTF.text!
        let params = ["userNickname": nickname]
        AlamofireSession.sendRestRequest(url: "getUserId.do", params: params) { [self] response in
            switch response.result {
            case .success(let value):
                let result = Int64(String(data: value!, encoding: .utf8)!)
                if (result == -1) {
                    view.makeToast("존재하지 않는 사용자입니다.")
                    dismissProgress()
                } else {
                    let params = ["id": result]
                    AlamofireSession.sendRestRequest(url: "addFriendRequest.do", params: params) { [self] response in
                        dismissProgress()
                        switch response.result {
                        case .success(let value):
                            let result = String(data: value!, encoding: .utf8)
                            switch result {
                            case "alreadyRequested":
                                view.makeToast("이미 친구신청이 되어있습니다.")
                                break;
                            case "success":
                                finish()
                                FriendViewController.instance.refreshData()
                                FriendViewController.instance.view.makeToast("신청되었습니다.")
                                break;
                            default:
                                finish()
                                MenuViewController.instance?.logout()
                                break;
                            }

                            break;
                        default:
                            view.makeToast("문제가 발생했습니다. 잠시후 다시 시도해주세요.")


                            dismissProgress()
                            break;
                        }
                    }
                }
                break;
            default:
                view.makeToast("문제가 발생했습니다. 잠시후 다시 시도해주세요.")


                dismissProgress()
                break;
            }
        }
    }

    @objc func onClickOutside() {
        finish()
    }

}
