//
//  Created by Anton Spivak
//

import JustonCORE
import JustonUI
import UIKit

// MARK: - C42CollectionViewController

class C42CollectionViewController: C42ConcreteViewController {
    // MARK: Lifecycle

    init(
        title: String,
        sections: [CollectionSection],
        isModalInPresentation: Bool = false,
        isBackActionAvailable: Bool = true,
        isNavigationBarHidden: Bool = false
    ) {
        self.sections = sections
        super.init(
            title: title,
            isModalInPresentation: isModalInPresentation,
            isBackActionAvailable: isBackActionAvailable,
            isNavigationBarHidden: isNavigationBarHidden
        )
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Internal

    @MainActor
    struct CollectionSection {
        let section: C42Section
        let items: [C42Item]
    }

    let sections: [CollectionSection]
    let feedbackGenerator = UIImpactFeedbackGenerator(style: .rigid)

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.backButtonTitle = ""
        navigationItem.setHidesBackButton(!isBackActionAvailable, animated: true)

        collectionViewLayout.delegate = self

        collectionView.keyboardDismissMode = .onDrag
        collectionView.delegate = self
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .jus_backgroundPrimary
        view.addSubview(collectionView)
        collectionView.pinned(edges: view)

        var snapshot = NSDiffableDataSourceSnapshot<C42Section, C42Item>()
        sections.forEach({ sectionViewModel in
            snapshot.appendSection(
                sectionViewModel.section,
                items: sectionViewModel.items
            )
        })

        let animatingDifferences = view.window != nil && !collectionViewDataSource.snapshot()
            .itemIdentifiers.isEmpty
        collectionViewDataSource.apply(
            snapshot,
            animatingDifferences: animatingDifferences
        )
    }

    // MARK: Private

    private lazy var collectionViewDataSource = C42CollectionViewDataSource(
        collectionView: collectionView
    )

    private lazy var collectionViewLayout = C42CollectionViewCompositionalLayout()
    private lazy var collectionView = DiffableCollectionView(
        frame: .zero,
        collectionViewLayout: collectionViewLayout
    )

    private var task: Task<Void, Never>?

    private var locked: Bool = false {
        didSet {
            view.isUserInteractionEnabled = locked
        }
    }
}

// MARK: UICollectionViewDelegate

extension C42CollectionViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let itemIdentifier = collectionViewDataSource.itemIdentifier(for: indexPath)
        else {
            return
        }

        if let cell = collectionView.cellForItem(at: indexPath) as? C42ButtonCell,
           case let C42Item.asynchronousButton(_, _, action) = itemIdentifier
        {
            cell.startAsynchronousOperation({ @MainActor in
                do {
                    try await action(self)
                } catch {
                    self.present(error)
                }
            })
        } else {
            switch itemIdentifier {
            case let .settingsButton(_, _, action), let .synchronousButton(_, _, action):
                do {
                    try action(self)
                } catch {
                    present(error)
                }
            case let .asynchronousButton(_, _, action):
                view.isUserInteractionEnabled = true
                task?.cancel()
                task = Task {
                    do {
                        try await action(self)
                    } catch {
                        present(error)
                    }

                    view.isUserInteractionEnabled = true
                    task = nil
                }
            default:
                break
            }
        }
    }
}

// MARK: C42CollectionViewCompositionalLayoutDelegate

extension C42CollectionViewController: C42CollectionViewCompositionalLayoutDelegate {
    func collectionViewLayout(
        _ layout: C42CollectionViewCompositionalLayout,
        sectionIdentifierFor sectionIndex: Int
    ) -> C42Section? {
        collectionViewDataSource.sectionIdentifier(forSectionIndex: sectionIndex)
    }

    func collectionViewLayout(
        _ layout: C42CollectionViewCompositionalLayout,
        numberOfItemsInSection sectionIndex: Int
    ) -> Int {
        collectionViewDataSource.collectionView(
            collectionView,
            numberOfItemsInSection: sectionIndex
        )
    }
}
