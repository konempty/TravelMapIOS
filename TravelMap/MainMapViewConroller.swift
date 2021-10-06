//
//  MainMapViewConroller.swift
//  TravelMap
//
//  Created by 김한빈 on 2021/04/18.
//

import UIKit
import MapKit
import Photos

class MainMapViewConroller: UIViewController, MKMapViewDelegate {
    static var instance: MainMapViewConroller?
    @IBOutlet weak var mapView: MKMapView!

    override func viewDidLoad() {
        mapView.showsCompass = false
        mapView.delegate = self
        MainMapViewConroller.instance = self
    }

    func refresh() {
        var annotaions: [MKAnnotation] = []
        let s = DispatchSemaphore(value: 10)
        for i in 0..<MainViewController.allPhotos!.count {
            let asset = MainViewController.allPhotos![i]
            let loc = asset.location?.coordinate

            if (loc != nil) {
                s.wait()
                DispatchQueue.main.startCoroutine {
                    let imageManager = PHCachingImageManager()
                    imageManager.requestImage(for: asset, targetSize: CGSize(width: 30, height: 30), contentMode: .aspectFill, options: nil, resultHandler: { image, _ in


                        // The cell may have been recycled by the time this handler gets called;


                        // set the cell's thumbnail image only if it's still showing the same asset.


                        let annotation = Locations(image!)
                        annotation.coordinate = loc!
                        let annotation2 = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "locations")
                        annotaions.append(annotation2.annotation!)

                        s.signal()

                    })

                }

            }
        }
        for _ in 0...9 {
            s.wait()
        }
        DispatchQueue.main.startCoroutine {
            self.mapView.showAnnotations(annotaions, animated: false)
        }
        for _ in 0...9 {
            s.signal()
        }

    }


    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {

        if let annotation = annotation as? Locations {
            var view = mapView.dequeueReusableAnnotationView(withIdentifier: annotation.identifier)
            if view == nil {
                view = MKAnnotationView(annotation: annotation, reuseIdentifier: annotation.identifier)
            }

            view!.image = annotation.image
            view!.isEnabled = true
            view!.canShowCallout = true
            view!.clusteringIdentifier = annotation.identifier
            return view
        } else if let cluster = annotation as? MKClusterAnnotation {

            var view = mapView.dequeueReusableAnnotationView(withIdentifier: "cluster")
            if view == nil {
                view = MKAnnotationView(annotation: cluster, reuseIdentifier: "cluster")
            }
            view!.image = (cluster.memberAnnotations[0] as! Locations).image
            view!.isEnabled = true
            return view
        }
        return nil
    }
}

class Locations: MKPointAnnotation {
    // required coordinate, title, and the reuse identifier for this annotation
    var identifier = "locations"
    var image: UIImage

    init(_ image: UIImage) {
        self.image = image
    }
}
