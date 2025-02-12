//
//  PhotoPicker.swift
//  OpenCameraNGallery
//
//  Created by Alfredo Rastello on 21/01/25.
//

import Foundation
import SwiftUI
import PhotosUI

struct PhotoPickerView: UIViewControllerRepresentable {
    let maxSelectionCount: Int
    var onFileSelected: (MediaType?, Data?) -> Void
    
    func makeUIViewController(context: Context) -> PHPickerViewController {
        var configuration = PHPickerConfiguration()
        configuration.selectionLimit = maxSelectionCount
        configuration.filter = .any(of: [.images, .videos])
        
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}
    
    func makeCoordinator() -> CoordinatorPhotoPicker {
        CoordinatorPhotoPicker(maxSelectionCount: maxSelectionCount, onFileSelected: onFileSelected)
    }
}

final public class CoordinatorPhotoPicker: NSObject, PHPickerViewControllerDelegate {
    var onFileSelected: (MediaType?, Data?) -> Void
    let maxSelectionCount: Int
    
    init(maxSelectionCount: Int, onFileSelected: @escaping (MediaType?, Data?) -> Void) {
        self.maxSelectionCount = maxSelectionCount
        self.onFileSelected = onFileSelected
    }

    public func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        if results.isEmpty {
            DispatchQueue.main.async {
                picker.dismiss(animated: true, completion: { self.onFileSelected(nil, nil) })
            }
            return
        }
        
        let newItems = results.prefix(maxSelectionCount)
        
        for result in newItems {
            if result.itemProvider.canLoadObject(ofClass: UIImage.self) {
                loadImage(from: result, picker: picker)
            } else {
                loadVideo(from: result, picker: picker)
            }
        }
    }

    private func loadImage(from result: PHPickerResult, picker: PHPickerViewController) {
        result.itemProvider.loadObject(ofClass: UIImage.self) { [weak self] object, _ in
            guard let self = self, let image = object as? UIImage,
                  let imageData = image.jpegData(compressionQuality: 0.8) else {
                self?.onFileSelected(nil, nil)
                picker.dismiss(animated: true)
                return
            }
            DispatchQueue.main.async {
                self.onFileSelected(.photo, imageData)
                picker.dismiss(animated: true)
            }
        }
    }

    private func loadVideo(from result: PHPickerResult, picker: PHPickerViewController) {
        result.itemProvider.loadTransferable(type: Data.self) { [weak self] data in
            DispatchQueue.main.async {
                switch data {
                case .success(let videoData):
                    guard let self = self else {
                        self?.onFileSelected(nil, nil)
                        picker.dismiss(animated: true)
                        return
                    }
                    self.onFileSelected(.video, videoData)                    
                    picker.dismiss(animated: true)
                case .failure(let error):
                    print("Failed to load video: \(error.localizedDescription)")
                    self?.onFileSelected(nil, nil)
                    picker.dismiss(animated: true)
                }
            }
        }
    }
}
