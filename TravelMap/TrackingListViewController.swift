//
//  TrackingListViewController.swift
//  TravelMap
//
//  Created by 김한빈 on 2021/10/07.
//

import UIKit

class TrackingListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var backBtn: UIImageView!
    @IBOutlet weak var tableView: UITableView!

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        10
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "trackingListTableViewCell", for: indexPath) as! TrackingListTableViewCell

        cell.trackingName.text = "(\(indexPath))"

        cell.trackingTime.text = "(1-1)"

        return cell
    }


    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.tableFooterView = UIView()
        tableView.contentInset = UIEdgeInsets(top: 0, left: -5, bottom: 0, right: 0)
        tableView.separatorColor = UIColor.lightGray
        // Do any additional setup after loading the view.

        let gesture = UITapGestureRecognizer(target: self, action: #selector(backFun))
        backBtn.isUserInteractionEnabled = true
        backBtn.addGestureRecognizer(gesture)
    }

    @objc func backFun() {
        finish()
    }


}
