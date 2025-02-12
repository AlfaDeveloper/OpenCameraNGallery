//
//  ContentView.swift
//  OpenCameraNGallery
//
//  Created by Alfredo Rastello on 20/01/25.
//

import SwiftUI
import PhotosUI

public let MAX_MEDIA_FILES = 3

enum MediaType: Int {
    case photo = 1
    case video
}

struct ContentView: View {
    @State private var showActionSheet = false
    @State private var showPhotoPicker = false
    @State private var showCamera = false
    @State private var showPermissionAlert = false
    @State private var mediaData: [(MediaType?, Data?)] = []
    
    var body: some View {
        VStack {
            Button("Load your media") { showActionSheet = true }
            .padding(.bottom, 32)
            ScrollView(.horizontal, showsIndicators: false) {
                ForEach(Array(mediaData.enumerated()), id: \.offset) { index, media in
                    VStack {
                        HStack {
                            let mediaTypeText = media.0 == .photo ? "photo" : "video"
                            Text("Loaded " + mediaTypeText + " \(index + 1)")
                            Spacer()
                            Button(action: {
                                mediaData.remove(at: index)
                            }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.red)
                            }
                        }
                    }
                }
            }
            .frame(height: 60)
            .actionSheet(isPresented: $showActionSheet) {
                ActionSheet(
                    title: Text("Select an option"),
                    buttons: [
                        .default(Text("Camera")) {
                            CameraView.checkCameraPermission { granted in
                                showCamera = granted
                                if !granted {
                                    showPermissionAlert = true
                                    print("Permission denied. Display a warning to the user.")
                                }
                            }
                        },
                        .default(Text("Gallery")) {
                            showPhotoPicker = true
                        },
                        .cancel()
                    ]
                )
            }
            .sheet(isPresented: $showPhotoPicker) {
                PhotoPickerView(maxSelectionCount: MAX_MEDIA_FILES - mediaData.count) { mediaType, data in
                    if let mediaType = mediaType, let data = data, mediaData.count < MAX_MEDIA_FILES {
                        mediaData.append((mediaType, data))
                    }
                }
            }
            .sheet(isPresented: $showCamera) {
                CameraView(onFileCaptured: { mediaType, data in
                    if let mediaType = mediaType, let data = data, mediaData.count < MAX_MEDIA_FILES {
                        mediaData.append((mediaType, data))
                    }
                })
            }
        }
        .alert("Permission denied.", isPresented: $showPermissionAlert) {
            Button("OK") {
                showPermissionAlert = false
            }
        }
        .padding()
    }
}

#Preview {
    ContentView()
}

