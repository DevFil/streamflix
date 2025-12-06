import Foundation

/// String response converter for network responses
/// Translated from Android's StringConverter.kt
/// This provides similar functionality to Retrofit's Converter for converting HTTP responses to strings

protocol ResponseConverter {
    associatedtype Output
    func convert(data: Data) throws -> Output
}

/// Converts Data to String using UTF-8 encoding
class StringConverter: ResponseConverter {
    typealias Output = String
    
    func convert(data: Data) throws -> String {
        guard let string = String(data: data, encoding: .utf8) else {
            throw ConversionError.invalidEncoding
        }
        return string
    }
}

/// Factory for creating string converters
class StringConverterFactory {
    
    static func create() -> StringConverterFactory {
        return StringConverterFactory()
    }
    
    /// Returns a converter for the specified type
    func converter<T>(for type: T.Type) -> (any ResponseConverter)? {
        if type == String.self {
            return StringConverter()
        }
        return nil
    }
}

/// Errors that can occur during conversion
enum ConversionError: Error {
    case invalidEncoding
    case conversionFailed
    
    var localizedDescription: String {
        switch self {
        case .invalidEncoding:
            return "Failed to decode data as UTF-8 string"
        case .conversionFailed:
            return "Failed to convert response"
        }
    }
}

// MARK: - URLSession Extension
extension URLSession {
    
    /// Performs a data task that converts the response to a String
    /// - Parameters:
    ///   - url: The URL to request
    ///   - completion: Completion handler with Result containing String or Error
    /// - Returns: The data task
    @discardableResult
    func stringDataTask(with url: URL, completion: @escaping (Result<String, Error>) -> Void) -> URLSessionDataTask {
        let task = dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(ConversionError.conversionFailed))
                return
            }
            
            let converter = StringConverter()
            do {
                let string = try converter.convert(data: data)
                completion(.success(string))
            } catch {
                completion(.failure(error))
            }
        }
        task.resume()
        return task
    }
    
    /// Performs a data task that converts the response to a String (async/await version)
    /// - Parameter url: The URL to request
    /// - Returns: The converted String
    func stringData(from url: URL) async throws -> String {
        let (data, _) = try await data(from: url)
        let converter = StringConverter()
        return try converter.convert(data: data)
    }
}
