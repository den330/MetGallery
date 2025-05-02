//
//  RandomWordGenerator.swift
//  MetGallery
//
//  Created by yaxin on 2025-05-02.
//
import Foundation

struct RandomWordGenerator {
    static func generateRandomWord() -> String? {
        guard let url = Bundle.main.url(forResource: "Words", withExtension: "txt"), let data = try? String(contentsOf: url, encoding: .utf8) else {
            return nil
        }
        let words = data.components(separatedBy: .newlines).map {$0.trimmingCharacters(in: .whitespaces)}.filter {!$0.isEmpty}
        return words.randomElement()
    }
}
