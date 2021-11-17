//
//  PasswordDialog.swift
//  TravelMap
//
//  Created by 김한빈 on 2021/11/15.
//

import UIKit

class PasswordDialog: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var passwordET: BorderTextField!
    var password = ""
    var onOk: ((String) -> Void)!

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        passwordET.resignFirstResponder()
        return true
    }

    override func viewDidLoad() {
        passwordET.attributedPlaceholder = NSAttributedString(
                string: "비밀번호를 입력해주세요.",
                attributes: [.foregroundColor: UIColor.init(white: 1, alpha: 0.5)]
        )
    }

    func setOnOk(onOk: @escaping ((String) -> Void)) {
        self.onOk = onOk
    }

    @IBAction func okFun() {
        password = passwordET.text!
        passwordET.resignFirstResponder()

        if (password.isEmpty) {
            view.makeToast("비밀번호를 입력해주세요.")
        } else {
            finish()
            DispatchQueue.global().asyncAfter(deadline: .now() + 2) { [self] in
                onOk(password)
            }
        }
    }


}
