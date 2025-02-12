//
//  CameraView.swift
//  OpenCameraNGallery
//
//  Created by Alfredo Rastello on 21/01/25.
//

import SwiftUI
import PhotosUI

struct CameraView: UIViewControllerRepresentable {
    var onFileCaptured: (MediaType?, Data?) -> Void
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .camera
        imagePicker.allowsEditing = true
        imagePicker.delegate = context.coordinator
        return imagePicker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> CoordinatorCameraView {
        CoordinatorCameraView(onFileCaptured: onFileCaptured)
    }
    
    static func checkCameraPermission(completion: @escaping (Bool) -> Void) {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        switch status {
        case .authorized:
            completion(true)
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                DispatchQueue.main.async {
                    completion(granted)
                }
            }
        default:
            completion(false)
        }
    }
}

final public class CoordinatorCameraView: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    var onFileCaptured: (MediaType?, Data?) -> Void
    
    init(onFileCaptured: @escaping (MediaType?, Data?) -> Void) {
        self.onFileCaptured = onFileCaptured
    }
    
    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[.originalImage] as? UIImage {
            if let imageData = image.jpegData(compressionQuality: 0.8) {
                self.onFileCaptured(.photo, imageData)
            }
        }
        picker.dismiss(animated: true)
    }
    
    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.onFileCaptured(nil, nil)
        picker.dismiss(animated: true)
    }
}

