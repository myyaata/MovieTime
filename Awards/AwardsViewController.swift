import UIKit

nonisolated enum AwardSection {
    case main
}

final class AwardsViewController: UIViewController {
    
    @IBOutlet weak var awardName: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    
    private var dataSource: UICollectionViewDiffableDataSource<AwardSection, Award>!
    private var centeredIndex: Int = -1
    private var didCenterFirst = false
    
    private lazy var awardSubtitle: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .subheadline)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private var awards: [Award] {
        AwardsStore.shared.allAwards
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        applySnapshot()
        centerOnLastUnlocked()       // наводимся на последнюю награду при каждом показе
    }

    private func centerOnLastUnlocked() {
        guard !awards.isEmpty else { return }
        let targetIndex = lastUnlockedIndex() ?? 0

        // ждём, пока коллекция разложится, иначе скролл не сработает
        DispatchQueue.main.async {
            self.collectionView.scrollToItem(
                at: IndexPath(item: targetIndex, section: 0),
                at: .centeredHorizontally,
                animated: false)
        }
    }

    private func lastUnlockedIndex() -> Int? {
        guard let id = AwardsStore.shared.lastUnlockedID else { return nil }
        return awards.firstIndex(where: { $0.id == id })
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSubtitle()
        collectionView.collectionViewLayout = makeLayout()
        collectionView.backgroundColor = .clear
        configureDataSource()
        applySnapshot()
    }
    
    private func setupSubtitle() {
        view.addSubview(awardSubtitle)
        NSLayoutConstraint.activate([
            awardSubtitle.topAnchor.constraint(equalTo: awardName.bottomAnchor, constant: 8),
            awardSubtitle.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            awardSubtitle.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16)
        ])
    }
    
    private func makeLayout() -> UICollectionViewLayout {
        UICollectionViewCompositionalLayout { [weak self] _, environment in
 
            let item = NSCollectionLayoutItem(layoutSize: .init(
                widthDimension: .fractionalWidth(1),
                heightDimension: .fractionalHeight(1)))
 
            let groupWidth = environment.container.contentSize.width * 0.5
            let group = NSCollectionLayoutGroup.horizontal(
                layoutSize: .init(widthDimension: .absolute(groupWidth),
                                  heightDimension: .fractionalHeight(1)),
                subitems: [item])
 
            let section = NSCollectionLayoutSection(group: group)
            section.interGroupSpacing = 0
            section.orthogonalScrollingBehavior = .groupPagingCentered
 
            section.visibleItemsInvalidationHandler = { [weak self] items, offset, env in
                guard let self else { return }
                let containerWidth = env.container.contentSize.width
                let centerX = offset.x + containerWidth / 2
                let maxDistance = containerWidth / 2
 
                var bestIndex = -1
                var bestRatio: CGFloat = -1
 
                for item in items {
                    let distance = abs(item.center.x - centerX)
                    let ratio = max(0, 1 - distance / maxDistance)
 
                    if let cell = self.collectionView.cellForItem(at: item.indexPath) as? AwardCell {
                        cell.updateAppearance(ratio: ratio)
                    }
                    if ratio > bestRatio {
                        bestRatio = ratio
                        bestIndex = item.indexPath.item
                    }
                }
                self.updateTitle(forCenteredItemAt: bestIndex)
            }
 
            return section
        }
    }
    
    private func updateTitle(forCenteredItemAt index: Int) {
        guard index >= 0, index < awards.count, index != centeredIndex else { return }
        centeredIndex = index
        let award = awards[index]
        awardName.text = award.title
        awardSubtitle.text = subtitle(for: award)
    }
    
    private func subtitle(for award: Award) -> String {
        AwardsStore.shared.isUnlocked(id: award.id) ? "Получено!" : award.description
    }
    
    private func configureDataSource() {
        dataSource = UICollectionViewDiffableDataSource<AwardSection, Award>(collectionView: collectionView) { collectionView, indexPath, award in
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: AwardCell.reuseIdentifier,
                for: indexPath) as! AwardCell
            let unlocked = AwardsStore.shared.isUnlocked(id: award.id)

            cell.configure(with: award, isUnlocked: unlocked)
            return cell
        }
    }
    
    private func applySnapshot() {
        var snapshot = dataSource.snapshot()

        if snapshot.sectionIdentifiers.contains(.main) {
            // раздел уже есть → просто обновляем ячейки (перерисовка состояния "Получено!")
            snapshot.reconfigureItems(awards)
        } else {
            // первый раз → создаём раздел и кладём награды
            snapshot.appendSections([.main])
            snapshot.appendItems(awards)
        }

        dataSource.apply(snapshot, animatingDifferences: false)

        centeredIndex = -1
        if let first = awards.first {
            awardName.text = first.title
            awardSubtitle.text = subtitle(for: first)
        } else {
            awardName.text = "Нет наград"
            awardSubtitle.text = nil
        }
    }
}
