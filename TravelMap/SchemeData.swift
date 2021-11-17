//
//  SchemeData.swift
//  TravelMap
//
//  Created by 김한빈 on 2021/11/14.
//

import Foundation

class SchemeData {
    let id: Int64
    let userID: Int64
    let nickname: String
    let shareNum: Int
    let trackingName: String
    let salt: [UInt8]?

    init(_ query: String) {
        let splits = query.split(separator: ";")
        var value = [Substring]()
        for split in splits {
            let tmp = split.split(separator: "=", maxSplits: 1)
            value.append(tmp[1])
        }
        id = Int64(value[0])!
        shareNum = Int(value[1])!
        userID = Int64(value[2])!
        nickname = String(value[3]).removingPercentEncoding!
        trackingName = String(value[4]).removingPercentEncoding!
        salt = value.count > 5 ? [UInt8](Data(base64Encoded: String(value[5]))!) : nil

    }
}
