//
//  TrackingNameDialog.swift
//  TravelMap
//
//  Created by 김한빈 on 2021/10/31.
//

import UIKit

class TrackingNameDialog: UIViewController, UITextFieldDelegate {

    @IBOutlet var outside: UIView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var msgLabel: UILabel!
    @IBOutlet var okBtn: UIButton!
    @IBOutlet var nameTF: UITextField!
    var onOk: ((String) -> Void)!
    var name = ""
    var trackingNum = 0
    var isEdit = false

    override func viewDidLoad() {
        super.viewDidLoad()
        var gesture = UITapGestureRecognizer(target: self, action: #selector(onClickOutsise(_:)))
        outside.isUserInteractionEnabled = true
        outside.addGestureRecognizer(gesture)

        gesture = UITapGestureRecognizer(target: self, action: #selector(onClickOK(_:)))
        okBtn.isUserInteractionEnabled = true
        okBtn.addGestureRecognizer(gesture)
        nameTF.delegate = self

        if (isEdit) {
            titleLabel.text = "여행기록 이름 변경"
            msgLabel.text = "변경할 여행기록 이름을 입력해주세요."
            nameTF.text = name
        } else {
            titleLabel.text = "여행기록 저장"
            msgLabel.text = "이번 여행을 기억할 수 있게\n여행 기록에 이름을 정해주세요."
        }
        nameTF.attributedPlaceholder = NSAttributedString(
                string: name,
                attributes: [.foregroundColor: UIColor.init(white: 1, alpha: 0.5)]
        )

    }


    func setData(name: String, trackingNum: Int, isEdit: Bool) {
        self.name = name
        self.trackingNum = trackingNum
        self.isEdit = isEdit
    }

    func setOnOk(onOk: @escaping ((String) -> Void)) {
        self.onOk = onOk
    }

    @objc func onClickOutsise(_ sender: UITapGestureRecognizer) {
        finish()
    }

    @objc func onClickOK(_ sender: UITapGestureRecognizer) {
        onOk(nameTF.text ?? name)
        self.view.endEditing(true)
        finish()
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        nameTF.resignFirstResponder()
        return true
    }

}
