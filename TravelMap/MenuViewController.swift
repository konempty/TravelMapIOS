//
//  MenuViewController.swift
//  TravelMap
//
//  Created by 김한빈 on 2021/11/13.
//

import UIKit
import Firebase
import SwiftyJSON

class MenuViewController: UIViewController {

    static var instance: MenuViewController? = nil

    @IBOutlet weak var nicknameLabel: UILabel!
    @IBOutlet weak var loginBtn: UIButton!
    @IBOutlet weak var loginView: UIView!

    override public func viewDidLoad() {
        super.viewDidLoad()
        MenuViewController.instance = self
        var gesture = UITapGestureRecognizer(target: self, action: #selector(loginFun))
        loginBtn.isUserInteractionEnabled = true
        loginBtn.addGestureRecognizer(gesture)
        if (Auth.auth().currentUser != nil) {
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
                                setNickname(nickname)

                            } else {
                                let firebaseAuth = Auth.auth()
                                do {
                                    try firebaseAuth.signOut()
                                } catch let signOutError as NSError {
                                    print("Error signing out: %@", signOutError)
                                }
                            }
                            break;
                        default:
                            MainViewController.instance.view.makeToast("문제가 발생했습니다. 잠시후 다시 시도해주세요.")
                            break;
                        }
                    }
                }
            }
        }
    }

    func setNickname(_ nickname: String?) {
        if (nickname == nil) {

            loginView.isHidden = true
            loginBtn.isHidden = false
            nicknameLabel.text = "로그인을 해주세요."
        } else {
            loginView.isHidden = false
            loginBtn.isHidden = true
            nicknameLabel.text = "\(nickname!)님 환영합니다!"
        }
    }


    @IBAction func logoutFun(_ sender: Any) {
        MainViewController.instance.toggleMenu()
        logout()

    }

    @IBAction func friendListFun(_ sender: Any) {
        MainViewController.instance.toggleMenu()
        ShowViewController("FriendVC")
    }

    @IBAction func withdrawalFun(_ sender: Any) {
        MainViewController.instance.toggleMenu()
    }

    @objc func loginFun() {
        MainViewController.instance.toggleMenu()
        if (Auth.auth().currentUser == nil) {

            ShowViewController("LoginVC")
        } else {
            loginProcess()
        }
    }

    func logout() {
        showProgress()
        AlamofireSession.sendRestRequest(url: "logout.do", params: nil) { [self] dataResponse in
            dismissProgress()
            switch dataResponse.result {
            case .success(let value):
                let result = String(data: value!, encoding: .utf8)

                if "success" == result {
                    MainViewController.instance.view.makeToast("로그아웃 되었습니다.")
                    setNickname(nil)

                } else {
                    MainViewController.instance.view.makeToast("문제가 발생했습니다. 잠시후 다시 시도해주세요.")
                }

                break;
            default:
                MainViewController.instance.view.makeToast("문제가 발생했습니다. 잠시후 다시 시도해주세요.")
                break;
            }
        }

        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
        } catch let signOutError as NSError {
            print("Error signing out: %@", signOutError)
        }
    }

    func loginProcess() {
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
                            setNickname(nickname)
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
                                            setNickname(nickName)
                                            break;
                                        default:
                                            MainViewController.instance.view.makeToast("문제가 발생했습니다. 잠시후 다시 시도해주세요.")
                                            break;
                                        }
                                    }
                                }

                                break;
                            default:
                                MainViewController.instance.view.makeToast("문제가 발생했습니다. 잠시후 다시 시도해주세요.")
                                break;

                            }
                        }
                        break;
                    default:
                        MainViewController.instance.view.makeToast("문제가 발생했습니다. 잠시후 다시 시도해주세요.")
                        break;
                    }
                }
            }
        }


    }

}

