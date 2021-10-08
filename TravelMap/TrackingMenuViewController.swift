//
//  TrackingMenuViewController.swift
//  TravelMap
//
//  Created by 김한빈 on 2021/04/18.
//

import UIKit

class TrackingMenuViewController: UIViewController {
    @IBOutlet weak var trackingStEn: GradientButton!
    @IBOutlet weak var trackingSetting: UIView!
    @IBOutlet weak var trackingPause: UIButton!
    @IBOutlet weak var speed1: ToggleRoundButton!
    @IBOutlet weak var speed2: ToggleRoundButton!
    @IBOutlet weak var speed3: ToggleRoundButton!
    @IBOutlet weak var trackingList: GradientButton!
    @IBOutlet weak var constraint1: NSLayoutConstraint!
    @IBOutlet weak var constraint2: NSLayoutConstraint!
    var btns: [ToggleRoundButton]!
    var isStarted = false
    var isPaused = false


    override func viewDidLoad() {
        btns = [speed1, speed2, speed3]
        var gesture = UITapGestureRecognizer(target: self, action: #selector(trackingStartEndFun))
        trackingStEn.isUserInteractionEnabled = true
        trackingStEn.addGestureRecognizer(gesture)

        gesture = UITapGestureRecognizer(target: self, action: #selector(trackingPauseFun))
        trackingPause.isUserInteractionEnabled = true
        trackingPause.addGestureRecognizer(gesture)


        gesture = UITapGestureRecognizer(target: self, action: #selector(trackingListFun))
        trackingList.isUserInteractionEnabled = true
        trackingList.addGestureRecognizer(gesture)

        for btn in btns {
            btn.isUserInteractionEnabled = true
            gesture = UITapGestureRecognizer(target: self, action: #selector(onBtn(_:)))
            btn.addGestureRecognizer(gesture)

        }

        ChangeBtn(1)
    }

    @objc func onBtn(_ sender: UIGestureRecognizer) {
        sender.location(in: sender.view)
        let idx = btns.lastIndex(of: sender.view as! ToggleRoundButton)!

        ChangeBtn(idx)
    }

    func ChangeBtn(_ n: Int) {
        for b in btns {
            let btn = b
            btn.toggle(false)
        }
        let btn = btns[n]
        btn.toggle(true)

    }

    @objc func trackingStartEndFun() {
        if (isStarted) {
            trackingStEn.setTitle("여행 기록 시작", for: .normal)
            trackingPause.setTitle("여행 기록 일시중지", for: .normal)
            ChangeBtn(1)
            trackingSetting.isHidden = true
            constraint2.isActive = false
            constraint1.isActive = true
        } else {

            trackingStEn.setTitle("여행 기록 중지", for: .normal)
            trackingSetting.isHidden = false
            constraint1.isActive = false
            constraint2.isActive = true
            isPaused = false
        }
        isStarted = !isStarted
    }

    @objc func trackingPauseFun() {
        if (isPaused) {

            trackingPause.setTitle("여행 기록 일시중지", for: .normal)
        } else {

            trackingPause.setTitle("여행 기록 재개", for: .normal)
        }
        isPaused = !isPaused
    }

    @objc func trackingListFun() {
        ShowViewController("TrackingListVC")
    }
}
