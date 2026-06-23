import UIKit

nonisolated enum MyMoviesSection {
    case main
}

final class AddedFilmsController: UIViewController {
    
    // MARK: - Private Properties
    
    private lazy var collectionView: UICollectionView = {
        UICollectionView(frame: .zero, collectionViewLayout: makeLayout())
    }()
    private var dataSource: UICollectionViewDiffableDataSource<MyMoviesSection, SavedMovie>!
    
    // MARK: - ViewController LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupCollectionView()
        configureDataSource()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        applySnapshot()
    }
    
    // MARK: - Private Methods
    
    private func setupCollectionView() {
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: makeLayout())
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(collectionView)
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func makeLayout() -> UICollectionViewLayout {
        var config = UICollectionLayoutListConfiguration(appearance: .plain) //объект конфигурации списка
        config.trailingSwipeActionsConfigurationProvider = { [weak self] indexPath in
            let delete = UIContextualAction(style: .destructive, title: "Удалить") { _, _, done in
                MyMoviesStore.shared.remove(at: indexPath.item)
                self?.applySnapshot()
                done(true)
            }
            delete.image = UIImage(systemName: "trash")
            return UISwipeActionsConfiguration(actions: [delete])
        }
        return UICollectionViewCompositionalLayout.list(using: config)
    }
    
    private func configureDataSource() {
        let registration = UICollectionView.CellRegistration<MyMovieCell, SavedMovie> { cell, _, movie in
            cell.configure(with: movie)
            cell.onRatingChanged = { rating in
                MyMoviesStore.shared.setRating(rating, forID: movie.imdbID)
            }
        }
        
        dataSource = UICollectionViewDiffableDataSource<MyMoviesSection, SavedMovie>(collectionView: collectionView) { collectionView, indexPath, movie in
            collectionView.dequeueConfiguredReusableCell(
                using: registration,
                for: indexPath,
                item: movie)
        }
    }
    
    private func applySnapshot() {
        var snapshot = NSDiffableDataSourceSnapshot<MyMoviesSection, SavedMovie>()
        snapshot.appendSections([.main])
        snapshot.appendItems(MyMoviesStore.shared.movies)
        dataSource.apply(snapshot, animatingDifferences: true)
    }
}


