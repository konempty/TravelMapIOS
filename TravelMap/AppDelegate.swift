//
//  AppDelegate.swift
//  TravelMap
//
//  Created by 김한빈 on 2021/04/18.
//

import UIKit
import Alamofire
import SwiftyJSON

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        return true
    }

    // MARK: UISceneSession Lifecycle

    @available(iOS 13.0, *)
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    @available(iOS 13.0, *)
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}


extension String {
    func height(withConstrainedWidth width: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)
    
        return ceil(boundingBox.height)
    }
}
extension UIView {
    func applyGradient(_ isRound:Bool = false) {
        let colours = [UIColor(named: "dark_sky_blue_two")!, UIColor(named: "purpleish_blue")!]

        removeGradient()
        let gradient: CAGradientLayer = CAGradientLayer()

        gradient.frame = self.bounds
        gradient.colors = colours.map {
            $0.cgColor
        }

        gradient.startPoint = CGPoint(x: 0, y: 0.5)
        gradient.endPoint = CGPoint(x: 1, y: 0.5)
        if(isRound){
        gradient.cornerRadius = 10
        }
        self.layer.insertSublayer(gradient, at: 0)
    }


    func removeGradient() {
        if layer.sublayers != nil && layer.sublayers!.count > 1 {
            layer.sublayers![0].removeFromSuperlayer()
        }
    }
}

class GradientButton: UIButton {

    open override func layoutSubviews() {
        super.layoutSubviews()
        applyGradient(true)
    }
}

class ToggleButton: UIButton {
    open override func layoutSubviews() {
        super.layoutSubviews()
    }
    func toggle(_ selected:Bool){
        if(selected){
        applyGradient()
        } else{
            
            removeGradient()
        }
    }
}

class BorderLabel: UILabel {
    open override func layoutSubviews() {
        super.layoutSubviews()
        layer.borderColor = UIColor(named: "dusk_light")?.cgColor
        layer.borderWidth = 2.0
    }
}

class BorderTextField: UITextField {


    open override func layoutSubviews() {
        super.layoutSubviews()
        layer.borderColor = UIColor(named: "dusk_light")?.cgColor
        layer.borderWidth = 2.0
    }
}
extension UIViewController {
    func finish(_ b: Bool = true) {

        self.presentingViewController?.dismiss(animated: b, completion: nil)
    }

    func ShowViewController(_ id: String) {
        guard let uvc = self.storyboard?.instantiateViewController(withIdentifier: id) else {
            return
        }
        uvc.modalTransitionStyle = UIModalTransitionStyle.coverVertical
        present(uvc, animated: true)
    }

    func ShowDialog(_ id: String) {
        guard let uvc = self.storyboard?.instantiateViewController(withIdentifier: id) else {
            return
        }
        uvc.modalPresentationStyle = .overCurrentContext
        present(uvc, animated: true)
    }

    func sendRestRequest(url: String, params: Parameters?, isPost: Bool = true, response: @escaping (AFDataResponse<Any>) -> Void) {

        let headers = HTTPHeaders()
       //headers.add(name: Content-type, value: "application/json")
        

        let method = isPost ? HTTPMethod.post : HTTPMethod.get
        AF.request("https://bmco.xyz/api/" + url, method: method, parameters: params, encoding: JSONEncoding.default, headers: headers).responseJSON(completionHandler: response)
    }

}
