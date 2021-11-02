//
//  GoogleMapViewController.swift
//  TravelMap
//
//  Created by 김한빈 on 2021/10/28.
//

import UIKit
import GoogleMaps
import GoogleMapsUtils

class GoogleMapViewController: UIViewController, GMSMapViewDelegate, GMUClusterRendererDelegate, GMUClusterManagerDelegate {

    @IBOutlet weak var coverView: UIView!
    static var clusterList = [PhotoData]()

    class MyItem: NSObject, GMUClusterItem {
        var position: CLLocationCoordinate2D

        let item: PhotoData
        let image: UIImage

        init(position: CLLocationCoordinate2D, image: UIImage, item: PhotoData) {
            self.position = position
            self.image = image
            self.item = item
        }

    }

    static var instance: GoogleMapViewController!
    var mapView: GMSMapView!
    var clusterManager: GMUClusterManager!

    override func viewDidLoad() {
        super.viewDidLoad()
        let camera = GMSCameraPosition.camera(withLatitude: 0, longitude: 0, zoom: 0)
        mapView = GMSMapView.map(withFrame: self.view.frame, camera: camera)
        self.view.addSubview(mapView)
        self.view.sendSubviewToBack(mapView)

        GoogleMapViewController.instance = self

        let iconGenerator = GMUDefaultClusterIconGenerator()
        let algorithm = GMUNonHierarchicalDistanceBasedAlgorithm()
        let renderer = GMUDefaultClusterRenderer(mapView: mapView, clusterIconGenerator: iconGenerator)
        renderer.delegate = self
        renderer.minimumClusterSize = 2
        clusterManager = GMUClusterManager(map: mapView, algorithm: algorithm, renderer: renderer)

        // Register self to listen to GMSMapViewDelegate events.
        clusterManager.setDelegate(self, mapDelegate: self)

    }

    func refresh() {
        clusterManager.clearItems()

        let s = DispatchSemaphore(value: 10)
        DispatchQueue.global().startCoroutine {
            for i in 0..<PhotoService.imageList.count {
                let asset = PhotoService.imageList[i]

                if (asset.isLoc!) {
                    s.wait()
                    DispatchQueue.global().startCoroutine {

                        self.requestIamge(with: asset.asset, thumbnailSize: CGSize(width: 100, height: 100)) { [self] image in
                            if (image != nil) {
                                let location = CLLocationCoordinate2D(latitude: asset.lat.value!, longitude: asset.lng.value!)
                                let marker = MyItem(position: location, image: image!, item: asset)


                                clusterManager.add(marker)
                                s.signal()

                            }
                        }

                    }

                }
            }
            for _ in 0...9 {
                s.wait()
            }
            DispatchQueue.main.startCoroutine { [self] in

                clusterManager.cluster()
                coverView.isHidden = true
            }
            for _ in 0...9 {
                s.signal()
            }
        }
    }

    func renderer(_ renderer: GMUClusterRenderer, willRenderMarker marker: GMSMarker) {
        var icon: UIImage? = nil
        var count = 0
        if let cluster = (marker.userData as? GMUCluster) {
            let items = (cluster.items as! [MyItem]).sorted() { i1, i2 in
                i1.item.modifyTime < i2.item.modifyTime
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
        GoogleMapViewController.clusterList.removeAll()
        let items = (cluster.items as! [MyItem]).sorted() { i1, i2 in
            i1.item.modifyTime > i2.item.modifyTime
        }
        for it in items {
            GoogleMapViewController.clusterList.append(it.item)
        }
        ImageListViewController.imageList = GoogleMapViewController.clusterList
        ShowViewController("ImageListVC")
        return true
    }

    func clusterManager(_ clusterManager: GMUClusterManager, didTap clusterItem: GMUClusterItem) -> Bool {
        GoogleMapViewController.clusterList.removeAll()
        GoogleMapViewController.clusterList.append((clusterItem as! MyItem).item)

        ImageListViewController.imageList = GoogleMapViewController.clusterList
        ShowViewController("ImageListVC")
        return true
    }

}
