//
//  TrackingItemMenuDialog.swift
//  TravelMap
//
//  Created by 김한빈 on 2021/10/31.
//


import UIKit
import RealmSwift

class TrackingItemMenuDialog: UIViewController {

    @IBOutlet var outside: UIView!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet weak var deleteBtn: UIButton!
    @IBOutlet weak var renameBtn: UIButton!
    @IBOutlet weak var shareBtn: UIButton!
    var name = ""
    var trackingNum = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        var gesture = UITapGestureRecognizer(target: self, action: #selector(onClickOutsise(_:)))
        outside.isUserInteractionEnabled = true
        outside.addGestureRecognizer(gesture)

        gesture = UITapGestureRecognizer(target: self, action: #selector(deleteFun(_:)))
        deleteBtn.isUserInteractionEnabled = true
        deleteBtn.addGestureRecognizer(gesture)

        gesture = UITapGestureRecognizer(target: self, action: #selector(renameFun(_:)))
        renameBtn.isUserInteractionEnabled = true
        renameBtn.addGestureRecognizer(gesture)

        gesture = UITapGestureRecognizer(target: self, action: #selector(shareFun(_:)))
        shareBtn.isUserInteractionEnabled = true
        shareBtn.addGestureRecognizer(gesture)
        nameLabel.text = name

    }


    func setData(name: String, trackingNum: Int) {
        self.name = name
        self.trackingNum = trackingNum
    }

    @objc func onClickOutsise(_ sender: UITapGestureRecognizer) {
        finish()
    }

    @objc func deleteFun(_ sender: UITapGestureRecognizer) {

        let alertController = UIAlertController(title: nil, message: "정말로 '\(name)'을(를) 삭제 하시겠습니까?\n삭제후 복구는 불가능 합니다.", preferredStyle: .alert)

        let okAction = UIAlertAction(title: "예", style: .default) { (_) -> Void in

            let realm = try! Realm()
            let data = realm.objects(EventData.self).filter("trackingNum == \(self.trackingNum)")

            try! realm.write({
                realm.delete(data)
            })
            self.finish()
            (self.presentingViewController as! TrackingListViewController).loadTrackingData()

        }

        let cancelAction = UIAlertAction(title: "아니요", style: .default)

        alertController.addAction(okAction)
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true, completion: nil)

    }

    @objc func renameFun(_ sender: UITapGestureRecognizer) {
        finish()
        (self.presentingViewController as! TrackingListViewController).changeTrackingName()
    }

    @objc func shareFun(_ sender: UITapGestureRecognizer) {
        finish()
    }

}
