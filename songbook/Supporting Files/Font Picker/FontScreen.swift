//
//  FontScreen.swift
//  songbook
//
//  Created by Paul Himes on 3/22/23.
//

import SwiftUI

struct FontScreen: View {
    /// A function used to dismiss this screen.
    @Environment(\.dismiss) private var dismiss

    /// The currently selected font.
    @AppStorage(.StorageKey.fontMode) var fontMode: FontMode = .default

    var body: some View {
        NavigationStack {
            FontPicker(
                fontName: Binding(
                    get: {
                        fontMode.rawValue
                    },
                    set: { value in
                        guard let value else { return }
                        fontMode = FontMode(rawValue: value)!
                    }
                )
            )
            .navigationTitle("Custom Font")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                Button("Cancel", role: .cancel) {
                    dismiss()
                }
            }
        }
    }
}

struct FontScreen_Previews: PreviewProvider {
    static var previews: some View {
        FontScreen()
    }
}
