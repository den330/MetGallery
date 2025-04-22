import Testing
import UIKit
@testable import MetGallery

@MainActor
struct GalleryViewModelTests {
    static let dtoWithImage = ArtpieceDTO(
        objectID: 1,
        objectDate: "2025",
        title: "HasImage",
        artistDisplayName: "Artist",
        primaryImage: "high.jpg",
        primaryImageSmall: "small.jpg",
        department: "Test"
    )
    static let dtoNoImage = ArtpieceDTO(
        objectID: 2,
        objectDate: "2025",
        title: "NoImage",
        artistDisplayName: "Artist",
        primaryImage: "high2.jpg",
        primaryImageSmall: "",    // will be filtered out
        department: "Test"
    )
    
    private func makeSUT() -> (GalleryViewModel, ArtpieceServiceMock) {
        let mock = ArtpieceServiceMock()
        let vm = GalleryViewModel(apService: mock)
        return (vm, mock)
    }
    
    @Test
    func generateInitialBatch_happyPath_filtersEmptyAndSetsStatus() async {
        let (vm, mock) = makeSUT()
        mock.dtosToBeReturned = [Self.dtoNoImage, Self.dtoWithImage]
        await vm.generateInitialBatch(with: "keyword")
        #expect(vm.artpieceDTOList == [Self.dtoWithImage])
        #expect(vm.searchStatus == .searchFoundResult)
        #expect(vm.error == nil)
        #expect(mock.lastKeyword == "keyword")
    }
    
    @Test
    func generateInitialBatch_emptyResult_setsSearchFoundNothing() async {
        let (vm, mock) = makeSUT()
        mock.dtosToBeReturned = []   // no DTOs at all
        
        await vm.generateInitialBatch(with: "anything")
        
        #expect(vm.artpieceDTOList.isEmpty)
        #expect(vm.searchStatus == .searchFoundNothing)
    }
    
    @Test
    func generateInitialBatch_onError_resetsStatusAndCapturesError() async {
        let (vm, mock) = makeSUT()
        mock.generateObjectIDListAndFetchFirstPageError = TestError.dummy
        
        await vm.generateInitialBatch(with: "fail")
        
        #expect(vm.searchStatus == .searchNotStarted)
        #expect(vm.error is TestError)
    }
    
    @Test
    func fetchNextBatch_appendsNewItems_andUpdatesStatus() async {
        let (vm, mock) = makeSUT()
        mock.dtosToBeReturned = [Self.dtoWithImage]
        await vm.generateInitialBatch(with: "one")
        let second = ArtpieceDTO(
            objectID: 3,
            objectDate: "2025",
            title: "Second",
            artistDisplayName: "Artist",
            primaryImage: "h.jpg",
            primaryImageSmall: "s.jpg",
            department: "Test"
        )
        mock.dtosToBeReturned = [second]
        
        await vm.fetchNextBatch()
        
        #expect(vm.artpieceDTOList == [Self.dtoWithImage, second])
        #expect(vm.searchStatus == .searchFoundResult)
    }
    
    @Test
    func fetchNextBatch_emptyResult_setsSearchFoundNothing() async {
        let (vm, mock) = makeSUT()
        mock.dtosToBeReturned = []
        await vm.generateInitialBatch(with: "one")
        await vm.fetchNextBatch()
        #expect(vm.artpieceDTOList == [])
        #expect(vm.searchStatus == .searchFoundNothing)
    }
    
    @Test
    func fetchNextBatch_onError_resetsStatusAndCapturesError() async {
        let (vm, mock) = makeSUT()
        mock.dtosToBeReturned = [Self.dtoWithImage]
        await vm.generateInitialBatch(with: "one")
        mock.fetchArtpieceInTheNextBatchError = TestError.dummy
        await vm.fetchNextBatch()
        
        #expect(vm.searchStatus == .searchNotStarted)
        #expect(vm.error is TestError)
    }
    
    @Test
    func generateInitialBatch_showsSearching_thenFinalStatus() async throws {
            let (vm, mock) = makeSUT()
            mock.dtosToBeReturned = [Self.dtoWithImage]
            mock.delay = 200_000_000
            let task = Task { await vm.generateInitialBatch(with: "landscape") }
            await Task.yield()
            #expect(vm.searchStatus == .searching)
            await task.value
            #expect(vm.searchStatus == .searchFoundResult)
    }
}

private enum TestError: Error {
    case dummy
}
