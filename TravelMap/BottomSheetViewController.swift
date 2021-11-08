//
//  BottomSheetViewController.swift
//  TravelMap
//
//  Created by 김한빈 on 2021/11/03.
//

import UIKit

class BottomSheetViewController: UIViewController {
    var maxScroll: CGFloat?
    var minScroll: CGFloat?
    var lastScroll = CGFloat(0)

    var velocity = CGFloat(0)

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var fullView: UIView!
    @IBOutlet weak var partialView: UIView!
    @IBOutlet weak var speed1: ToggleRoundButton!
    @IBOutlet weak var speed2: ToggleRoundButton!
    @IBOutlet weak var speed5: ToggleRoundButton!
    @IBOutlet weak var speed10: ToggleRoundButton!
    @IBOutlet weak var backwardBtn: UIImageView!
    @IBOutlet weak var startBtn: UIImageView!
    @IBOutlet weak var forwardBtn: UIImageView!
    var btns: [ToggleRoundButton]!
    var trackingMapVCInstance: TrackingMapViewController!


    /*func prepareBackgroundView() {
        let blurEffect = UIBlurEffect.init(style: .dark)
        let visualEffect = UIVisualEffectView.init(effect: blurEffect)
        let bluredView = UIVisualEffectView.init(effect: blurEffect)
        bluredView.contentView.addSubview(visualEffect)

        visualEffect.frame = UIScreen.main.bounds
        bluredView.frame = UIScreen.main.bounds

        view.insertSubview(bluredView, at: 0)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        prepareBackgroundView()
    }*/

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        let path = UIBezierPath(roundedRect: view.bounds,
                byRoundingCorners: [.topRight, .topLeft],
                cornerRadii: CGSize(width: 20, height: 20))

        let maskLayer = CAShapeLayer()

        maskLayer.path = path.cgPath
        view.layer.mask = maskLayer
        view.layer.masksToBounds = true
        trackingMapVCInstance.refreshViewHeight()
        UIView.animate(withDuration: 0.3) { [] in
            let frame = self.view.frame
            let yComponent = (TrackingMapViewController.instance.view.frame.height) - self.partialView.frame.height
            self.view.frame = CGRect(x: 0, y: yComponent, width: frame.width, height: frame.height)
        }
        maxScroll = (TrackingMapViewController.instance.view.frame.height) - self.partialView.frame.height
        minScroll = (TrackingMapViewController.instance.view.frame.height) - self.view.frame.height
        fullView.isHidden = false
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let panGesture = UIPanGestureRecognizer.init(target: self, action: #selector(BottomSheetViewController.panGesture))
        view.addGestureRecognizer(panGesture)

        tableView.tableFooterView = UIView()
        btns = [speed1, speed2, speed5, speed10]
        trackingMapVCInstance = (presentingViewController as! TrackingMapViewController)

        var gesture = UITapGestureRecognizer(target: self, action: #selector(trackingMapVCInstance.startFun))
        startBtn.isUserInteractionEnabled = true
        startBtn.addGestureRecognizer(gesture)

        gesture = UITapGestureRecognizer(target: self, action: #selector(trackingMapVCInstance.backwardFun))
        backwardBtn.isUserInteractionEnabled = true
        backwardBtn.addGestureRecognizer(gesture)

        gesture = UITapGestureRecognizer(target: self, action: #selector(trackingMapVCInstance.forwardFun))
        forwardBtn.isUserInteractionEnabled = true
        forwardBtn.addGestureRecognizer(gesture)

        for btn in btns {
            btn.isUserInteractionEnabled = true
            gesture = UITapGestureRecognizer(target: self, action: #selector(onBtn(_:)))
            btn.addGestureRecognizer(gesture)

        }
        ChangeBtn(0)
        fullView.isHidden = true
    }

    @objc func onBtn(_ sender: UITapGestureRecognizer) {
        sender.location(in: sender.view)
        let idx = btns.lastIndex(of: sender.view as! ToggleRoundButton)!


        trackingMapVCInstance.changeSpeed(idx)


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


    @objc func panGesture(recognizer: UIPanGestureRecognizer) {
        if (recognizer.state == .ended) {
            if (velocity >= -1.0 && velocity <= 1.0) {
                if (lastScroll > (maxScroll! + minScroll!) / 2) {

                    UIView.animate(withDuration: 0.2) { [self] in
                        self.view.frame = CGRect(x: 0, y: maxScroll!, width: view.frame.width, height: view.frame.height)
                        recognizer.setTranslation(CGPoint(x: 0, y: 0), in: self.view)
                    }
                } else {
                    UIView.animate(withDuration: 0.2) { [self] in
                        self.view.frame = CGRect(x: 0, y: minScroll!, width: view.frame.width, height: view.frame.height)
                        recognizer.setTranslation(CGPoint(x: 0, y: 0), in: self.view)
                    }
                }
            } else if (velocity > 1.0) {
                UIView.animate(withDuration: 0.2) { [self] in
                    self.view.frame = CGRect(x: 0, y: maxScroll!, width: view.frame.width, height: view.frame.height)
                    recognizer.setTranslation(CGPoint(x: 0, y: 0), in: self.view)
                }
            } else {
                UIView.animate(withDuration: 0.2) { [self] in
                    self.view.frame = CGRect(x: 0, y: minScroll!, width: view.frame.width, height: view.frame.height)
                    recognizer.setTranslation(CGPoint(x: 0, y: 0), in: self.view)
                }
            }
        } else {
            let translation = recognizer.translation(in: self.view)
            let y = self.view.frame.minY
            lastScroll = y + translation.y
            velocity = translation.y
            if (lastScroll < maxScroll! && lastScroll > minScroll!) {

                self.view.frame = CGRect(x: 0, y: lastScroll, width: view.frame.width, height: view.frame.height)
                recognizer.setTranslation(CGPoint(x: 0, y: 0), in: self.view)

            }
        }
    }

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        let gesture = (gestureRecognizer as! UIPanGestureRecognizer)
        let direction = gesture.velocity(in: view).y

        let y = view.frame.minY
        if (y == fullView.frame.height && tableView.contentOffset.y == 0 && direction > 0) || (y == partialView.frame.height) {
            tableView.isScrollEnabled = false
        } else {
            tableView.isScrollEnabled = true
        }

        return false
    }
}

