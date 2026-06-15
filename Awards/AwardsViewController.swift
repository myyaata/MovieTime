import UIKit

nonisolated enum AwardSection {
    case main
}

final class AwardsViewController: UIViewController {
    
    @IBOutlet weak var awardName: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    
    private var dataSource: UICollectionViewDiffableDataSource<AwardSection, Award>!
    private var centeredIndex: Int = -1
    
    private let awards: [Award] = [
        Award(id: 0, title: "Первый шаг",    imageName: "award_1", number: "1"),
        Award(id: 1, title: "Киноман",       imageName: "award_2", number: "2"),
        Award(id: 2, title: "Знаток жанров", imageName: "award_3", number: "3"),
        Award(id: 3, title: "Марафонец",     imageName: "award_4", number: "4"),
        Award(id: 4, title: "Коллекционер",  imageName: "award_5", number: "5")
    ]
    
    private var didCenterFirst = false

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        guard !didCenterFirst, !awards.isEmpty else { return }
        didCenterFirst = true
        collectionView.scrollToItem(at: IndexPath(item: 0, section: 0),
                                    at: .centeredHorizontally, animated: false)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.collectionViewLayout = makeLayout()
        collectionView.backgroundColor = .clear
        configureDataSource()
        applySnapshot()
    }
    
    private func makeLayout() -> UICollectionViewLayout {
        UICollectionViewCompositionalLayout { [weak self] _, environment in
 
            let item = NSCollectionLayoutItem(layoutSize: .init(
                widthDimension: .fractionalWidth(1),
                heightDimension: .fractionalHeight(1)))
 
            // Ширина ячейки. Кружки будут стоять на таком расстоянии друг от друга.
            let groupWidth = environment.container.contentSize.width * 0.5
            let group = NSCollectionLayoutGroup.horizontal(
                layoutSize: .init(widthDimension: .absolute(groupWidth),
                                  heightDimension: .fractionalHeight(1)),
                subitems: [item])
 
            let section = NSCollectionLayoutSection(group: group)
            // 0 между группами → линии соседних ячеек стыкуются в сплошную нить
            section.interGroupSpacing = 0
            section.orthogonalScrollingBehavior = .groupPagingCentered
 
            //функция, которая срабатывает постоянно, на каждый чуть-чуть сдвиг при прокрутке
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
 
                    // Тянемся к самой ячейке и красим её подвиды (не весь item!)
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
        awardName.text = awards[index].title
    }
    
    private func configureDataSource() {
        dataSource = UICollectionViewDiffableDataSource<AwardSection, Award>(collectionView: collectionView) { collectionView, indexPath, award in
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: AwardCell.reuseIdentifier,
                for: indexPath) as! AwardCell
            cell.configure(with: award)
            return cell
        }
    }
    
    private func applySnapshot() {
        var snapShot = NSDiffableDataSourceSnapshot<AwardSection, Award>() //пустой снимок данных
        snapShot.appendSections([.main])
        snapShot.appendItems(awards)
        dataSource.apply(snapShot, animatingDifferences: false)
        awardName.text = awards.first?.title ?? "Нет наград"
    }
}

