//
//  File.swift
//  
//
//  Created by Ian on 29/06/2022.
//

#if os(iOS)
import Foundation
import PhotosUI
import SwiftUI

class ViewModel: ObservableObject {
    var configuration: PHPickerConfiguration
    var allowedContentTypes: [UTType] = []
    @Published var pathURLs: [URL] = []
    @Published var errors: [Error] = []
    @Published var isLoading: Bool = false
    @Published var progress: Progress
    var onCompletion: (Result<[URL], Error>) -> Void
    
    init(onCompletion: @escaping (Result<[URL], Error>) -> Void) {
        self.configuration = PHPickerConfiguration(photoLibrary: .shared())
        self.progress = Progress()
        self.onCompletion = onCompletion
    }
    
    func handleResults(for results: [PHPickerResult]) {
        withAnimation {
            isLoading = true
        }
        progress.totalUnitCount = Int64(results.count)
        
        for result in results {
            let contentTypes = allowedContentTypes
            for contentType in contentTypes {
                let progress: Progress?
                let itemProvider = result.itemProvider
                if itemProvider.hasItemConformingToTypeIdentifier(contentType.identifier) {
                    progress = itemProvider.loadFileRepresentation(forTypeIdentifier: contentType.identifier) { url, error in
                        do {
                            guard let url = url, error == nil else {
                                throw error!
                            }
                            let directory = FileManager.default.temporaryDirectory.appendingPathComponent("MediaPicker")
                            if !FileManager.default.fileExists(atPath: directory.path) {
                                try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true, attributes: nil)
                            }
                            let localURL: URL = directory.appendingPathComponent(url.lastPathComponent)
                            
                            if FileManager.default.fileExists(atPath: localURL.path) {
                                try? FileManager.default.removeItem(at: localURL)
                            }
                            try FileManager.default.copyItem(at: url, to: localURL)
                            DispatchQueue.main.async {
                                self.pathURLs.append(localURL)
                            }
                        } catch let catchedError {
                            DispatchQueue.main.async {
                                self.errors.append(catchedError)
                            }
                        }
                    }
                    if let progress = progress {
                        self.progress.addChild(progress, withPendingUnitCount: 1)
                    }
                }
            }
        }
    }
    
    func finaliseResults() {
        if pathURLs.isEmpty {
            onCompletion(.failure(errors[0]))
        } else {
            onCompletion(.success(pathURLs))
        }
        withAnimation {
            isLoading = false
        }
    }
}
#endif
