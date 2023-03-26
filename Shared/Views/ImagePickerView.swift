//
//  ImagePickerView.swift
//  Flag Ceremony
//
//  Created by Vito Royeca on 3/25/23.
//

import SwiftUI

struct ImagePickerView: UIViewControllerRepresentable {
    @Environment(\.presentationMode) private var presentationMode
    var sourceType: UIImagePickerController.SourceType = .photoLibrary
    @Binding var selectedImageURL: URL?
    @Binding var photoDirty: Bool

    func makeUIViewController(context: UIViewControllerRepresentableContext<ImagePickerView>) -> UIImagePickerController {
        let imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = false
        imagePicker.sourceType = sourceType
        imagePicker.delegate = context.coordinator

        return imagePicker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: UIViewControllerRepresentableContext<ImagePickerView>) {

    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    final class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        var parent: ImagePickerView

        init(_ parent: ImagePickerView) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let url = info[.imageURL] as? URL {
                parent.selectedImageURL = url
                parent.photoDirty = true
            }
            
            if let image = info[.originalImage] as? UIImage,
               let resizedImage = image.resize(to: CGSize(width: 256, height: 256)),
               let data = resizedImage.pngData(),
               let url = temporaryURL() {

                try? data.write(to: url)
                parent.selectedImageURL = url
                parent.photoDirty = true
            }

            parent.presentationMode.wrappedValue.dismiss()
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.photoDirty = false
            parent.presentationMode.wrappedValue.dismiss()
        }
        
        private func temporaryURL() -> URL? {
            if let path = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first {
                let url = path.appendingPathComponent("\(Date().timeIntervalSinceNow).png", conformingTo: .url)
                
                if FileManager.default.fileExists(atPath: url.path) {
                    try? FileManager.default.removeItem(at: url)
                }
                return url
            }

            return nil
        }
    }
}
