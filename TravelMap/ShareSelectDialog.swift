//
//  ShareSelectDialog.swift
//  TravelMap
//
//  Created by 김한빈 on 2021/11/06.
//

import UIKit
import Toast

class ShareSelectDialog: UIViewController, UITextFieldDelegate {


    @IBOutlet weak var shareAllBtn: ToggleRoundButton!
    @IBOutlet weak var shareFriendBtn: ToggleRoundButton!
    @IBOutlet weak var shareLockBtn: ToggleRoundButton!
    @IBOutlet weak var passwordView: UIView!
    @IBOutlet weak var passwordTF: BorderTextField!
    @IBOutlet weak var passwordCheckTF: BorderTextField!
    @IBOutlet weak var qualityOriginBtn: ToggleRoundButton!
    @IBOutlet weak var qualityHighBtn: ToggleRoundButton!
    @IBOutlet weak var qualityNormBtn: ToggleRoundButton!
    @IBOutlet weak var okBtn: GradientButton!
    @IBOutlet var outside: UIView!

    @IBOutlet weak var lockConstraint: NSLayoutConstraint!
    @IBOutlet weak var notLockConstraint: NSLayoutConstraint!
    var shareBtns: [ToggleRoundButton]!
    var qualituBtns: [ToggleRoundButton]!
    var onOkListener: (() -> Void)!

    let regex = try! NSRegularExpression(pattern: "^[a-zA-Z|0-9!@#\\$%^&*()+_\\-\\\\.,/?;:'\"\\[{}\\]~`]*$", options: .caseInsensitive)
    var shareSlectrion = 0
    var qualitySelection = 0
    var pswd = ""

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if string == "" {
            return true
        }
        if (!match(input: string)) {
            view.makeToast("영문,숫자,특수기호만 입력해주세요.", position: .top)
            return false
        }
        return true

    }

    private func match(input: String) -> Bool {
        let range = NSRange(input.startIndex..., in: input)
        let matches = regex.matches(in: input, options: [], range: range)
        let matchedString = matches.map { match -> String in
            let range = Range(match.range, in: input)!
            return String(input[range])
        }
        return matchedString.count == 1 && matchedString[0] == input
    }

    override func viewDidLoad() {
        super.viewDidLoad()


        shareBtns = [shareAllBtn, shareFriendBtn, shareLockBtn]
        qualituBtns = [qualityOriginBtn, qualityHighBtn, qualityNormBtn]

        var gesture = UITapGestureRecognizer(target: self, action: #selector(onOk(_:)))
        okBtn.isUserInteractionEnabled = true
        okBtn.addGestureRecognizer(gesture)

        gesture = UITapGestureRecognizer(target: self, action: #selector(onClickOutside))
        outside.isUserInteractionEnabled = true
        outside.addGestureRecognizer(gesture)

        for btn in shareBtns {
            btn.isUserInteractionEnabled = true
            gesture = UITapGestureRecognizer(target: self, action: #selector(onShareBtn(_:)))
            btn.addGestureRecognizer(gesture)
            btn.toggle(false)
        }

        for btn in qualituBtns {
            btn.isUserInteractionEnabled = true
            gesture = UITapGestureRecognizer(target: self, action: #selector(onQualityBtn(_:)))
            btn.addGestureRecognizer(gesture)
            btn.toggle(false)
        }
        passwordTF.delegate = self
        passwordCheckTF.delegate = self

        shareAllBtn.toggle(true)
        qualityOriginBtn.toggle(true)

    }

    @objc func onShareBtn(_ sender: UITapGestureRecognizer) {
        let idx = shareBtns.lastIndex(of: sender.view as! ToggleRoundButton)!
        for b in shareBtns {
            let btn = b
            btn.toggle(false)
        }
        if (idx == 2) {
            passwordView.isHidden = false
            notLockConstraint.isActive = false
            lockConstraint.isActive = true
        } else {
            passwordView.isHidden = true
            lockConstraint.isActive = false
            notLockConstraint.isActive = true
        }
        shareSlectrion = idx
        let btn = shareBtns[idx]
        btn.toggle(true)
    }

    @objc func onQualityBtn(_ sender: UITapGestureRecognizer) {
        let idx = qualituBtns.lastIndex(of: sender.view as! ToggleRoundButton)!
        for b in qualituBtns {
            let btn = b
            btn.toggle(false)
        }
        qualitySelection = idx
        let btn = qualituBtns[idx]
        btn.toggle(true)
    }

    @objc func onClickOutside() {
        finish()
    }


    func setOnOk(listener: @escaping (() -> Void)) {
        onOkListener = listener
    }

    @objc func onOk(_ sender: UITapGestureRecognizer) {
        if (shareSlectrion == 2) {
            pswd = passwordTF.text!
            let pswdCheck = passwordCheckTF.text!

            if (pswd.isEmpty || pswdCheck.isEmpty) {
                view.makeToast("비밀번호를 입력해주세요.")
                return
            } else if (pswd != pswdCheck) {
                view.makeToast("비밀번호와 비밀번호 확인의 내용이 같지않습니다.")
                return
            }
        }
        finish()
        onOkListener()
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if (textField == passwordTF) {
            passwordCheckTF.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
        }
        return true
    }

}
