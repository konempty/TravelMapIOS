//
//  ProgressPopup.swift
//  TravelMap
//
//  Created by 김한빈 on 2021/11/09.
//

import UIKit

class ProgressPopup: UIViewController {

    static var instance: ProgressPopup!
    @IBOutlet weak var indicator: UIActivityIndicatorView!

    override func viewDidLoad() {
        super.viewDidLoad()
        indicator.transform = CGAffineTransform(scaleX: 3, y: 3)
        indicator.startAnimating()

    }


}
