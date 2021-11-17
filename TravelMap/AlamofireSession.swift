//
//  AlamofireSession.swift
//  TravelMap
//
//  Created by 김한빈 on 2021/11/10.
//

import Foundation
import Alamofire

class AlamofireSession {
    static var session: Session? = nil
    static var ServerURL = "https://119.69.202.23/"

    static var manager: Alamofire.ServerTrustManager {
        get {
            let defaultManager: ServerTrustManager = {
                let serverTrustPolicies: [String: ServerTrustEvaluating] = [
                    "119.69.202.23": DisabledTrustEvaluator(),

                    "119.69.202.23:443": DisabledTrustEvaluator()
                ]


                return Alamofire.ServerTrustManager(evaluators: serverTrustPolicies)
            }()

            return defaultManager
        }
    }

    @discardableResult static func sendRestRequest(url: String, params: Parameters?, isPost: Bool = true, response: @escaping (AFDataResponse<Data?>) -> Void) -> Request {
        let headers: HTTPHeaders = ["Accept": "application/json; charset=utf-8"]
        if (session == nil) {
            session = Session(serverTrustManager: manager)
        }
        return session!.request(ServerURL + url, method: isPost ? .post : .get, parameters: params, headers: headers).response(completionHandler: response)
    }

    @discardableResult static func uploadFile(url: String, multipartFormData: MultipartFormData, isPost: Bool = true, response: @escaping (AFDataResponse<Data?>) -> Void) -> Request {
        let headers: HTTPHeaders = [
            .contentType("multipart/form-data; charset=utf-8")
        ]
        if (session == nil) {
            session = Session(serverTrustManager: manager)
        }
        return session!.upload(multipartFormData: multipartFormData, to: ServerURL + url, method: isPost ? .post : .get, headers: headers).response(completionHandler: response)
    }

    @discardableResult static func downloadFile(url: String, params: Parameters?, isPost: Bool = true, response: @escaping (AFDownloadResponse<URL?>) -> Void) -> Request {
        let headers: HTTPHeaders = []
        if (session == nil) {
            session = Session(serverTrustManager: manager)
        }
        return session!.download(ServerURL + url, method: isPost ? .post : .get, parameters: params, headers: headers, to: nil).response(completionHandler: response)
    }
}
