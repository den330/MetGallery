//
//  ArtpieceServiceMock.swift
//  MetGallery
//
//  Created by yaxin on 2025-04-21.
//

import UIKit
@testable import MetGallery

@MainActor
class ArtpieceServiceMock: ArtpieceServiceProtocol {
    private(set) var lastKeyword: String?
    private(set) var lastHighResID: Int?
    private(set) var lastHighResURLStr: String?
    private(set) var lastLowResID: Int?
    private(set) var lastLowResURLStr: String?
    private(set) var highResCalls: [(id: Int, url: String)] = []
    private(set) var lowResCalls: [(id: Int, url: String)] = []
    var highResImageToBeReturned: UIImage?
    var lowResImageDataToBeReturned: Data?
    var dtosToBeReturned: [ArtpieceDTO] = []
    var delay: UInt64 = 0
    private func maybeDelay() async {
        guard delay > 0 else { return }
        try? await Task.sleep(nanoseconds: delay)
    }
    
    var fetchArtpieceInTheNextBatchError: Error?
    var generateObjectIDListAndFetchFirstPageError: Error?
    var fetchHighResImageError: Error?
    var fetchLowResImageDataError: Error?
    
    func fetchArtpieceInTheNextBatch() async throws -> [MetGallery.ArtpieceDTO] {
        await maybeDelay()
        if let error = fetchArtpieceInTheNextBatchError {
            throw error
        }
        return dtosToBeReturned
    }
    
    func generateObjectIDListAndFetchFirstPage(with keyword: String) async throws -> [MetGallery.ArtpieceDTO] {
        lastKeyword = keyword
        await maybeDelay()
        if let error = generateObjectIDListAndFetchFirstPageError {
            throw error
        }
        return dtosToBeReturned
    }
    
    func fetchHighResImage(for id: Int, urlStr: String) async throws -> UIImage? {
        lastHighResID = id
        lastHighResURLStr = urlStr
        highResCalls.append((id, urlStr))
        await maybeDelay()
        if let error = fetchHighResImageError {
            throw error
        }
        return highResImageToBeReturned
    }
    
    func fetchLowResImageData(for id: Int, urlStr: String) async throws -> Data? {
        lastLowResID = id
        lastLowResURLStr = urlStr
        lowResCalls.append((id, urlStr))
        await maybeDelay()
        if let error = fetchLowResImageDataError {
            throw error
        }
        return lowResImageDataToBeReturned
    }
    
    func reset() {
        lastKeyword = nil
        lastHighResID = nil
        lastHighResURLStr = nil
        lastLowResID = nil
        lastLowResURLStr = nil
        highResCalls = []
        lowResCalls = []
        highResImageToBeReturned = nil
        lowResImageDataToBeReturned = nil
        dtosToBeReturned = []
        delay = 0
        fetchArtpieceInTheNextBatchError = nil
        generateObjectIDListAndFetchFirstPageError = nil
        fetchHighResImageError = nil
        fetchLowResImageDataError = nil
    }
}
