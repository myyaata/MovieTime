import UIKit

final class MovieDetailsController: UIViewController {
    
    // MARK: - Public Properties
    var movie: Movie?

    // MARK: - Private Properties
    
    private let loader = MoviesLoader()

    private lazy var movieImage: UIImageView = {
        let image = UIImageView()
        image.contentMode = .scaleAspectFill
        image.layer.cornerRadius = 8
        image.clipsToBounds = true
        return image
    }()

    private lazy var movieTitle = makeLabel(style: .largeTitle)
    private lazy var descriptionLabel = makeLabel(style: .body)
    private lazy var directorLabel = makeLabel(style: .subheadline)
    private lazy var actorsLabel = makeLabel(style: .subheadline)
    private lazy var ratingLabel = makeLabel(style: .title3)
    
    private lazy var watchButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Буду смотреть", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .preferredFont(forTextStyle: .headline)
        button.backgroundColor = .purple
        button.layer.cornerRadius = 16
        button.clipsToBounds = true
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(watchTapped), for: .touchUpInside)
        return button
    }()
    
    // TODO: - UIViewController Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.accessibilityIdentifier = "movieDetailsView"

        setupLayout()
        guard let movie else { return }
        movieTitle.text = movie.title
        loadDetails(for: movie.imdbID)
    }
    
    // MARK: - Public Methods
    public func configure(image: UIImage?) {
        movieImage.image = image
    }

    // MARK: - Private Methods
    private func loadDetails(for imbdID: String) {
        loader.loadDetail(imdbID: imbdID) { [weak self] result in
            DispatchQueue.main.async {
                guard case .success(let d) = result else { return }
                self?.movieTitle.text = d.title
                self?.descriptionLabel.text = d.plot
                self?.directorLabel.text = "Режиссёр: \(d.director)"
                self?.actorsLabel.text = "В ролях: \(d.actors)"
                self?.ratingLabel.text = "Рейтинг: \(d.imdbRating)"
                self?.loadPoster(from: d.posterURL)
            }
        }
    }
    
    private func loadPoster(from url: URL?) {
        guard let url else { return }
        URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
            guard let data, let image = UIImage(data: data) else { return }
            DispatchQueue.main.async { self?.movieImage.image = image }
        }.resume()
    }
    
    private func makeLabel(style: UIFont.TextStyle) -> UILabel {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: style)
        label.numberOfLines = 0
        return label
    }
    
    private func setupLayout() {
        view.backgroundColor = .systemBackground
        
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        
        let stack = UIStackView(arrangedSubviews: [
            movieImage, movieTitle, ratingLabel, directorLabel, actorsLabel, descriptionLabel, watchButton
        ])
        stack.axis = .vertical
        stack.spacing = 12
        stack.alignment = .fill
        stack.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(stack)

        movieImage.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            stack.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: 16),
            stack.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor, constant: -16),
            stack.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: -16),
            
            stack.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor, constant: -32),
            
            movieImage.heightAnchor.constraint(equalToConstant: 280),
            movieImage.widthAnchor.constraint(equalTo: movieImage.heightAnchor, multiplier: 2.0/3.0),
            movieImage.centerXAnchor.constraint(equalTo: stack.centerXAnchor),
            
            watchButton.heightAnchor.constraint(equalToConstant: 52)
        ])
    }
    
    @objc private func watchTapped() {
        //TO-DO
    }
}
