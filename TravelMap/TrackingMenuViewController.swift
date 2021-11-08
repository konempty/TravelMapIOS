//
//  TrackingMenuViewController.swift
//  TravelMap
//
//  Created by 김한빈 on 2021/04/18.
//

import UIKit
import CoreLocation
import RealmSwift
import Photos

class TrackingMenuViewController: UIViewController, CLLocationManagerDelegate {
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

    var locationManager: CLLocationManager!
    //var timer: Timer!
    var lastTime: Int = 0
    let time: [Int] = [30, 150, 300]
    var isInited = false
    var id: AtomicInteger!


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

        id = AtomicInteger(try! Realm().objects(EventData.self).map {
            $0.id
        }.max() { i1, i2 in
            return i1 < i2
        } ?? 0)


        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.allowsBackgroundLocationUpdates = true
        //locationManager.startUpdatingLocation()
        locationManager.pausesLocationUpdatesAutomatically = false


    }

    override func viewDidAppear(_ animated: Bool) {
        if (MyPreferences.trackingState != 0) {

            trackingStEn.setTitle("여행 기록 종료", for: .normal)
            ChangeBtn(time.firstIndex(of: MyPreferences.trackingTime)!)
            if (MyPreferences.trackingState == 1) {
                trackingPause.setTitle("여행 기록 재개", for: .normal)
            } else {
                trackingPause.setTitle("여행 기록 일시중지", for: .normal)
                startTracker()
            }
            trackingSetting.isHidden = false
            constraint1.isActive = false
            constraint2.isActive = true
        }
    }

    @objc func onBtn(_ sender: UIGestureRecognizer) {
        sender.location(in: sender.view)
        let idx = btns.lastIndex(of: sender.view as! ToggleRoundButton)!
        let realm = try! Realm()


        let trackingNum = realm.objects(EventData.self).map {
            $0.trackingNum
        }.max() { i1, i2 in
            return i1 < i2
        }!
        MyPreferences.trackingTime = time[idx]
        try? realm.write() {
            realm.add(EventData(id: id.incrementAndGet(), trackingNum: trackingNum, eventNum: 4, trackingSpeed: idx))
        }
        stopTracker()
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
            self.startTracker()
        }


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
        if (MyPreferences.trackingState == 0) {
            if (checkGPS()) {
                MyPreferences.trackingState = 2
                ChangeBtn(time.firstIndex(of: MyPreferences.trackingTime)!)
                trackingStEn.setTitle("여행 기록 종료", for: .normal)
                trackingSetting.isHidden = false
                constraint1.isActive = false
                constraint2.isActive = true
                DispatchQueue.global().async { [self] in
                    let realm = try! Realm()

                    let trackingNum = (realm.objects(EventData.self).map {
                        $0.trackingNum
                    }.max() { i1, i2 in
                        return i1 < i2
                    } ?? 0) + 1


                    try? realm.write() {
                        realm.add(EventData(id: id.incrementAndGet(), trackingNum: trackingNum, eventNum: 0))
                    }
                    startTracker()
                }
            }
        } else {

            let alertController = UIAlertController(title: nil, message: "여행기록을 끝내시겠습니까?", preferredStyle: .alert)

            let settingsAction = UIAlertAction(title: "예", style: .default) { [self] (_) -> Void in

                let realm = try! Realm()
                let trackingNum = realm.objects(EventData.self).map {
                    $0.trackingNum
                }.max() { i1, i2 in
                    return i1 < i2
                }!

                let uvc = self.storyboard?.instantiateViewController(withIdentifier: "TrackingNameDialog") as! TrackingNameDialog
                uvc.modalPresentationStyle = .overCurrentContext
                uvc.setData(name: "여행기록\(trackingNum)", trackingNum: trackingNum, isEdit: false)
                uvc.setOnOk() { [self]nameTmp in

                    DispatchQueue.main.async {

                        var name = nameTmp
                        if name.isEmpty {
                            name = "여행기록\(trackingNum)"
                        }
                        MyPreferences.trackingState = 0
                        trackingStEn.setTitle("여행 기록 시작", for: .normal)
                        trackingPause.setTitle("여행 기록 일시중지", for: .normal)
                        trackingSetting.isHidden = true
                        constraint2.isActive = false
                        constraint1.isActive = true

                        stopTracker()
                        DispatchQueue.global().async {
                            let realm = try! Realm()
                            try? realm.write() {
                                realm.add(EventData(id: id.incrementAndGet(), trackingNum: trackingNum, eventNum: 2, name: name))
                            }
                        }
                    }

                }
                present(uvc, animated: true)


            }
            let cancelAction = UIAlertAction(title: "아니오", style: .default)

            alertController.addAction(settingsAction)
            alertController.addAction(cancelAction)
            self.present(alertController, animated: true, completion: nil)

        }
    }

    @objc func trackingPauseFun() {
        if (MyPreferences.trackingState == 1) {
            if (checkGPS()) {
                let realm = try! Realm()


                let trackingNum = realm.objects(EventData.self).map {
                    $0.trackingNum
                }.max() { i1, i2 in
                    return i1 < i2
                }!

                try? realm.write() {
                    realm.add(EventData(id: id.incrementAndGet(), trackingNum: trackingNum, eventNum: 0))
                }
                startTracker()


                trackingPause.setTitle("여행 기록 일시중지", for: .normal)

                MyPreferences.trackingState = 2

            }
        } else {
            let realm = try! Realm()


            let trackingNum = realm.objects(EventData.self).map {
                $0.trackingNum
            }.max() { i1, i2 in
                return i1 < i2
            }!

            try? realm.write() {
                realm.add(EventData(id: id.incrementAndGet(), trackingNum: trackingNum, eventNum: 1))
            }

            stopTracker()
            trackingPause.setTitle("여행 기록 재개", for: .normal)
            MyPreferences.trackingState = 1
        }
    }

    @objc func trackingListFun() {
        ShowViewController("TrackingListVC")
    }

    var lastLoction: CLLocationCoordinate2D!

    func startTracker() {

        let realm = try! Realm()
        lastTime = Int((realm.objects(EventData.self).filter("eventNum != 4 ").sorted(byKeyPath: "id", ascending: false).first?.time?.timeIntervalSince1970)!)

        if let lastKnownLocation = locationManager.location?.coordinate {
            lastLoction = lastKnownLocation
            findNewPicture()
        }

        /*timer = Timer.scheduledTimer(timeInterval: TimeInterval(MyPreferences.trackingTime),
                target: self,
                selector: #selector(self.updateLocations),
                userInfo: nil,
                repeats: true)*/
        locationManager.startUpdatingLocation()

    }

    func checkGPS() -> Bool {
        if CLLocationManager.locationServicesEnabled() {
            switch CLLocationManager.authorizationStatus() {
            case .authorizedAlways, .authorizedWhenInUse:


                return true
            case .notDetermined:
                self.locationManager.requestAlwaysAuthorization()
                break
            case .restricted, .denied:
                let alertController = UIAlertController(title: "권한이 필요합니다.", message: "여행기록을 하기 위해 반드시 필요한 권한입니다. 설정을 통해 허용해 주세요.", preferredStyle: .alert)

                let settingsAction = UIAlertAction(title: "예", style: .default) { (_) -> Void in
                    guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
                        return
                    }
                    if UIApplication.shared.canOpenURL(settingsUrl) {
                        UIApplication.shared.open(settingsUrl, completionHandler: { (success) in })
                    }

                }
                let cancelAction = UIAlertAction(title: "아니오", style: .default)

                alertController.addAction(cancelAction)
                alertController.addAction(settingsAction)
                self.present(alertController, animated: true, completion: nil)
                break
            @unknown default:
                break
            }
        } else {
            let alertController = UIAlertController(title: "GPS가 꺼져있습니다.", message: "GPS가 꺼져있습니다. GPS를 켠후 다시 시도해주세요.", preferredStyle: .alert)

            let settingsAction = UIAlertAction(title: "확인", style: .default)
            alertController.addAction(settingsAction)
            self.present(alertController, animated: true, completion: nil)
        }
        return false
    }

    func stopTracker() {
        //timer.invalidate()
        locationManager.stopUpdatingLocation()
        findNewPicture()
    }

    @objc func updateLocations() {
        locationManager.startUpdatingLocation()

    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        //위치가 업데이트될때마다
        if (Int(NSDate().timeIntervalSince1970) - lastTime > MyPreferences.trackingTime - 1) {
            if let coor = manager.location?.coordinate {
                print("latitude" + String(coor.latitude) + "/ longitude" + String(coor.longitude))
                let realm = try! Realm()

                let trackingNum = realm.objects(EventData.self).map {
                    $0.trackingNum
                }.max() { i1, i2 in
                    return i1 < i2
                }!
                try! realm.write {
                    realm.add(EventData(id: id.incrementAndGet(), trackingNum: trackingNum, eventNum: 3, lat: coor.latitude, lng: coor.longitude, time: Date()))
                }
                lastLoction = coor
                findNewPicture()


            }
        }
    }

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if (isInited) {
            trackingStartEndFun()
        }
        isInited = true

    }

    func findNewPicture() {
        DispatchQueue.global().async { [self] in
            let realm = try! Realm()
            let fetchOptions = PHFetchOptions()
            fetchOptions.sortDescriptors = [NSSortDescriptor(key: "modificationDate", ascending: false)]
            fetchOptions.includeAssetSourceTypes = [.typeUserLibrary]
            fetchOptions.predicate = NSPredicate(format: "(mediaType = %d || mediaType = %d) && modificationDate > %@", PHAssetMediaType.image.rawValue, PHAssetMediaType.video.rawValue, Date(timeIntervalSince1970: TimeInterval(self.lastTime)) as CVarArg)
            let allPhotos = PHAsset.fetchAssets(with: fetchOptions)
            PhotoService.allPhotos = allPhotos
            var list = [EventData]()


            let trackingNum = realm.objects(EventData.self).map {
                $0.trackingNum
            }.max() { i1, i2 in
                return i1 < i2
            } ?? 0
            for i in 0..<allPhotos.count {
                let photo = allPhotos[i]
                let name = photo.value(forKey: "filename") as! String
                let dir = photo.value(forKey: "directory") as! String
                let date = photo.value(forKey: "modificationDate") as! Date
                let media = photo.value(forKey: "mediaType") as! Int == PHAssetMediaType.video.rawValue
                var loc = photo.location?.coordinate
                if (loc == nil) {
                    loc = lastLoction
                }

                list.append(EventData(id: id.incrementAndGet(), trackingNum: trackingNum, eventNum: 5, lat: loc?.latitude, lng: loc?.longitude, pictureId: photo.localIdentifier, name: name, path: dir, isVideo: media, time: date))


            }
            try? realm.write() {
                realm.add(list)
            }


            lastTime = Int(NSDate().timeIntervalSince1970)
        }
    }
}
