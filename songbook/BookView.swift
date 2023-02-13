import BookModel
import SwiftUI

struct BookView: UIViewControllerRepresentable {

    // MARK: Public Properties

    /// The book displayed by this view.
    let book: Book

    /// The tint color of the bottom toolbar controls.
    @Binding var tint: Color

    /// The page view models of the book.
    var pages: [PageModel] {
        var pageModels: [PageModel] = []
        pageModels.append(.book(title: book.title, version: book.version))
        for section in book.sections {
            pageModels.append(.section(title: section.title ?? "Untitled Section"))
            for song in section.songs {
                var title = ""
                if let number = song.number {
                    title.append("\(number): ")
                }
                title.append(song.title ?? "Untitled Song")
                pageModels.append(.song(title: title))
            }
        }
        return pageModels
    }

    // MARK: Public Functions

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIViewController(context: Context) -> UIPageViewController {
        let controller = UIPageViewController(
            transitionStyle: .scroll,
            navigationOrientation: .horizontal
        )
        controller.dataSource = context.coordinator
        controller.delegate = context.coordinator

        controller.setViewControllers(
            [context.coordinator.controllers[0]],
            direction: .forward,
            animated: true
        )

        return controller
    }

    func updateUIViewController(_ pageViewController: UIPageViewController, context: Context) {
//        pageViewController.setViewControllers(
//            [context.coordinator.controllers[0]],
//            direction: .forward,
//            animated: true
//        )
    }

    // MARK: Nested Types

    class Coordinator: NSObject, UIPageViewControllerDataSource, UIPageViewControllerDelegate {

        // MARK: Public Properties

        var parent: BookView

        var controllers = [UIViewController]()

        // MARK: Public Functions

        init(_ bookView: BookView) {
            parent = bookView
            controllers = parent.pages.map {
                let viewController: UIViewController
                switch $0 {
                case let .book(title, version):
                    viewController = UIHostingController(
                        rootView: BookPageView(title: title, version: version)
                    )
                case let .section(title):
                    viewController = UIHostingController(rootView: SectionPageView(title: title))
                case let .song(title):
                    viewController = UIHostingController(rootView: SongPageView(title: title))
                }
                viewController.view.backgroundColor = .clear
                return viewController
            }
        }

        func pageViewController(
            _ pageViewController: UIPageViewController,
            viewControllerAfter viewController: UIViewController
        ) -> UIViewController? {
            guard let index = controllers.firstIndex(of: viewController) else {
                return nil
            }
            if index + 1 == controllers.count {
                return controllers.first
            }
            return controllers[index + 1]
        }

        func pageViewController(
            _ pageViewController: UIPageViewController,
            viewControllerBefore viewController: UIViewController
        ) -> UIViewController? {
            guard let index = controllers.firstIndex(of: viewController) else {
                return nil
            }
            if index == 0 {
                return controllers.last
            }
            return controllers[index - 1]
        }

        func pageViewController(
            _ pageViewController: UIPageViewController,
            didFinishAnimating finished: Bool,
            previousViewControllers: [UIViewController],
            transitionCompleted completed: Bool
        ) {
            withAnimation {
                if pageViewController.viewControllers?.first is UIHostingController<BookPageView> {
                    parent.tint = .white
                } else {
                    parent.tint = .accentColor
                }
            }
        }
    }
}

struct BookView_Previews: PreviewProvider {
    static var previews: some View {
        BookView(book: BookModel().book!, tint: .constant(.white))
    }
}
