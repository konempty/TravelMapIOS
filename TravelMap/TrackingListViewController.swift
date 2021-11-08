//
//  TrackingListViewController.swift
//  TravelMap
//
//  Created by 김한빈 on 2021/10/07.
//

import UIKit
import RealmSwift
import DropDown

class TrackingListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var backBtn: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    var datas = [TrackingListData]()
    var selectIndex = 0
    

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        datas.count

    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "trackingListTableViewCell", for: indexPath) as! TrackingListTableViewCell

        let data = datas[indexPath.row]
        cell.trackingName.text = data.name
        let dateFormatter = DateFormatter()

        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        cell.trackingTime.text = dateFormatter.string(from: data.startTime) + " ~ " + dateFormatter.string(from: data.endTime)

        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(sender:)))
        tableView.addGestureRecognizer(longPress)

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {


    }


    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.tableFooterView = UIView()
        tableView.contentInset = UIEdgeInsets(top: 0, left: -5, bottom: 0, right: 0)
        tableView.separatorColor = UIColor.lightGray
        tableView.rowHeight = "hello".height(withConstrainedWidth: tableView.frame.width, font: UIFont(name: "BMJUAOTF", size: 19)!) * 4
        // Do any additional setup after loading the view.

        let gesture = UITapGestureRecognizer(target: self, action: #selector(backFun))
        backBtn.isUserInteractionEnabled = true
        backBtn.addGestureRecognizer(gesture)


        loadTrackingData()
    }


    func loadTrackingData() {
        let realm = try! Realm()
        let results = realm.objects(EventData.self).filter("eventNum == 2").sorted(byKeyPath: "trackingNum")
        datas.removeAll()
        for result in results {

            let results2 = realm.objects(EventData.self).filter("trackingNum == \(result.trackingNum)")
            datas.append(TrackingListData(id: result.id, trackingNum: result.trackingNum, name: result.name!, startTime: results2.min(ofProperty: "time")!, endTime: results2.max(ofProperty: "time")!))
        }
        tableView.reloadData()
    }

    @objc func backFun() {
        finish()
    }

    @objc func handleLongPress(sender: UILongPressGestureRecognizer) {
        if sender.state == .began {
            let touchPoint = sender.location(in: tableView)
            if let indexPath = tableView.indexPathForRow(at: touchPoint) {
                selectIndex = indexPath.row
                let data = datas[selectIndex]
                let uvc = self.storyboard?.instantiateViewController(withIdentifier: "TrackingItemMenuDia") as! TrackingItemMenuDialog
                uvc.modalPresentationStyle = .overCurrentContext
                uvc.setData(name: data.name, trackingNum: data.trackingNum)
                present(uvc, animated: true)
            }
        }
    }

    func changeTrackingName() {
        let data = datas[selectIndex]

        let uvc = self.storyboard?.instantiateViewController(withIdentifier: "TrackingNameDialog") as! TrackingNameDialog
        uvc.modalPresentationStyle = .overCurrentContext
        uvc.setData(name: data.name, trackingNum: data.trackingNum, isEdit: true)
        uvc.setOnOk() { [self]name in
            let realm = try! Realm()
            let row = realm.object(ofType: EventData.self, forPrimaryKey: data.id)
            try! realm.write({
                row?.name = name
                loadTrackingData()
            })
        }
        present(uvc, animated: true)

    }

    func showShareDialog() {
        let data = datas[selectIndex]


        let alertController = UIAlertController(title: nil, message: "'\(data.name)'을(를) 다른 사람들에게 공유하시겠습니까?", preferredStyle: .alert)

        let okAction = UIAlertAction(title: "예", style: .default) { [self] (_) -> Void in

            let dialog1 = (ShowDialog("ShareSelectDialog") as! ShareSelectDialog)
            dialog1.setOnOk { [self] in
                let dialog2 = (ShowDialog("ShareProgressDialog") as! ShareProgressDialog)
                dialog2.name = data.name
                dialog2.trackingNum = data.trackingNum
                dialog2.share = dialog1.shareSlectrion
                dialog2.quality = dialog1.qualitySelection
                dialog2.pswd = dialog1.pswd

            }
        }

        let cancelAction = UIAlertAction(title: "아니요", style: .default)

        alertController.addAction(okAction)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
    }

}
