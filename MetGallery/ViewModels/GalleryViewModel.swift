//
//  GalleryViewModel.swift
//  MetGallery
//
//  Created by yaxin on 2025-04-18.
//
import SwiftData
import Foundation

@MainActor
class GalleryViewModel: ObservableObject {
    private var apService: ArtpieceServiceProtocol
    @Published var artpieceDTOList = [ArtpieceDTO]()
    @Published var error: Error?
    @Published var searchStatus: CurrentStatus = .searchNotStarted
    enum CurrentStatus {
        case searchNotStarted
        case searching
        case searchFoundResult
        case searchFoundNothing
    }
    
    init(apService: ArtpieceServiceProtocol) {
        self.apService = apService
    }
    
    func generateInitialBatch(with keyword: String) async {
        searchStatus = .searching
        do {
            artpieceDTOList = try await apService.generateObjectIDListAndFetchFirstPage(with: keyword)
            searchStatus = artpieceDTOList.isEmpty ? .searchFoundNothing : .searchFoundResult
        } catch {
            print("error is \(error.localizedDescription)")
            searchStatus = .searchNotStarted
            self.error = error
        }
    }
    
    func fetchNextBatch() async {
        searchStatus = .searching
        do {
            let newItems = try await apService.fetchArtpieceInTheNextBatch()
            artpieceDTOList.append(contentsOf: newItems)
            searchStatus = artpieceDTOList.isEmpty ? .searchFoundNothing : .searchFoundResult
        } catch {
            print("error is \(error.localizedDescription)")
            searchStatus = .searchNotStarted
            self.error = error
        }
    }
}
