//
//  CacheManager.swift
//  MetGallery
//
//  Created by yaxin on 2025-04-18.
//
import UIKit

@MainActor
final class CacheManager {
    static let shared = CacheManager()
    private var cache = NSCache<NSNumber, UIImage>()
    
    private init() {
        cache.countLimit = 100
        cache.totalCostLimit = 50 * 1024 * 1024
    }
    
    func insertImage(_ image: UIImage, id: Int) {
        let cost = image.pngData()?.count ?? 1
        cache.setObject(image, forKey: id as NSNumber, cost: cost)
    }
    
    func image(for id: Int) -> UIImage? {
        cache.object(forKey: id as NSNumber)
    }
    
    func removeImage(for id: Int) {
        cache.removeObject(forKey: id as NSNumber)
    }
    
    func removeAll() {
        cache.removeAllObjects()
    }
}


@MainActor
final class LowResCacheManager {
    static let shared = LowResCacheManager()
    private var cache = NSCache<NSString, NSData>()
    
    private init() {
        cache.countLimit = 100
        cache.totalCostLimit = 50 * 1024 * 1024
    }
    
    func insertData(_ data: Data, urlString: String) {
        cache.setObject(data as NSData, forKey: urlString as NSString, cost: data.count)
    }
    
    func data(for urlString: String) -> Data? {
        cache.object(forKey: urlString as NSString) as? Data
    }
    
    func removeData(for urlString: String) {
        cache.removeObject(forKey: urlString as NSString)
    }
    
    func removeAll() {
        cache.removeAllObjects()
    }
}
