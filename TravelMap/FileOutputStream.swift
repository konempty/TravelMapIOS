//
//  FileOutputStream.swift
//  TravelMap
//
//  Created by 김한빈 on 2021/11/06.
//

import Foundation


class FileOutputStream {
    let Stream: OutputStream

    init(url: URL) {
        Stream = OutputStream(url: url, append: false)!
        Stream.open()
    }

    @discardableResult func write(_ data: [UInt8], encoding: String.Encoding = .utf8, allowLossyConversion: Bool = false) throws -> Int {

        let data = Data(data)
        return data.withUnsafeBytes { (bytes: UnsafePointer<UInt8>) -> Int in
            var pointer = bytes
            var bytesRemaining = data.count
            var totalBytesWritten = 0

            while bytesRemaining > 0 {
                let bytesWritten = Stream.write(pointer, maxLength: bytesRemaining)
                if bytesWritten < 0 {
                    return -1
                }

                bytesRemaining -= bytesWritten
                pointer += bytesWritten
                totalBytesWritten += bytesWritten
            }

            return totalBytesWritten
        }

    }

    func close() {
        Stream.close()
    }

}
