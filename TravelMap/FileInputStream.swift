//
//  FileInputStream.swift
//  TravelMap
//
//  Created by 김한빈 on 2021/11/15.
//

import Foundation
import CryptoSwift

class FileInputStream: InputStream {
    var aesObject: AES!


    init(fileURL: URL, pswd: String, salt: [UInt8]) {
        super.init(url: fileURL)!

        let key = pbkdf2sha256(password: pswd, salt: Data(salt), keyByteCount: 32, rounds: 1000)
        let iv = "9362469649674046"
        let keyDecodes: Array<UInt8> = [UInt8](key!)
        let ivDecodes: Array<UInt8> = Array(iv.utf8)
        aesObject = try! AES(key: keyDecodes, blockMode: CBC(iv: ivDecodes), padding: .pkcs7)
        open()
    }

    override func read(_ buffer: UnsafeMutablePointer<UInt8>, maxLength len: Int) -> Int {
        let tmp_buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: len)
        let n = super.read(tmp_buffer, maxLength: len)

        let bufferPointer = UnsafeMutableBufferPointer(start: tmp_buffer, count: n)
        let array = Array(bufferPointer)
        let decode = try! aesObject.decrypt(array)
        buffer.assign(from: decode, count: decode.count)
        return decode.count
    }

    func pbkdf2(hash: CCPBKDFAlgorithm, password: String, salt: Data, keyByteCount: Int, rounds: Int) -> Data? {
        let passwordData = password.data(using: .utf8)!
        var derivedKeyData = Data(repeating: 0, count: keyByteCount)

        let localDerivedKeyData = derivedKeyData

        let derivationStatus = derivedKeyData.withUnsafeMutableBytes { derivedKeyBytes in
            salt.withUnsafeBytes { saltBytes in

                CCKeyDerivationPBKDF(
                        CCPBKDFAlgorithm(kCCPBKDF2),
                        password, passwordData.count,
                        saltBytes, salt.count,
                        hash,
                        UInt32(rounds),
                        derivedKeyBytes, localDerivedKeyData.count)
            }
        }
        if (derivationStatus != kCCSuccess) {
            print("Error: \(derivationStatus)")
            return nil;
        }

        return derivedKeyData
    }

    // Converts data to a hexadecimal string
    private func toHex(_ data: Data) -> String {
        return data.map {
            String(format: "%02x", $0)
        }.joined()
    }

    func pbkdf2sha256(password: String, salt: Data, keyByteCount: Int, rounds: Int) -> Data? {

        return pbkdf2(hash: CCPBKDFAlgorithm(kCCPRFHmacAlgSHA256), password: password, salt: salt, keyByteCount: keyByteCount, rounds: rounds)
    }


}
