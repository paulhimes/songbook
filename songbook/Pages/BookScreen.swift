import BookModel
import SwiftUI

/// Shows the pages of a book.
struct BookScreen: UIViewControllerRepresentable {

    // MARK: Public Properties

    /// The index of the currently visible page.
    @AppStorage(.StorageKey.currentPageIndex) var currentPageIndex = 0

    /// The page view models of the book.
    let pages: [PageModel]

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
            [context.coordinator.controllerFor(index: currentPageIndex)],
            direction: .forward,
            animated: true
        )

        return controller
    }

    func updateUIViewController(_ pageViewController: UIPageViewController, context: Context) {
        let newController = context.coordinator.controllerFor(index: currentPageIndex)
        let oldPageIndex = context.coordinator.indexOf(pageViewController.visibleViewController)
        guard oldPageIndex != currentPageIndex else {
            print("Invalid Page View Redisplay")
            return
        }
        pageViewController.setViewControllers(
            [newController],
            direction: oldPageIndex < currentPageIndex ? .forward : .reverse,
            animated: true
        )
    }

    // MARK: Nested Types

    class Coordinator: NSObject, UIPageViewControllerDataSource, UIPageViewControllerDelegate {

        // MARK: Public Properties

        var parent: BookScreen

        private var controllers = [UIViewController]()

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
                    viewController = UIHostingController(
                        rootView: SectionPageView(title: title)
                    )
                case let .song(title, _):
                    viewController = UIHostingController(
                        rootView: SongPageView(title: title)
                    )
                }
                viewController.view.backgroundColor = .clear
                return viewController
            }
        }

        func controllerFor(index: Int) -> UIViewController {
            guard controllers.count > index else {
                return UIViewController()
            }
            return controllers[index]
        }

        func indexOf(_ viewController: UIViewController?) -> Int {
            guard let viewController else { return 0 }
            return controllers.firstIndex(of: viewController) ?? 0
        }

        func pageViewController(
            _ pageViewController: UIPageViewController,
            viewControllerAfter viewController: UIViewController
        ) -> UIViewController? {
            controllerFor(
                index: (indexOf(viewController) + controllers.count + 1) % controllers.count
            )
        }

        func pageViewController(
            _ pageViewController: UIPageViewController,
            viewControllerBefore viewController: UIViewController
        ) -> UIViewController? {
            controllerFor(
                index: (indexOf(viewController) + controllers.count - 1) % controllers.count
            )
        }

        func pageViewController(
            _ pageViewController: UIPageViewController,
            didFinishAnimating finished: Bool,
            previousViewControllers: [UIViewController],
            transitionCompleted completed: Bool
        ) {
            guard completed else { return }
            parent.currentPageIndex = indexOf(pageViewController.visibleViewController)
        }
    }
}

struct BookView_Previews: PreviewProvider {
    static var previews: some View {
        BookScreen(
//            currentPageIndex: .constant(0),
            pages: BookModel().index?.pageModels ?? []
        )
    }
}

extension UIPageViewController {
    var visibleViewController: UIViewController? {
        viewControllers?.last
    }
}
