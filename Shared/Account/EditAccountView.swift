//
//  EditAccountView.swift
//  Flag Ceremony
//
//  Created by Vito Royeca on 3/24/23.
//

import SwiftUI

struct EditAccountView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var accountViewModel: AccountViewModel
    @State var photoURL: URL?
    @State var photoDirty = false
    @State var displayName: String?
    @State private var sourceType: UIImagePickerController.SourceType = .photoLibrary
    @State private var isShowingImagePicker = false

    var body: some View {
        Form {
            Section(header: Text("Avatar")) {
                HStack {
                    AccountImageView(photoURL: $photoURL)

                    Spacer()

                    Button(action: {
                        sourceType = .photoLibrary
                        isShowingImagePicker.toggle()
                    }) {
                        Image(systemName: "photo")
                            .font(Font.largeTitle)
                            .imageScale(.large)
                    }
                        .buttonStyle(.borderless)
                    Button(action: {
                        sourceType = .camera
                        isShowingImagePicker.toggle()
                    }) {
                        Image(systemName: "camera")
                            .font(Font.largeTitle)
                            .imageScale(.large)
                    }
                        .buttonStyle(.borderless)
                    Button(action: {
                        photoURL = nil
                        photoDirty = true
                    }) {
                        Image(systemName: "minus.circle")
                            .font(Font.largeTitle)
                            .imageScale(.large)
                    }
                        .buttonStyle(.borderless)
                }
            }
            Section(header: Text("Display Name")) {
                TextField("Enter your Display Name", text: $displayName)
            }
        }
            .navigationTitle(Text("Edit Account"))
            .toolbar {
                EditAccountToolbar(presentationMode: presentationMode,
                                   photoURL: $photoURL,
                                   photoDirty: $photoDirty,
                                   displayName: $displayName)
            }
            .onAppear {
                photoURL = URL(string: accountViewModel.account?.photoURL ?? "")
                displayName = accountViewModel.account?.displayName
            }
            .sheet(isPresented: $isShowingImagePicker) {
                ImagePickerView(sourceType: sourceType,
                                selectedImageURL: $photoURL,
                                photoDirty: $photoDirty)
            }
    }
}

struct EditAccountView_Previews: PreviewProvider {
    static var previews: some View {
        EditAccountView()
            .environmentObject(AccountViewModel())
    }
}

// MARK: - EditAccountToolbar

struct EditAccountToolbar: ToolbarContent {
    @EnvironmentObject var viewModel: AccountViewModel
    @Binding var presentationMode: PresentationMode
    @Binding var photoURL: URL?
    @Binding var photoDirty: Bool
    @Binding var displayName: String?
    
    init(presentationMode: Binding<PresentationMode>,
         photoURL: Binding<URL?>,
         photoDirty: Binding<Bool>,
         displayName: Binding<String?>) {
        _presentationMode = presentationMode
        _photoURL = photoURL
        _photoDirty = photoDirty
        _displayName = displayName
    }
    
    var body: some ToolbarContent {
        ToolbarItemGroup(placement: .navigationBarLeading) {
            Button("Cancel") {
                $presentationMode.wrappedValue.dismiss()
            }
        }
        ToolbarItemGroup(placement: .navigationBarTrailing) {
            Button("Save") {
                viewModel.update(photoURL: photoURL, photoDirty: photoDirty, displayName: displayName)
                $presentationMode.wrappedValue.dismiss()
            }
        }
    }
}
