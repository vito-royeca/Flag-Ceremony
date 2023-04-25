//
//  FirebaseManager+Async.swift
//  Flag Ceremony
//
//  Created by Vito Royeca on 4/21/23.
//

import Foundation

// MARK: - User methods

extension FirebaseManager {
    func fetchUser() async throws -> FCUser? {
        return try await withCheckedThrowingContinuation { continuation in
            fetchUser() { result in
                continuation.resume(with: result)
            }
        }
    }

    func updateUser(photoURL: URL?, photoDirty: Bool, displayName: String?) async throws {
        return try await withCheckedThrowingContinuation { continuation in
            updateUser(photoURL: photoURL, photoDirty: photoDirty, displayName: displayName) { result in
                continuation.resume(with: result)
            }
        }
    }
    
    func updatePhoto(photoURL: URL?, photoDirty: Bool) async throws -> URL? {
        return try await withCheckedThrowingContinuation { continuation in
            updatePhoto(photoURL: photoURL, photoDirty: photoDirty) { result in
                continuation.resume(with: result)
            }
        }
    }
    
    func toggleFavorite(_ key: String) async throws {
        return try await withCheckedThrowingContinuation { continuation in
            toggleFavorite(key) { result in
                continuation.resume(with: result)
            }
        }
    }
}

// MARK: - Country methods

extension FirebaseManager {
    func incrementCountryViews(_ key: String) async throws -> FCCountry? {
        return try await withCheckedThrowingContinuation { continuation in
            incrementCountryViews(key) { result in
                continuation.resume(with: result)
            }
        }
    }
    
    func incrementCountryPlays(_ key: String) async throws -> FCCountry? {
        return try await withCheckedThrowingContinuation { continuation in
            incrementCountryPlays(key) { result in
                continuation.resume(with: result)
            }
        }
    }
    
    func findAnthem(_ key: String) async throws -> FCAnthem? {
        return try await withCheckedThrowingContinuation { continuation in
            findAnthem(key) { result in
                continuation.resume(with: result)
            }
        }
    }
    
    func downloadAnthem(country: FCCountry) async throws -> URL {
        return try await withCheckedThrowingContinuation { continuation in
            downloadAnthem(country: country) { result, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                guard let result = result else {
                    fatalError("Expected non-nil result 'result' for nil error")
                }
                continuation.resume(returning: result)
            }
        }
    }
    
    func fetchAllCountries() async throws -> [FCCountry] {
        return try await withCheckedThrowingContinuation { continuation in
            fetchAllCountries() { result in
                continuation.resume(with: result)
            }
        }
    }

    func findCountries(keys: [String]) async throws -> [FCCountry] {
        return try await withCheckedThrowingContinuation { continuation in
            findCountries(keys: keys) { result in
                continuation.resume(with: result)
            }
        }
    }

    func findCountry(_ key: String) async throws -> FCCountry? {
        return try await withCheckedThrowingContinuation { continuation in
            findCountry(key) { result in
                continuation.resume(with: result)
            }
        }
    }
}

// MARK: - Chart methods

extension FirebaseManager {
    func monitorTopViewed() async -> [FCCountry] {
        return await withCheckedContinuation { continuation in
            monitorTopViewed() { result in
                continuation.resume(returning: result)
            }
        }
    }
    
    func monitorTopViewers() async -> [FCActivity] {
        return await withCheckedContinuation { continuation in
            monitorTopViewers() { result in
                continuation.resume(returning: result)
            }
        }
    }
    
    func monitorTopPlayed() async -> [FCCountry] {
        return await withCheckedContinuation { continuation in
            monitorTopPlayed() { result in
                continuation.resume(returning: result)
            }
        }
    }
    
    func monitorTopPlayers() async -> [FCActivity] {
        return await withCheckedContinuation { continuation in
            monitorTopPlayers() { result in
                continuation.resume(returning: result)
            }
        }
    }
    
    func monitorUsers() async -> [FCUser] {
        return await withCheckedContinuation { continuation in
            monitorUsers() { result in
                continuation.resume(returning: result)
            }
        }
    }
    
    func monitorUserActivity() async throws -> FCActivity? {
        return try await withCheckedThrowingContinuation { continuation in
            monitorUserActivity() { result in
                continuation.resume(with: result)
            }
        }
    }
}
