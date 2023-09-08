//
//  AES.swift
//  CosRent
//
//  Created by 刘思源 on 2023/8/22.
//

import Foundation
import CommonCrypto

private let defaultKey = "Uc1gU2FsdGVkX19LW0ZSbvKUJT6TnTfI"

enum AESError: Error {
    case keySizeError
    case keyDataError
}

public struct AES256 {
    private let key: Data

    public init?(key: String) throws {
        guard key.count == kCCKeySizeAES256 else {
            throw AESError.keySizeError
        }
        guard let keyData = key.data(using: .utf8) else {
            throw AESError.keyDataError
        }
        self.key = keyData
    }

    public func encrypt(messageData: Data?) -> Data? {
        guard let messageData else { return nil}
        return crypt(data: messageData, option: CCOperation(kCCEncrypt))
    }

    public func decrypt(encryptedData: Data?) -> Data? {
        return crypt(data: encryptedData, option: CCOperation(kCCDecrypt))
    }

    private func crypt(data: Data?, option: CCOperation) -> Data? {
        guard let data = data else { return nil }
        var outputBuffer = [UInt8](repeating: 0, count: data.count + kCCBlockSizeAES128)
        var numBytesEncrypted = 0
        let status = CCCrypt(
            option,
            CCAlgorithm(kCCAlgorithmAES),
            CCOptions(kCCOptionPKCS7Padding),
            Array(key),
            kCCKeySizeAES256,
            nil,
            Array(data),
            data.count,
            &outputBuffer, outputBuffer.count, &numBytesEncrypted
        )
        guard status == kCCSuccess else { return nil }
        let outputBytes = outputBuffer.prefix(numBytesEncrypted)
        return Data(outputBytes)
    }
}


extension String{
    func aes256Encode(withKey key: String = defaultKey) -> String{
        let data = self.data(using: .utf8)
        if let encryptedData = try? AES256(key: key)?.encrypt(messageData: data){
            return encryptedData.base64EncodedString()
        }
        return ""
    }
    
    func aes256decode(withKey key: String = defaultKey) -> String{
        let data = Data(base64Encoded: self)
        if let decryptedData = try? AES256(key: key)?.decrypt(encryptedData: data) {
            return String(data: decryptedData, encoding: .utf8)!
        }
        return ""
    }
}
