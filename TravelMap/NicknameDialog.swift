//
//  NicknameDialog.swift
//  TravelMap
//
//  Created by 김한빈 on 2021/11/09.
//

import UIKit
import SwiftyJSON

class NicknameDialog: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var nicknameTF: BorderTextField!
    @IBOutlet weak var okBtn: GradientButton!
    var nickname = ""
    var onOk: ((String) -> Void)!

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

    override func viewDidLoad() {
        super.viewDidLoad()
        nicknameTF.delegate = self
        let gesture = UITapGestureRecognizer(target: self, action: #selector(okFun))
        okBtn.isUserInteractionEnabled = true
        okBtn.addGestureRecognizer(gesture)
    }

    @objc func okFun() {
        showProgress()
        nickname = nicknameTF.text!
        let params = ["nickname": nickname]
        AlamofireSession.sendRestRequest(url: "checkNickname.do", params: params) { [self] response in
            switch response.result {
            case .success(_):
                let result = String(data: response.data!, encoding: .utf8)
                dismissProgress()
                if (result == "available") {


                    finish()
                    onOk(nickname)
                } else {
                    view.makeToast("중복된 닉네임입니다. 다른 닉네임을 입력해주세요.")

                }
                break;
            default:
                view.makeToast("문제가 발생했습니다. 잠시후 다시 시도해주세요.")


                dismissProgress()
                break;
            }
        }
    }

    func setOnOk(onOk: @escaping ((String) -> Void)) {

        self.onOk = onOk
    }


}
