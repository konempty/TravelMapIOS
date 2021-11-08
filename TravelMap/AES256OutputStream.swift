//
//  AES256Util.swift
//  TravelMap
//
//  Created by 김한빈 on 2021/11/06.
//

import Foundation
import CryptoSwift

//라이브러리 : https://github.com/krzyzanowskim/CryptoSwift
//pod 'CryptoSwift', '~> 1.3.8'
class AES256OutputStream: FileOutputStream {
    var aesObject: AES!

    init(fileURL: URL, pswd: String, salt: [UInt8]) {
        super.init(url: fileURL)

        let key = pbkdf2sha256(password: pswd, salt: Data(salt), keyByteCount: 32, rounds: 1000)
        let iv = "9362469649674046"
        let keyDecodes: Array<UInt8> = [UInt8](key!)
        let ivDecodes: Array<UInt8> = Array(iv.utf8)
        aesObject = try! AES(key: keyDecodes, blockMode: CBC(iv: ivDecodes), padding: .pkcs7)
    }

    func encrypt(_ data: Array<UInt8>) -> [UInt8] {
        guard !data.isEmpty else {
            return []
        }
        return try! aesObject.encrypt(data)
    }

    override func write(_ data: [UInt8], encoding: String.Encoding = .utf8, allowLossyConversion: Bool = false) -> Int {
        return super.write(encrypt(data), encoding: encoding, allowLossyConversion: allowLossyConversion)
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

    /*func decrypt(encoded: String) -> String {
        let datas = Data(base64Encoded: encoded)
 
        guard datas != nil else {
            return ""
        }
 
        let bytes = datas!.bytes
        let decode = aesObject.decrypt(bytes)
 
        return String(bytes: decode, encoding: .utf8) ?? ""
    }*/


}
