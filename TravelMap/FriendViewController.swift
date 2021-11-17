//
//  FriendViewController.swift
//  TravelMap
//
//  Created by 김한빈 on 2021/11/13.
//

import UIKit
import SwiftyJSON

class FriendViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {


    @IBOutlet weak var backBtn: WhiteImageView!
    @IBOutlet weak var toggleBtn: GradientButton!
    @IBOutlet weak var tableview: UITableView!

    static var instance: FriendViewController!

    var isFriendList = true
    var list = [FriendItem]()

    override func viewDidLoad() {
        super.viewDidLoad()
        let nibName = UINib(nibName: "FriendTableViewCell", bundle: nil)

        tableview.register(nibName, forCellReuseIdentifier: "FriendTableViewCell")
        FriendViewController.instance = self

        var gesture = UITapGestureRecognizer(target: self, action: #selector(backFun))
        backBtn.isUserInteractionEnabled = true
        backBtn.addGestureRecognizer(gesture)

        tableview.tableFooterView = UIView()
        refreshData()
    }

    func refreshData() {
        showProgress()
        AlamofireSession.sendRestRequest(url: isFriendList ? "getFriendList.do" : "getFriendRequestedList.do", params: nil, isPost: false) { [self] dataResponse in
            dismissProgress()
            switch dataResponse.result {
            case .success(let value):
                let json = JSON(value)
                if json["success"].boolValue {
                    list.removeAll()
                    let arr = json["list"].arrayValue
                    for item in arr {
                        list.append(FriendItem(id: item["id"].int64Value, nickname: item["nickname"].stringValue, isPartially: isFriendList ? item["isPartially"].boolValue : true))
                    }
                    tableview.reloadData()

                } else {
                    MainViewController.instance.view.makeToast("문제가 발생했습니다. 잠시후 다시 시도해주세요.")
                    finish()
                }

                break;
            default:
                MainViewController.instance.view.makeToast("문제가 발생했습니다. 잠시후 다시 시도해주세요.")
                finish()
                break;
            }
        }
    }

    @objc func backFun() {
        finish()
    }

    @IBAction func addFriendFun() {
        ShowDialog("AddFriendDialog")
    }

    @IBAction func toggleFun() {
        isFriendList = !isFriendList
        toggleBtn.setTitle(isFriendList ? "받은 친구신청" : "친구 리스트", for: .normal)
        refreshData()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        list.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FriendTableViewCell", for: indexPath) as! FriendTableViewCell

        cell.setData(data: list[indexPath.row], isFriendList: isFriendList)

        return cell
    }

}
