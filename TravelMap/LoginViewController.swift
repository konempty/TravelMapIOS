//
//  LoginViewController.swift
//  TravelMap
//
//  Created by 김한빈 on 2021/11/09.
//

import UIKit
import Firebase
import GoogleSignIn
import FBSDKLoginKit
import CryptoKit

class LoginViewController: UIViewController {


    @IBOutlet weak var googleLoginBtn: GradientButton!
    @IBOutlet weak var appleLoginBtn: GradientButton!
    @IBOutlet weak var facebookLoginBtn: GradientButton!
    @IBOutlet weak var backBtn: WhiteImageView!
    @IBOutlet weak var twitterLoginBtn: GradientButton!
    let provider = OAuthProvider(providerID: "twitter.com")


    override func viewDidLoad() {
        super.viewDidLoad()
        var gesture = UITapGestureRecognizer(target: self, action: #selector(googleLoginFun))
        googleLoginBtn.isUserInteractionEnabled = true
        googleLoginBtn.addGestureRecognizer(gesture)


        gesture = UITapGestureRecognizer(target: self, action: #selector(facebookLoginFun))
        facebookLoginBtn.isUserInteractionEnabled = true
        facebookLoginBtn.addGestureRecognizer(gesture)

        gesture = UITapGestureRecognizer(target: self, action: #selector(backFun))
        backBtn.isUserInteractionEnabled = true
        backBtn.addGestureRecognizer(gesture)

        /*gesture = UITapGestureRecognizer(target: self, action: #selector(appleLoginFun))
        appleLoginBtn.isUserInteractionEnabled = true
        appleLoginBtn.addGestureRecognizer(gesture)*/

        gesture = UITapGestureRecognizer(target: self, action: #selector(twitterLoginFun))
        twitterLoginBtn.isUserInteractionEnabled = true
        twitterLoginBtn.addGestureRecognizer(gesture)


    }


    @objc func backFun() {
        finish()
        (presentingViewController as! TrackingListViewController).setLoginResult(false)
    }

    @objc func googleLoginFun() {
        showProgress()
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            return
        }

        // Create Google Sign In configuration object.
        let config = GIDConfiguration(clientID: clientID)

        // Start the sign in flow!
        GIDSignIn.sharedInstance.signIn(with: config, presenting: self) { [unowned self] user, error in

            if let error = error {
                dismissProgress()
                // ...
                return
            }

            guard
                    let authentication = user?.authentication,
                    let idToken = authentication.idToken
                    else {
                dismissProgress()
                return
            }

            let credential = GoogleAuthProvider.credential(withIDToken: idToken,
                    accessToken: authentication.accessToken)
            loginProcess(credential)
            //print(idToken)
        }
    }

    @objc func facebookLoginFun() {
        showProgress()
        let loginManager = LoginManager()
        loginManager.logIn(permissions: [], from: self) { [self] (result, error) in

            // 4
            // Check for error

            guard error == nil else {
                // Error occurred
                print(error!.localizedDescription)
                dismissProgress()
                return
            }

            // 5
            // Check for cancel
            guard let result = result, !result.isCancelled else {
                print("User cancelled login")
                dismissProgress()
                return
            }

            let credential = FacebookAuthProvider
                    .credential(withAccessToken: AccessToken.current!.tokenString)
            loginProcess(credential)
        }
    }

    @objc func appleLoginFun() {

    }

    @objc func twitterLoginFun() {
        showProgress()

        provider.getCredentialWith(nil) { credential, error in

            if error != nil {
                // Handle error.

                self.dismissProgress()
            }
            if credential != nil {
                self.loginProcess(credential!)

            }
        }
    }

    private func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        let charset: Array<Character> =
                Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = ""
        var remainingLength = length

        while remainingLength > 0 {
            let randoms: [UInt8] = (0..<16).map { _ in
                var random: UInt8 = 0
                let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
                if errorCode != errSecSuccess {
                    fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
                }
                return random
            }

            randoms.forEach { random in
                if remainingLength == 0 {
                    return
                }

                if random < charset.count {
                    result.append(charset[Int(random)])
                    remainingLength -= 1
                }
            }
        }

        return result
    }

    fileprivate var currentNonce: String?

    /*@available(iOS 13, *)
    func startSignInWithAppleFlow() {
      let nonce = randomNonceString()
      currentNonce = nonce
      let appleIDProvider = ASAuthorizationAppleIDProvider()
      let request = appleIDProvider.createRequest()
      request.requestedScopes = [.fullName, .email]
      request.nonce = sha256(nonce)

      let authorizationController = ASAuthorizationController(authorizationRequests: [request])
      authorizationController.delegate = self
      authorizationController.presentationContextProvider = self
      authorizationController.performRequests()
    }

    @available(iOS 13, *)
    private func sha256(_ input: String) -> String {
      let inputData = Data(input.utf8)
      let hashedData = SHA256.hash(data: inputData)
      let hashString = hashedData.compactMap {
        return String(format: "%02x", $0)
      }.joined()

      return hashString
    }*/

    func loginProcess(_ credential: AuthCredential) {
        Auth.auth().signIn(with: credential) { [self] (authResult, error) in

            dismissProgress()

            if let error = error {
                view.makeToast("문제가 발생했습니다. 잠시후 다시 시도해주세요.")
                return
            }
            finish()
            (presentingViewController as! LoginResultProtocol).setLoginResult(true)
        }
    }

}
