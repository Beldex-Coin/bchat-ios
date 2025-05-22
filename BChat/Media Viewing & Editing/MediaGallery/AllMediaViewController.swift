// Copyright © 2025 Beldex International Limited OU. All rights reserved.

import Foundation

class AllMediaViewController: BaseVC {
    private let tileViewController: MediaTileViewController
    private let accessoriesHelper = MediaGalleryAccessoriesHelper()

    override var navigationItem: UINavigationItem {
        return tileViewController.navigationItem
    }

    init(
        thread: TSThread
    ) {
        tileViewController = MediaTileViewController(
            thread: thread,
            accessoriesHelper: accessoriesHelper
        )
        super.init()
        accessoriesHelper.viewController = tileViewController
    }

    override func viewDidLoad() {
        addChild(tileViewController)
        view.addSubview(tileViewController.view)
        tileViewController.view.autoPinEdgesToSuperviewEdges()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension AllMediaViewController: MediaPresentationContextProvider {

    func mediaPresentationContext(item: Media, in coordinateSpace: UICoordinateSpace) -> MediaPresentationContext? {
        return tileViewController.mediaPresentationContext(item: item, in: coordinateSpace)
    }

    func snapshotOverlayView(in coordinateSpace: UICoordinateSpace) -> (UIView, CGRect)? {
        return tileViewController.snapshotOverlayView(in: coordinateSpace)
    }
}
