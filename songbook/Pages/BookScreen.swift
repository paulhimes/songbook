import BookModel
import SwiftUI

/// Shows the pages of a book.
struct BookScreen: UIViewControllerRepresentable {

    // MARK: Public Properties

    /// The page view models of the book.
    let pages: [PageModel]

    /// The tint color of the bottom toolbar controls.
    @Binding var tint: Color

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

        var parent: BookScreen

        var controllers = [UIViewController]()

        // MARK: Public Functions

        init(_ bookView: BookScreen) {
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
        BookScreen(pages: BookModel().index?.pageModels ?? [], tint: .constant(.white))
    }
}
