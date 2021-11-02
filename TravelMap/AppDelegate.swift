//
//  AppDelegate.swift
//  TravelMap
//
//  Created by 김한빈 on 2021/04/18.
//

import UIKit
import Alamofire
import SwiftyJSON
import Photos
import GoogleMaps
import DropDown

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        GMSServices.provideAPIKey("AIzaSyBoHTmxjR0r1V567C1-Uydp4w-MkNb1sGE")
        DropDown.startListeningToKeyboard()
        sleep(2)
        return true
    }


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

    func applicationDidBecomeActive(_ application: UIApplication) {
        if (!PhotoService.isRunning) {
            PhotoService()
        }
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
    func applyGradient(_ isRound: Bool = false) {
        let colours = [UIColor(named: "dark_sky_blue_two")!, UIColor(named: "purpleish_blue")!]

        removeGradient()
        let gradient: CAGradientLayer = CAGradientLayer()

        gradient.frame = self.bounds
        gradient.colors = colours.map {
            $0.cgColor
        }

        gradient.startPoint = CGPoint(x: 0, y: 0.5)
        gradient.endPoint = CGPoint(x: 1, y: 0.5)
        if (isRound) {
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

    func toggle(_ selected: Bool) {
        if (selected) {
            applyGradient()
        } else {

            removeGradient()
        }
    }
}

class ToggleRoundButton: UIButton {
    open override func layoutSubviews() {
        super.layoutSubviews()
    }

    func toggle(_ selected: Bool) {
        if (selected) {
            applyGradient(true)
        } else {

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

extension NSObject {
    func requestIamge(with asset: PHAsset?, thumbnailSize: CGSize, completion: @escaping (UIImage?) -> Void) {

        guard let asset = asset else {

            completion(nil)

            return

        }

        let representedAssetIdentifier = asset.localIdentifier

        let imageManager = PHCachingImageManager()
        let option = PHImageRequestOptions()
        option.isSynchronous = false
        option.isNetworkAccessAllowed = true
        option.deliveryMode = .highQualityFormat
        imageManager.requestImage(for: asset, targetSize: thumbnailSize, contentMode: .aspectFill, options: option, resultHandler: { image, _ in

            // UIKit may have recycled this cell by the handler's activation time.

            // Set the cell's thumbnail image only if it's still showing the same asset.

            if representedAssetIdentifier == asset.localIdentifier {

                completion(image)

            }

        })

    }


}

extension UIColor {
    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")

        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }

    convenience init(rgb: Int) {
        self.init(
                red: (rgb >> 16) & 0xFF,
                green: (rgb >> 8) & 0xFF,
                blue: rgb & 0xFF
        )
    }
}

fileprivate func <<T: Comparable>(lhs: T?, rhs: T?) -> Bool {
    switch (lhs, rhs) {
    case let (l?, r?):
        return l < r
    case (nil, _?):
        return true
    default:
        return false
    }
}


extension UIImage {

    public class func gifImageWithData(_ data: Data) -> UIImage? {
        guard let source = CGImageSourceCreateWithData(data as CFData, nil) else {
            print("image doesn't exist")
            return nil
        }

        return UIImage.animatedImageWithSource(source)
    }

    public class func gifImageWithURL(_ gifUrl: String) -> UIImage? {
        guard let bundleURL: URL? = URL(string: gifUrl)
                else {
            print("image named \"\(gifUrl)\" doesn't exist")
            return nil
        }
        guard let imageData = try? Data(contentsOf: bundleURL!) else {
            print("image named \"\(gifUrl)\" into NSData")
            return nil
        }

        return gifImageWithData(imageData)
    }

    public class func gifImageWithName(_ name: String) -> UIImage? {
        guard let bundleURL = Bundle.main
                .url(forResource: name, withExtension: "gif") else {
            print("SwiftGif: This image named \"\(name)\" does not exist")
            return nil
        }
        guard let imageData = try? Data(contentsOf: bundleURL) else {
            print("SwiftGif: Cannot turn image named \"\(name)\" into NSData")
            return nil
        }

        return gifImageWithData(imageData)
    }

    class func delayForImageAtIndex(_ index: Int, source: CGImageSource!) -> Double {
        var delay = 0.1

        let cfProperties = CGImageSourceCopyPropertiesAtIndex(source, index, nil)
        let gifProperties: CFDictionary = unsafeBitCast(
                CFDictionaryGetValue(cfProperties,
                        Unmanaged.passUnretained(kCGImagePropertyGIFDictionary).toOpaque()),
                to: CFDictionary.self)

        var delayObject: AnyObject = unsafeBitCast(
                CFDictionaryGetValue(gifProperties,
                        Unmanaged.passUnretained(kCGImagePropertyGIFUnclampedDelayTime).toOpaque()),
                to: AnyObject.self)
        if delayObject.doubleValue == 0 {
            delayObject = unsafeBitCast(CFDictionaryGetValue(gifProperties,
                    Unmanaged.passUnretained(kCGImagePropertyGIFDelayTime).toOpaque()), to: AnyObject.self)
        }

        delay = delayObject as! Double

        if delay < 0.1 {
            delay = 0.1
        }

        return delay
    }

    class func gcdForPair(_ a: Int?, _ b: Int?) -> Int {
        var a = a
        var b = b
        if b == nil || a == nil {
            if b != nil {
                return b!
            } else if a != nil {
                return a!
            } else {
                return 0
            }
        }

        if a < b {
            let c = a
            a = b
            b = c
        }

        var rest: Int
        while true {
            rest = a! % b!

            if rest == 0 {
                return b!
            } else {
                a = b
                b = rest
            }
        }
    }

    class func gcdForArray(_ array: Array<Int>) -> Int {
        if array.isEmpty {
            return 1
        }

        var gcd = array[0]

        for val in array {
            gcd = UIImage.gcdForPair(val, gcd)
        }

        return gcd
    }

    class func animatedImageWithSource(_ source: CGImageSource) -> UIImage? {
        let count = CGImageSourceGetCount(source)
        var images = [CGImage]()
        var delays = [Int]()

        for i in 0..<count {
            if let image = CGImageSourceCreateImageAtIndex(source, i, nil) {
                images.append(image)
            }

            let delaySeconds = UIImage.delayForImageAtIndex(Int(i),
                    source: source)
            delays.append(Int(delaySeconds * 1000.0)) // Seconds to ms
        }

        let duration: Int = {
            var sum = 0

            for val: Int in delays {
                sum += val
            }

            return sum
        }()

        let gcd = gcdForArray(delays)
        var frames = [UIImage]()

        var frame: UIImage
        var frameCount: Int
        for i in 0..<count {
            frame = UIImage(cgImage: images[Int(i)])
            frameCount = Int(delays[Int(i)] / gcd)

            for _ in 0..<frameCount {
                frames.append(frame)
            }
        }

        let animation = UIImage.animatedImage(with: frames,
                duration: Double(duration) / 1000.0)

        return animation
    }
}

extension PHAsset {

    func getURL(completionHandler: @escaping ((_ responseURL: URL?) -> Void)) {
        if self.mediaType == .image {
            let options: PHContentEditingInputRequestOptions = PHContentEditingInputRequestOptions()
            options.canHandleAdjustmentData = { (adjustmeta: PHAdjustmentData) -> Bool in
                return true
            }
            self.requestContentEditingInput(with: options, completionHandler: { (contentEditingInput: PHContentEditingInput?, info: [AnyHashable: Any]) -> Void in
                completionHandler(contentEditingInput!.fullSizeImageURL as URL?)
            })
        } else if self.mediaType == .video {
            let options: PHVideoRequestOptions = PHVideoRequestOptions()
            options.version = .original
            PHImageManager.default().requestAVAsset(forVideo: self, options: options, resultHandler: { (asset: AVAsset?, audioMix: AVAudioMix?, info: [AnyHashable: Any]?) -> Void in
                if let urlAsset = asset as? AVURLAsset {
                    let localVideoUrl: URL = urlAsset.url as URL
                    completionHandler(localVideoUrl)
                } else {
                    completionHandler(nil)
                }
            })
        }
    }
}

