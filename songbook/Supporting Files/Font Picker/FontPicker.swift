import SwiftUI
import UIKit

struct FontPicker: UIViewControllerRepresentable {
    @Binding var fontName: String?
    @Environment(\.dismiss) private var dismiss

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIViewController(context: Context) -> some UIViewController {
        let picker = UIFontPickerViewController()
        if let fontName {
            picker.selectedFontDescriptor = UIFontDescriptor(name: fontName, size: 12)
        }
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {}

    // MARK: Nested Types

    class Coordinator: NSObject, UIFontPickerViewControllerDelegate {
        let parent: FontPicker

        init(_ parent: FontPicker) {
            self.parent = parent
        }

        func fontPickerViewControllerDidCancel(_ viewController: UIFontPickerViewController) {
            parent.dismiss()
        }

        func fontPickerViewControllerDidPickFont(_ viewController: UIFontPickerViewController) {
            parent.fontName = viewController.selectedFontDescriptor?.postscriptName
            parent.dismiss()
        }
    }
}
