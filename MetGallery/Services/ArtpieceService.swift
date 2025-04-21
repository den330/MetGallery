//
//  ArtpieceFetcher.swift
//  MetGallery
//
//  Created by yaxin on 2025-04-18.
//

import Foundation
import SwiftData
import UIKit

@MainActor
protocol ArtpieceServiceProtocol: AnyObject {
    func fetchArtpieceInTheNextBatch() async throws -> [ArtpieceDTO]
    func generateObjectIDListAndFetchFirstPage(with keyword: String) async throws -> [ArtpieceDTO]
    func fetchHighResImage(for id: Int, urlStr: String) async throws -> UIImage?
    func fetchLowResImageData(for id: Int, urlStr: String) async throws -> Data?
}

@MainActor
class ArtpieceService: ArtpieceServiceProtocol {
    enum ArtpieceServiceError: Error {
        case artpieceFetchError
        case smallImageFetchError
        case invalidUrl
    }
    private let context: ModelContext
    private var page = 1
    private let batchSize = 20
    private var objectIDList: [Int] = []
    private let baseURL = URL(string: "https://collectionapi.metmuseum.org")!
    
    init(context: ModelContext) {
        self.context = context
    }
    
    // example: https://collectionapi.metmuseum.org/public/collection/v1/search?hasImages=true&q=Auguste%20Renoir
    func generateObjectIDListAndFetchFirstPage(with keyword: String) async throws -> [ArtpieceDTO]{
        var urlComponents = URLComponents(url: baseURL, resolvingAgainstBaseURL: true)!
        urlComponents.path = "/public/collection/v1/search"
        urlComponents.queryItems = [URLQueryItem(name: "hasImages", value: "true"), URLQueryItem(name: "q", value: keyword)]
        var urlRequest = URLRequest(url: urlComponents.url!)
        print("url is \(urlComponents.url!)")
        urlRequest.httpMethod = "GET"
        let (data, response) = try await URLSession.shared.data(for: urlRequest)
        guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
            print("response is \(response)")
            throw ArtpieceServiceError.artpieceFetchError
        }
        print("response is \(response)")
        let decoder = JSONDecoder()
        let idListObject = try decoder.decode(IDList.self, from: data)
        let favIds = try context.fetch(FetchDescriptor<Artpiece>()).map { $0.id }
        objectIDList = idListObject.objectIDs.filter {!favIds.contains($0)}
        page = 1
        return try await fetchArtpieceInTheNextBatch()
    }
    
    private func fetchObjectDTO(with id: Int) async throws -> ArtpieceDTO {
        var urlComponents = URLComponents(url: baseURL, resolvingAgainstBaseURL: true)!
        urlComponents.path = "/public/collection/v1/objects/\(id)"
        var urlRequest = URLRequest(url: urlComponents.url!)
        urlRequest.httpMethod = "GET"
        let (data, response) = try await URLSession.shared.data(for: urlRequest)
        guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
            throw ArtpieceServiceError.artpieceFetchError
        }
        let decoder = JSONDecoder()
        return try decoder.decode(ArtpieceDTO.self, from: data)
    }
    
    private func fetchAll(ids: [Int]) async throws -> [ArtpieceDTO] {
        return await withTaskGroup(of: ArtpieceDTO?.self) { group in
            for id in ids {
                group.addTask {
                    do {
                        let dto = try await self.fetchObjectDTO(with: id)
                        return dto
                    } catch {
                        return nil
                    }
                }
            }
            var results = [ArtpieceDTO]()
            for await result in group {
                if let obj = result {
                    results.append(obj)
                }
            }
            return results
        }
    }
    
    func fetchArtpieceInTheNextBatch() async throws -> [ArtpieceDTO] {
        let startIndex = (page - 1) * batchSize
        if startIndex >= objectIDList.count {
            return []
        }
        let endIndex = Int(min(objectIDList.count, startIndex + batchSize))
        let artList = try await fetchAll(ids: Array(objectIDList[startIndex..<endIndex]))
        page += 1
        return artList
    }
    
    func fetchHighResImage(for id: Int, urlStr: String) async throws -> UIImage? {
        if let image = CacheManager.shared.image(for: id) {
            return image
        }
        print("high res url is \(urlStr)")
        guard let url = URL(string: urlStr) else {
            throw ArtpieceServiceError.invalidUrl
        }
        let urlRequest = URLRequest(url: url)
        let (data, _) = try await URLSession.shared.data(for: urlRequest)
        if let image = UIImage(data: data) {
            CacheManager.shared.insertImage(image, id: id)
            return image
        }
        return nil
    }
    
    func fetchLowResImageData(for id: Int, urlStr: String) async throws -> Data? {
        guard let url = URL(string: urlStr) else {
            throw ArtpieceServiceError.invalidUrl
        }
        let urlRequest = URLRequest(url: url)
        let (data, response) = try await URLSession.shared.data(for: urlRequest)
        guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
            throw ArtpieceServiceError.artpieceFetchError
        }
        print("response for low res is \(response)")
        return data
    }

}
