import SwiftUI

final class DocumentPicker: NSObject, UIViewControllerRepresentable {
    typealias UIViewControllerType = UIDocumentPickerViewController

    lazy var viewController:UIDocumentPickerViewController = {
        // For picked only folder
//        let vc = UIDocumentPickerViewController(documentTypes: ["public.folder"], in: .open)
        // For picked every document
        let vc = UIDocumentPickerViewController(documentTypes: ["public.bottles"], in: .open)
        // For picked only images
//        let vc = UIDocumentPickerViewController(documentTypes: ["public.image"], in: .open)
        vc.allowsMultipleSelection = false
//        vc.accessibilityElements = [kFolderActionCode]
//        vc.shouldShowFileExtensions = true
        vc.delegate = self
        return vc
    }()

    func makeUIViewController(context: UIViewControllerRepresentableContext<DocumentPicker>) -> UIDocumentPickerViewController {
        viewController.delegate = self
        return viewController
    }

    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: UIViewControllerRepresentableContext<DocumentPicker>) {
    }
}

extension DocumentPicker: UIDocumentPickerDelegate {
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        print(urls)
    }

    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        controller.dismiss(animated: true) {
        }
        print("Cancelled File Picker")
    }
}
