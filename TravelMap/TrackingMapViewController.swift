//
//  TrackingMapViewController.swift
//  TravelMap
//
//  Created by 김한빈 on 2021/11/03.
//

import UIKit
import GoogleMaps
import GoogleMapsUtils
import RealmSwift


class TrackingMapViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, GMSMapViewDelegate, GMUClusterRendererDelegate, GMUClusterManagerDelegate {
    var trackingNum: Int = 0
    var items: [String] = []
    var lastLocIdx = -1
    var nextIdx = 0
    var isDiscrete = true
    var zoomlevel = 0
    var angle = 0.0
    let zoomLevels: [Float] = [20.0, 18.0, 16.0]
    var speed = 1
    var isAuto = true
    var lastLoc: CLLocationCoordinate2D!

    static var clusterList = [BaseData]()


    static var instance: TrackingMapViewController!
    @IBOutlet weak var coverView: UIView!
    @IBOutlet weak var backBtn: WhiteImageView!
    var bottomSheetVC: BottomSheetViewController!
    var clusterManager: GMUClusterManager!
    var mapView: GMSMapView!
    var isPause = true
    var isStop = true
    var isAccuratePoint = true
    var centerMarker = GMSMarker(position: CLLocationCoordinate2D(latitude: 0, longitude: 0))

    var eventList: [EventData]!
    var trackingLogs = [EventData]()

    class MyItem: NSObject, GMUClusterItem {
        var position: CLLocationCoordinate2D

        let item: EventData
        let image: UIImage

        init(position: CLLocationCoordinate2D, image: UIImage, item: EventData) {
            self.position = position
            self.image = image
            self.item = item
        }

    }


    override func viewDidLoad() {
        TrackingMapViewController.instance = self

        centerMarker.icon = GMSMarker.markerImage(with: UIColor.blue)
        backBtn.isUserInteractionEnabled = true
        let gesture = UITapGestureRecognizer(target: self, action: #selector(back(_:)))
        backBtn.addGestureRecognizer(gesture)

        addBottomSheetView()

        mapView = GMSMapView(frame: self.view.frame)
        let setting = mapView.settings
        setting.tiltGestures = false
        setting.rotateGestures = false
        setting.zoomGestures = false
        setting.scrollGestures = false
        setting.compassButton = false

        self.view.addSubview(mapView)
        self.view.sendSubviewToBack(mapView)

        let iconGenerator = GMUDefaultClusterIconGenerator()
        let algorithm = GMUNonHierarchicalDistanceBasedAlgorithm()
        let renderer = GMUDefaultClusterRenderer(mapView: mapView, clusterIconGenerator: iconGenerator)
        renderer.delegate = self
        renderer.minimumClusterSize = 2
        clusterManager = GMUClusterManager(map: mapView, algorithm: algorithm, renderer: renderer)

        // Register self to listen to GMSMapViewDelegate events.
        clusterManager.setDelegate(self, mapDelegate: self)
        centerMarker.map = mapView
        initCluster()
    }

    @objc func back(_ sender: UITapGestureRecognizer) {
        finish()
    }

    @objc func forwardFun() {

        goFoward()
    }

    func startFun() {
        isPause = !isPause
        if (isStop) {
            bottomSheetVC.startBtn.image = UIImage(named: "pause")
            isStop = false
            getStartPoint()
            nextTracking()
        } else if (isPause) {
            bottomSheetVC.startBtn.image = UIImage(named: "start Btn")
            pauseAnimation()
        } else {
            bottomSheetVC.startBtn.image = UIImage(named: "pause")
            resumeAnimation()
        }
    }

    @objc func backwardFun() {

        goPrev()
    }

    @objc func changeSpeed(_ speed: Int) {
        let speeds = [1, 2, 5, 10]
        pauseAnimation()
        self.speed = speeds[speed]
        resumeAnimation()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        items.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "tableCell", for: indexPath)

        cell.selectionStyle = .none
        cell.textLabel?.text = items[indexPath.row]
        cell.textLabel?.font = UIFont(name: "BMJUAOTF", size: 16)
        cell.textLabel?.textColor = .white

        //drawDottedLine(start: CGPoint(x: 0, y: 0), end: CGPoint(x: cell.Separator.frame.width, y: 0), view: cell.Separator)
        //addDashedBottomBorder(cell)
        return cell
    }


    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //click
    }

    func refreshViewHeight() {


        // 3- Adjust bottomSheet frame and initial position.
        let height = view.frame.height / 2
        let width = view.frame.width
        bottomSheetVC!.view.frame = CGRect(x: 0, y: self.view.frame.maxY, width: width, height: height)
    }


    func addBottomSheetView() {
        // 1- Init bottomSheetVC
        bottomSheetVC = ((self.storyboard?.instantiateViewController(withIdentifier: "BottomSheetVC"))! as! BottomSheetViewController)


        // 2- Add bottomSheetVC as a child view
        self.addChild(bottomSheetVC)
        self.view.addSubview(bottomSheetVC.view)
        bottomSheetVC!.didMove(toParent: self)
        self.view.sendSubviewToBack(bottomSheetVC.view)
        bottomSheetVC.tableView.delegate = self
        bottomSheetVC.tableView.dataSource = self

    }

    func renderer(_ renderer: GMUClusterRenderer, willRenderMarker marker: GMSMarker) {
        var icon: UIImage? = nil
        var count = 0
        if let cluster = (marker.userData as? GMUCluster) {
            let items = (cluster.items as! [MyItem]).sorted() { i1, i2 in
                i1.item.time < i2.item.time
            }
            let markerData = items.last!
            icon = markerData.image
            count = items.count
        } else if let markerData = marker.userData as? MyItem {
            icon = markerData.image
            count = 0
        }
        marker.iconView = CustomMarkerView(image: icon!, count: count)
        marker.iconView?.frame = CGRect(x: 0, y: 0, width: 85, height: 75)
    }

    func clusterManager(_ clusterManager: GMUClusterManager, didTap cluster: GMUCluster) -> Bool {
        TrackingMapViewController.clusterList.removeAll()
        let items = (cluster.items as! [MyItem]).sorted() { i1, i2 in
            i1.item.time > i2.item.time
        }
        for it in items {
            TrackingMapViewController.clusterList.append(it.item)
        }
        ImageListViewController.imageList = TrackingMapViewController.clusterList
        ShowViewController("ImageListVC")
        return true
    }

    func clusterManager(_ clusterManager: GMUClusterManager, didTap clusterItem: GMUClusterItem) -> Bool {
        TrackingMapViewController.clusterList.removeAll()
        TrackingMapViewController.clusterList.append((clusterItem as! MyItem).item)

        ImageListViewController.imageList = TrackingMapViewController.clusterList
        ShowViewController("ImageListVC")
        return true
    }

    func mapView(_ mapView: GMSMapView, didChange position: GMSCameraPosition) {
        centerMarker.position = mapView.camera.target
        if (!isPause) {
            isAccuratePoint = false
        } else {
            stopAnimation()
        }
    }

    func stopAnimation() {


        CATransaction.begin()
        CATransaction.setDisableActions(true)
        CATransaction.commit()
    }

    func initCluster() {
        clusterManager.clearItems()
        mapView.clear()
        var path = GMSMutablePath()
        DispatchQueue.global().async { [self] in
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy년 MM월 dd일"
            var dataList = [EventData]()
            let realm = try! Realm()
            eventList = Array(realm.objects(EventData.self).filter("trackingNum == \(trackingNum)"))

            for item in eventList {
                let item = EventData(other: item)
                switch (item.eventNum) {
                case 0:
                    DispatchQueue.main.async {
                        let polyline = GMSPolyline(path: path)
                        polyline.strokeColor = UIColor.black
                        polyline.strokeWidth = 5.0
                        polyline.map = mapView
                        path = GMSMutablePath()
                    }
                    trackingLogs.append(item)
                    break
                case 3:
                    lastLocIdx = trackingLogs.count
                    path.add(item.latlng)
                    items.append(dateFormatter.string(from: item.time!))
                    dataList.append(item)
                    trackingLogs.append(item)
                    break;
                case 4:
                    trackingLogs.append(item)
                    break;
                case 5:
                    self.requestIamge(with: item.asset, thumbnailSize: CGSize(width: 100, height: 100)) { [self] image in
                        if (image != nil) {
                            let location = item.latlng
                            let marker = MyItem(position: location, image: image!, item: item)

                            clusterManager.add(marker)
                        }
                    }
                    break;
                default:
                    break;
                }
            }

            DispatchQueue.main.async {
                bottomSheetVC.tableView.reloadData()
                let polyline = GMSPolyline(path: path)
                polyline.strokeColor = UIColor.black
                polyline.strokeWidth = 5.0
                polyline.map = mapView
                path = GMSMutablePath()
                clusterManager.cluster()
                getStartPoint()
                coverView.isHidden = true
            }
        }
    }

    func nextTracking() {
        if (nextIdx == trackingLogs.count) {
            isStop = true
            isPause = true
            bottomSheetVC.startBtn.image = UIImage(named: "start Btn")
            isAccuratePoint = true
            return
        }
        let item = trackingLogs[nextIdx]
        nextIdx += 1

        switch (item.eventNum) {
        case 0:
            isDiscrete = true
            nextTracking()
            break;
        case 3:
            if (!isPause) {
                DispatchQueue.main.async { [self] in
                    usleep(100000)
                    var cameraPosition: GMSCameraPosition

                    if (isAuto) {
                        if (!isDiscrete) {
                            angle = bearing(
                                    lastLoc.latitude,
                                    lastLoc.longitude,
                                    item.latlng.latitude,
                                    item.latlng.longitude
                            )
                            //  CATransaction.begin()
                            //   CATransaction.setDisableActions(true)
                            //    CATransaction.setAnimationDuration(1.0 / Double(speed))
                            mapView.animate(to: GMSCameraPosition.camera(
                                    withLatitude: lastLoc.latitude,
                                    longitude: lastLoc.longitude,
                                    zoom: zoomLevels[zoomlevel],
                                    bearing: angle, viewingAngle: 90.0

                            ))
                            //    CATransaction.commit()
                            usleep(useconds_t(500000 / speed))
                        }
                        cameraPosition = GMSCameraPosition.camera(
                                withLatitude: item.latlng.latitude,
                                longitude: item.latlng.longitude,
                                zoom: zoomLevels[zoomlevel],
                                bearing: angle, viewingAngle: 90.0)
                    } else {
                        cameraPosition = GMSCameraPosition.camera(withLatitude: item.latlng.latitude, longitude: item.latlng.longitude, zoom: mapView.camera.zoom)
                    }
                    var animateTime = 0.0
                    if (isDiscrete) {
                        isDiscrete = false
                        animateTime = 0.001
                    } else {
                        animateTime = Double(3 / speed)
                    }
                    //CATransaction.begin()
                    //CATransaction.setDisableActions(true)
                    //CATransaction.setValue(animateTime, forKey: kCATransactionAnimationDuration)
                    //CATransaction.setAnimationDuration(animateTime)
                    mapView.animate(to: cameraPosition)
                    /*CATransaction.setCompletionBlock({
                        lastLoc = item.latlng
                        nextTracking()
                    })
                   CATransaction.commit()*/
                }
            }


            break;
        case 4:
            zoomlevel = item.trackingSpeed.value!
            nextTracking()
            break;
        default:
            break;
        }
    }

    func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
        centerMarker.position = mapView.camera.target
        lastLoc = mapView.camera.target
        nextTracking()
    }

    func goFoward() {
        if (nextIdx <= trackingLogs.count) {
            stopAnimation()
            let item = trackingLogs[nextIdx - 1]

            var cameraPosition: GMSCameraPosition

            if (isAuto) {
                angle = bearing(
                        lastLoc.latitude,
                        lastLoc.longitude,
                        item.latlng.latitude,
                        item.latlng.longitude
                )
                cameraPosition = GMSCameraPosition.camera(
                        withLatitude: item.lat.value!,
                        longitude: item.lng.value!,
                        zoom: zoomLevels[zoomlevel]

                )

            } else {
                cameraPosition = GMSCameraPosition.camera(
                        withLatitude: item.lat.value!,
                        longitude: item.lng.value!,
                        zoom: mapView.camera.zoom

                )
            }

            mapView.camera = cameraPosition
            lastLoc = item.latlng
            centerMarker.position = lastLoc
            isAccuratePoint = true


            nextTracking()
        }
    }

    func goPrev() {
        if (nextIdx != trackingLogs.count && isStop) {
            return
        }
        stopAnimation()
        let back = isAccuratePoint && !isStop ? 2 : 1
        //얼마만큼 이전으로 돌아가서 찾아야 하는지
        isStop = false
        var item = trackingLogs[nextIdx - back]


        for idx in (nextIdx - back...0).reversed() {
            let item2 = trackingLogs[idx]
            if (item2.eventNum == 3) {
                item = item2
                break;
            }
            nextIdx -= 1
        }
        var isFound = [false, false, false] //0: 이전 GPS찾음 1:이전과 그 전의 GPS찾음 2: 줌레벨 찾음
        var prevItem: EventData = item
        var isDiscrete = false
        for idx in (nextIdx - back - 1...0).reversed() {
            let item2 = trackingLogs[idx]
            if (item2.eventNum == 3) {
                if (isFound[0]) {
                    if (!isFound[1]) {
                        isFound[1] = true
                        if (!isDiscrete) {
                            angle = bearing(
                                    item2.lat.value!,
                                    item2.lng.value!,
                                    prevItem.lat.value!,
                                    prevItem.lng.value!
                            )
                        }
                        if (isFound[2]) {
                            break;
                        }
                    }
                } else {
                    nextIdx = idx + 1
                    prevItem = item2
                    isFound[0] = true
                }
            } else if (item2.eventNum == 4) {
                if (isFound[0] && !isFound[2]) {
                    isFound[2] = true
                    zoomlevel = item2.trackingSpeed.value!
                    if (isFound[1]) {
                        break
                    }
                }
            } else {
                if (idx == 0 && isPause) {

                    isStop = true
                }
                isDiscrete = true
            }
        }
        isAccuratePoint = true
        if (prevItem.eventNum == 3) {
            let cameraPosition: GMSCameraPosition
            if (isAuto) {

                cameraPosition = GMSCameraPosition.camera(withLatitude: prevItem.latlng.latitude, longitude: prevItem.latlng.longitude, zoom: zoomLevels[zoomlevel],
                        bearing: angle, viewingAngle: 90.0)

            } else {
                cameraPosition = GMSCameraPosition.camera(
                        withLatitude: prevItem.latlng.latitude,
                        longitude: prevItem.latlng.longitude,
                        zoom: mapView.camera.zoom
                )
            }

            mapView.camera = cameraPosition
            lastLoc = prevItem.latlng
            centerMarker.position = lastLoc
        }
        nextTracking()

    }

    func getStartPoint() {
        zoomlevel = 0
        nextIdx = 0
        isDiscrete = false

        for item in trackingLogs {
            nextIdx += 1
            if (item.eventNum == 3) {
                lastLoc = item.latlng
                centerMarker.map = nil
                centerMarker = GMSMarker(position: item.latlng)
                centerMarker.icon = GMSMarker.markerImage(with: UIColor.blue)
                centerMarker.map = mapView
                for idx in nextIdx..<trackingLogs.count {
                    if (trackingLogs[idx].eventNum == 3) {
                        nextIdx = idx
                        let item2 = trackingLogs[idx]
                        angle = bearing(
                                lastLoc.latitude,
                                lastLoc.longitude,
                                item2.lat.value!,
                                item2.lng.value!
                        )
                        break
                    } else if (item.eventNum == 4) {
                        zoomlevel = item.trackingSpeed.value!

                    } else {
                        isDiscrete = true
                    }
                }
                let camera: GMSCameraPosition
                if (isAuto) {

                    camera = GMSCameraPosition.camera(withLatitude: lastLoc.latitude, longitude: lastLoc.longitude, zoom: zoomLevels[zoomlevel],
                            bearing: angle, viewingAngle: 90.0)

                } else {
                    camera = GMSCameraPosition.camera(
                            withLatitude: lastLoc.latitude,
                            longitude: lastLoc.longitude,
                            zoom: mapView.camera.zoom
                    )
                }


                mapView.camera = camera

                break
            } else if (item.eventNum == 4) {
                zoomlevel = item.trackingSpeed.value!

            }
        }

    }

    func bearing(
            _ latitude1: Double,
            _ longitude1: Double,
            _ latitude2: Double,
            _ longitude2: Double
    ) -> Double {
        // 현재 위치 : 위도나 경도는 지구 중심을 기반으로 하는 각도이기 때문에 라디안 각도로 변환한다.
        let Cur_Lat_radian = latitude1 * (Double.pi / 180)
        let Cur_Lon_radian = longitude1 * (Double.pi / 180)


        // 목표 위치 : 위도나 경도는 지구 중심을 기반으로 하는 각도이기 때문에 라디안 각도로 변환한다.
        let Dest_Lat_radian = latitude2 * (Double.pi / 180)
        let Dest_Lon_radian = longitude2 * (Double.pi / 180)

        // radian distance
        var radian_distance = 0.0
        radian_distance = acos(
                sin(Cur_Lat_radian) * sin(Dest_Lat_radian)
                        + cos(Cur_Lat_radian) * cos(Dest_Lat_radian) * cos(Cur_Lon_radian - Dest_Lon_radian)
        )

        // 목적지 이동 방향을 구한다.(현재 좌표에서 다음 좌표로 이동하기 위해서는 방향을 설정해야 한다. 라디안값이다.
        let radian_bearing = acos(
                (sin(Dest_Lat_radian) - sin(Cur_Lat_radian)
                        * cos(radian_distance)) / (cos(Cur_Lat_radian) * sin(
                        radian_distance
                ))
        ) // acos의 인수로 주어지는 x는 360분법의 각도가 아닌 radian(호도)값이다.
        var true_bearing: Double
        if (sin(Dest_Lon_radian - Cur_Lon_radian) < 0) {
            true_bearing = radian_bearing * (180 / Double.pi)
            true_bearing = 360 - true_bearing
        } else {
            true_bearing = radian_bearing * (180 / Double.pi)
        }
        return true_bearing
    }

    func pauseAnimation() {
        stopAnimation()
    }

    func resumeAnimation() {
        var destLoc: CLLocationCoordinate2D? = nil
        for i in nextIdx - 1..<trackingLogs.count {
            if (trackingLogs[i].eventNum == 3) {
                destLoc = trackingLogs[i].latlng
                break;
            }
        }
        if (destLoc != nil) {
            DispatchQueue.main.async { [self] in
                if (isPause) {
                    return
                }
                let orgDist = lastLoc.distance(to: destLoc!)
                let currDist = mapView.camera.target.distance(to: destLoc!)
                var animateTime = 0.0
                if (isDiscrete) {
                    isDiscrete = false
                    animateTime = 1.0

                } else {
                    animateTime = 3.0 / Double(speed)
                }
                var ratio = currDist / orgDist

                if (isAuto && ratio > 0.5) {

                    angle = bearing(
                            lastLoc.latitude,
                            lastLoc.longitude,
                            destLoc!.latitude,
                            destLoc!.longitude
                    )
                    ratio -= 0.5
                    let time = ratio / 0.5 / Double(speed)

                    //CATransaction.begin()
                    // CATransaction.setDisableActions(true)
                    //  CATransaction.setAnimationDuration(time)
                    mapView.animate(to: GMSCameraPosition.camera(withLatitude: mapView.camera.target.latitude, longitude: mapView.camera.target.longitude, zoom: zoomLevels[zoomlevel],
                            bearing: angle, viewingAngle: 90.0))

                    //  CATransaction.commit()

                    usleep(UInt32(time * 1000000) - 500000 / UInt32(speed))
                } else {
                    animateTime = max(Double(animateTime) * currDist / orgDist / 0.5, 1.0)
                }
                // CATransaction.begin()
                //  CATransaction.setDisableActions(true)
                //  CATransaction.setAnimationDuration(animateTime)
                mapView.animate(to: GMSCameraPosition.camera(withLatitude: destLoc!.latitude, longitude: destLoc!.longitude, zoom: zoomLevels[zoomlevel],
                        bearing: angle, viewingAngle: 90.0))
                //   CATransaction.setCompletionBlock({
                //      lastLoc = destLoc
                //       nextTracking()
                //   })
                //   CATransaction.commit()

            }
        }
    }
}
