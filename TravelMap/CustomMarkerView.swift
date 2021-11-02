//
//  CustomMarkerView.swift
//  TravelMap
//
//  Created by 김한빈 on 2021/10/28.
//

import UIKit

class CustomMarkerView: UIView {


    @IBOutlet weak var count10000: UILabel!
    @IBOutlet weak var count100: UILabel!
    @IBOutlet weak var count10: UILabel!
    @IBOutlet weak var imageView: UIImageView!

    convenience init(image: UIImage, count: Int) {
        self.init(frame: CGRect.zero)
        imageView.image = image
        var label: UILabel
        if (count == 0) {
            return
        } else if (count < 100) {
            label = count10
        } else if (count < 10000) {
            label = count100
        } else {
            label = count10000
        }

        label.layer.masksToBounds = true
        label.layer.cornerRadius = 15
        label.isHidden = false
        if (count > 99999) {
            label.text = "99999"
        } else {
            label.text = String(count)
        }
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        loadXib()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        loadXib()
    }

    private func loadXib() {
        let identifier = String(describing: type(of: self))
        let nibs = Bundle.main.loadNibNamed(identifier, owner: self, options: nil)

        guard let customView = nibs?.first as? UIView else {
            return
        }
        customView.frame = self.bounds
        self.addSubview(customView)
    }
}
