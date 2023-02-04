import BookModel
import SwiftUI
import CoreData

struct MainView: View {

    @ObservedObject var bookModel: BookModel
    @State var tint: Color = .white

    var body: some View {
        ZStack {
            if let book = bookModel.book {
                BookView(book: book, tint: $tint)
                    .toolbar {
                        ToolbarItemGroup(placement: .bottomBar) {
                            Button {
                                print("Search")
                            } label: {
                                Image(systemName: "magnifyingglass")
                            }
                            Spacer()
                            Menu {
                                Button {
                                    print("Play Tune")
                                } label: {
                                    Label("Play Tune", systemImage: "play")
                                }
                                if bookModel.bookWithTunesURL != nil {
                                    Menu {
//                                        ShareLink(item: Songbook(url: bookModel.bookWithTunesURL!), preview: SharePreview(bookModel.bookWithTunesURL!.lastPathComponent, image: Image("Icon"))) {
                                        ShareLink(item: bookModel.bookWithTunesURL!) {
                                            Label("With Tunes", systemImage: "music.note")
                                        }
                                        ShareLink(item: bookModel.bookWithoutTunesURL!) {
                                            Label("Without Tunes", systemImage: "nosign")
                                        }
                                    } label: {
                                        Label("Share Book", systemImage: "square.and.arrow.up")
                                    }
                                } else {
                                    ShareLink(item: bookModel.bookWithoutTunesURL!) {
                                        Label("Share Book", systemImage: "square.and.arrow.up")
                                    }
                                }
                                Menu {
                                    Button {
                                        print("Light Background")
                                    } label: {
                                        Toggle(isOn: .constant(true)) {
                                            Label("Light", systemImage: "sun.max")
                                        }
                                    }
                                    Button {
                                        print("Dark Background")
                                    } label: {
                                        Toggle(isOn: .constant(false)) {
                                            Label("Dark", systemImage: "moon")
                                        }
                                    }
                                    Button {
                                        print("Automatic Background")
                                    } label: {
                                        Toggle(isOn: .constant(false)) {
                                            Label("Automatic", systemImage: "circle.righthalf.filled")
                                        }
                                    }
                                    Divider()
                                    Button {
                                        print("Default Font")
                                    } label: {
                                        Toggle(isOn: .constant(true)) {
                                            Label("Default Font", systemImage: "textformat")
                                        }
                                    }
                                    Button {
                                        print("Low Vision Font")
                                    } label: {
                                        Toggle(isOn: .constant(false)) {
                                            Label("Low Vision Font", systemImage: "a.magnify")
                                        }
                                    }
                                    Button {
                                        print("Custom Font")
                                    } label: {
                                        Toggle(isOn: .constant(false)) {
                                            Label("Custom Font", systemImage: "ellipsis.circle")
                                        }
                                    }
                                } label: {
                                    Label("Appearance", systemImage: "textformat.size") // textformat.size eye paintpalette sun.max
                                }
                            } label: {
                                Image(systemName: "ellipsis.circle")
                            }
                            .menuOrder(.fixed)
                        }
                    }
                    .ignoresSafeArea()
                    .tint(tint)
            } else {
                RedGradientView()
                VStack {
                    Text("Opening Book")
                        .foregroundColor(.white)
                    ProgressView()
                        .tint(.white)
                        .progressViewStyle(.circular)
                }
            }
        }
        .statusBarHidden(true)
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView(bookModel: BookModel())
    }
}
