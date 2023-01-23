//
//  Created by Anton Spivak
//

import Foundation
import JustonUI

// MARK: - FormCollectionViewSection

enum FormCollectionViewSection {
    case simple(models: [FormButtonsCollectionReusableView.Model])
}

// MARK: - FormCollectionViewItem

enum FormCollectionViewItem {
    case input(model: FormInputCollectionViewCell.Model)
    case text(model: FormTextCollectionViewCell.Model)
}

// MARK: - FormCollectionViewDataSource

class FormCollectionViewDataSource: CollectionViewDiffableDataSource<
    FormCollectionViewSection,
    FormCollectionViewItem
> {
    // MARK: Lifecycle

    override init(collectionView: UICollectionView) {
        super.init(collectionView: collectionView)

        collectionView.register(reusableCellClass: FormInputCollectionViewCell.self)
        collectionView.register(reusableCellClass: FormTextCollectionViewCell.self)

        collectionView
            .register(reusableSupplementaryViewClass: FormButtonsCollectionReusableView.self)
    }

    // MARK: Internal

    weak var formInputCellDelegate: FormInputCollectionViewCellDelegate?

    override func cell(
        with collectionView: UICollectionView,
        indexPath: IndexPath,
        item: FormCollectionViewItem
    ) -> UICollectionViewCell? {
        switch item {
        case let .input(model):
            let cell = collectionView.dequeue(
                reusableCellClass: FormInputCollectionViewCell.self,
                for: indexPath
            )
            cell.model = model
            cell.delegate = formInputCellDelegate
            return cell
        case let .text(model):
            let cell = collectionView.dequeue(
                reusableCellClass: FormTextCollectionViewCell.self,
                for: indexPath
            )
            cell.model = model
            return cell
        }
    }

    override func view(
        with collectionView: UICollectionView,
        elementKind: String,
        indexPath: IndexPath
    ) -> UICollectionReusableView? {
        guard let section = sectionIdentifier(forSectionIndex: indexPath.section)
        else {
            return nil
        }

        switch (section, elementKind) {
        case (.simple(let models), String(describing: FormButtonsCollectionReusableView.self)):
            let view = collectionView.dequeue(
                reusableSupplementaryViewClass: FormButtonsCollectionReusableView.self,
                for: indexPath
            )
            view.models = models
            return view
        default:
            return nil
        }
    }
}

// MARK: - FormCollectionViewSection + Hashable

extension FormCollectionViewSection: Hashable {
    func hash(into hasher: inout Hasher) {
        switch self {
        case .simple:
            hasher.combine("simple")
        }
    }
}

// MARK: - FormCollectionViewSection + Equatable

extension FormCollectionViewSection: Equatable {
    static func == (lhs: FormCollectionViewSection, rhs: FormCollectionViewSection) -> Bool {
        lhs.hashValue == rhs.hashValue
    }
}

// MARK: - FormCollectionViewItem + Hashable

extension FormCollectionViewItem: Hashable {
    func hash(into hasher: inout Hasher) {
        switch self {
        case let .input(model):
            hasher.combine(model.placeholder)
            hasher.combine(model.text ?? "")
        case let .text(model):
            hasher.combine(model.text)
        }
    }
}

// MARK: - FormCollectionViewItem + Equatable

extension FormCollectionViewItem: Equatable {
    static func == (lhs: FormCollectionViewItem, rhs: FormCollectionViewItem) -> Bool {
        lhs.hashValue == rhs.hashValue
    }
}
