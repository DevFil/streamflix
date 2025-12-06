import Foundation
import CommonCrypto

/// AES decryption utility for encrypted data
/// Translated from Android's CryptoAES.kt
class CryptoAES {
    
    /// Decrypts AES-encrypted data with CBC mode and PKCS5 padding
    /// - Parameters:
    ///   - encryptedData: Base64-encoded encrypted string
    ///   - key: Encryption key as a string
    /// - Returns: Decrypted string, or empty string on failure
    static func decrypt(encryptedData: String, key: String) -> String {
        do {
            // Decode base64 data
            guard let decodedData = Data(base64Encoded: encryptedData) else {
                print("Failed to decode base64 data")
                return ""
            }
            
            // Extract IV from first 16 bytes
            guard decodedData.count > 16 else {
                print("Data too short to contain IV")
                return ""
            }
            
            let iv = decodedData.prefix(16)
            let ciphertext = decodedData.suffix(from: 16)
            
            // Convert key to data
            guard let keyData = key.data(using: .utf8) else {
                print("Failed to convert key to data")
                return ""
            }
            
            // Perform AES decryption
            let decryptedData = try aesDecrypt(data: ciphertext, key: keyData, iv: iv)
            
            // Convert decrypted data to string
            if let decryptedString = String(data: decryptedData, encoding: .utf8) {
                return decryptedString
            } else {
                print("Failed to convert decrypted data to string")
                return ""
            }
            
        } catch {
            print("Decryption error: \(error)")
            return ""
        }
    }
    
    /// Performs AES decryption using CommonCrypto
    private static func aesDecrypt(data: Data, key: Data, iv: Data) throws -> Data {
        let cryptLength = data.count + kCCBlockSizeAES128
        var cryptData = Data(count: cryptLength)
        
        let keyLength = key.count
        let options = CCOptions(kCCOptionPKCS7Padding)
        
        var numBytesDecrypted: size_t = 0
        
        let cryptStatus = cryptData.withUnsafeMutableBytes { cryptBytes in
            data.withUnsafeBytes { dataBytes in
                iv.withUnsafeBytes { ivBytes in
                    key.withUnsafeBytes { keyBytes in
                        CCCrypt(
                            CCOperation(kCCDecrypt),
                            CCAlgorithm(kCCAlgorithmAES),
                            options,
                            keyBytes.baseAddress, keyLength,
                            ivBytes.baseAddress,
                            dataBytes.baseAddress, data.count,
                            cryptBytes.baseAddress, cryptLength,
                            &numBytesDecrypted
                        )
                    }
                }
            }
        }
        
        if cryptStatus == kCCSuccess {
            cryptData.removeSubrange(numBytesDecrypted..<cryptData.count)
            return cryptData
        } else {
            throw NSError(domain: "CryptoAES", code: Int(cryptStatus), userInfo: [
                NSLocalizedDescriptionKey: "AES decryption failed with status: \(cryptStatus)"
            ])
        }
    }
}
