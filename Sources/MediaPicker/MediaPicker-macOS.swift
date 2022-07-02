//
//  File.swift
//  
//
//  Created by Ian on 29/06/2022.
//

#if os(macOS)
import SwiftUI

public extension View {
    func mediaPicker(
        isPresented: Binding<Bool>,
        allowedMediaTypes: MediaTypeOptions,
        onCompletion: @escaping (Result<URL, Error>) -> Void
    ) -> some View {
        self.fileImporter(
            isPresented: isPresented,
            allowedContentTypes: allowedMediaTypes.typeIdentifiers,
            onCompletion: onCompletion
        )
    }
    
    func mediaPicker(
        isPresented: Binding<Bool>,
        allowedMediaTypes: MediaTypeOptions,
        allowsMultipleSelection: Bool,
        onCompletion: @escaping (Result<[URL], Error>) -> Void
    ) -> some View {
        self.fileImporter(
            isPresented: isPresented,
            allowedContentTypes: allowedMediaTypes.typeIdentifiers,
            allowsMultipleSelection: allowsMultipleSelection,
            onCompletion: onCompletion
        )
    }
}
#endif
