//
//  APIClient.swift
//  BananaClicker
//
//  Created by Claude on 2025-11-22.
//

import Foundation
import OSLog

/// HTTP methods
enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
}

/// API Errors
enum APIError: LocalizedError {
    case invalidResponse
    case httpError(Int)
    case decodingError(Error)
    case networkError(Error)
    case unauthorized
    case notFound
    case serverError

    var errorDescription: String? {
        switch self {
        case .invalidResponse:
            return "Invalid server response"
        case .httpError(let code):
            return "HTTP error: \(code)"
        case .decodingError(let error):
            return "Decoding error: \(error.localizedDescription)"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .unauthorized:
            return "Unauthorized access"
        case .notFound:
            return "Resource not found"
        case .serverError:
            return "Server error occurred"
        }
    }
}

/// Main API Client for network requests
@Observable
final class APIClient: Sendable {
    static let shared = APIClient()

    private let baseURL = URL(string: "https://api.bananaclicker.app/v1")!
    private let session: URLSession
    private let logger = Logger(subsystem: "com.yourcompany.bananaclicker", category: "Network")

    init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        config.waitsForConnectivity = true
        config.requestCachePolicy = .reloadIgnoringLocalCacheData
        self.session = URLSession(configuration: config)
    }

    /// Make a generic API request
    func request<T: Decodable>(
        endpoint: Endpoint,
        method: HTTPMethod = .get,
        body: Encodable? = nil
    ) async throws -> T {
        var request = URLRequest(url: baseURL.appendingPathComponent(endpoint.path))
        request.httpMethod = method.rawValue
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        // Add auth token from Keychain
        if let token = await KeychainManager.shared.getToken() {
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        // Encode body if present
        if let body = body {
            do {
                request.httpBody = try JSONEncoder().encode(body)
            } catch {
                logger.error("Failed to encode request body: \(error.localizedDescription)")
                throw APIError.decodingError(error)
            }
        }

        logger.info("[\(method.rawValue)] \(endpoint.path)")

        do {
            let (data, response) = try await session.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse else {
                logger.error("Invalid response type")
                throw APIError.invalidResponse
            }

            logger.info("Response status: \(httpResponse.statusCode)")

            // Handle different status codes
            switch httpResponse.statusCode {
            case 200...299:
                break
            case 401:
                throw APIError.unauthorized
            case 404:
                throw APIError.notFound
            case 500...599:
                throw APIError.serverError
            default:
                throw APIError.httpError(httpResponse.statusCode)
            }

            // Decode response
            do {
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                return try decoder.decode(T.self, from: data)
            } catch {
                logger.error("Failed to decode response: \(error.localizedDescription)")
                throw APIError.decodingError(error)
            }

        } catch let error as APIError {
            throw error
        } catch {
            logger.error("Network request failed: \(error.localizedDescription)")
            throw APIError.networkError(error)
        }
    }

    /// Request without response body (for DELETE, etc.)
    func requestVoid(
        endpoint: Endpoint,
        method: HTTPMethod = .post,
        body: Encodable? = nil
    ) async throws {
        struct EmptyResponse: Codable {}
        let _: EmptyResponse = try await request(endpoint: endpoint, method: method, body: body)
    }
}
