//
//  FriendItem.swift
//  TravelMap
//
//  Created by 김한빈 on 2021/11/13.
//

import UIKit

class FriendItem {
    let id: Int64
    let nickname: String
    let isPartially: Bool

    init(id: Int64, nickname: String, isPartially: Bool) {
        self.id = id
        self.nickname = nickname
        self.isPartially = isPartially
    }
}
