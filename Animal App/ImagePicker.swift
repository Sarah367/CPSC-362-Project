import Foundation
import UIKit
import SwiftUI

struct ImagePicker: UIViewControllerRepresentable {
    let onImagePicked: (UIImage?) -> Void
    @Environment(\.dismiss) public var dismiss
    
//    @Binding var selectedImage: [UIImage]
//    @Binding var isPickerShowing: Bool
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .photoLibrary
        imagePicker.delegate = context.coordinator// object can receive UIImagePickerController events
        imagePicker.modalPresentationStyle = .fullScreen
        return imagePicker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {
        // 
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
//        return Coordinator(self)
    }
}

class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    let parent: ImagePicker
//    var parent: ImagePicker
    
    init(_ picker: ImagePicker) {
        self.parent = picker
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        // Run the code when the user has selected an image
        print("image selected")
        if let image = info[.originalImage] as? UIImage {
            DispatchQueue.main.async {
                self.parent.onImagePicked(image)
                self.parent.dismiss()
            }
        } else {
            DispatchQueue.main.async {
                self.parent.onImagePicked(nil)
                self.parent.dismiss()
            }
        }
        //Dismiss the picker
        parent.dismiss()
//        parent.isPickerShowing = false
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        parent.onImagePicked(nil)
        parent.dismiss()
        print("cancelled")
    }
}
