//
//  MainViewController.swift
//  TravelMap
//
//  Created by 김한빈 on 2021/04/18.
//

import UIKit
import Photos
import SwiftCoroutine

class MainViewController: UIViewController {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var dailyBtn: UIView!
    @IBOutlet weak var albumBtn: UIView!
    @IBOutlet weak var mapBtn: UIView!
    @IBOutlet weak var trackinBtn: UIView!

    var btns: [UIView]!

    override func viewDidLoad() {
        super.viewDidLoad()
        let identifiers = ["DailyPhotoListVC", "AlbumVC", "MainMapVC", "TrackingMenuVC"]
        self.scrollView.contentSize.width = self.view.frame.width * 4
        for i in 0..<identifiers.count {
            guard let vc = self.storyboard?.instantiateViewController(withIdentifier: identifiers[i]) else {
                return
            }
            // Left View Controller를 Child View Controller로 지정
            self.addChild(vc)
            // Left View Controller의 View만 가져오기
            guard let vcView = vc.view else {
                return
            }
            // Left View Controller View의 Frame 지정
            vcView.frame = CGRect(x: CGFloat(i) * view.frame.width, y: 0, width: scrollView.frame.width, height: scrollView.frame.height)
            // Scroll View에 Left View Controller의 View 넣기
            self.scrollView.addSubview(vcView)
            // 이제 Left View Controller가 Container View Controller 앞으로 올라왔기 때문에 didmove(toParent:)를 실행
            vc.didMove(toParent: self)
        }
        btns = [dailyBtn, albumBtn, mapBtn, trackinBtn]
        var gesture = UITapGestureRecognizer(target: self, action: #selector(onBtn))

        for btn in btns {
            btn.isUserInteractionEnabled = true
            gesture = UITapGestureRecognizer(target: self, action: #selector(onBtn(_:)))
            btn.addGestureRecognizer(gesture)

        }
        if (PHPhotoLibrary.authorizationStatus() == .authorized) {

            PhotoService()

        } else {
            PHPhotoLibrary.requestAuthorization() { status in
                switch (status) {
                case .authorized:

                    PhotoService()
                    break;

                case .notDetermined:
                    break;
                case .restricted, .limited, .denied:
                    let alertController = UIAlertController(title: "권한이 필요합니다.", message: "Mybee 앱을 이용하기 위해 반드시 필요한 권한입니다. 설정을 통해 허용해 주세요.", preferredStyle: .alert)

                    let settingsAction = UIAlertAction(title: "예", style: .default) { (_) -> Void in
                        guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
                            return
                        }
                        if UIApplication.shared.canOpenURL(settingsUrl) {
                            UIApplication.shared.open(settingsUrl, completionHandler: { (success) in })
                        }

                    }
                    let cancelAction = UIAlertAction(title: "아니오", style: .default, handler: nil)

                    alertController.addAction(cancelAction)
                    alertController.addAction(settingsAction)
                    self.present(alertController, animated: true, completion: nil)

                    break
                @unknown default:
                    break
                }
            }
        }

        ChangeBtn(1)
    }

    @objc func onBtn(_ sender: UIGestureRecognizer) {
        sender.location(in: sender.view)
        let idx = btns.lastIndex(of: sender.view!)!

        ChangeBtn(idx)
    }

    func ChangeBtn(_ n: Int) {
        for b in btns {
            let btn = b as! ToggleButton
            btn.toggle(false)
        }
        let btn = btns[n] as! ToggleButton
        btn.toggle(true)
        scrollView.setContentOffset(CGPoint(x: Int(scrollView.contentSize.width) / 4 * n, y: 0), animated: true)

    }
}

