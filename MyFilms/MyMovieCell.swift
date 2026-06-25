import UIKit

class MyMovieCell: UICollectionViewCell {
    
    // MARK: - Public Properties
    
    var onRatingChanged: ((Int) -> Void)?
    
    // MARK: - Private Properties
    
    private let posterView = UIImageView()
    private let titleLabel = UILabel()
    private let starsStack = UIStackView()
    private var starButtons: [UIButton] = []
    private var imageTask: URLSessionDataTask?
    private var currentRating = 0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    // MARK: - Public Methods
    
    func configure(with movie: SavedMovie) {
        titleLabel.text = movie.title
        currentRating = movie.rating
        updateStars()
        posterView.image = nil
        guard let s = movie.posterURLString, let url = URL(string: s) else { return }
        imageTask = URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
            guard let data, let img = UIImage(data: data) else { return }
            DispatchQueue.main.async { self?.posterView.image = img }
        }
        imageTask?.resume()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageTask?.cancel()
        posterView.image = nil
        onRatingChanged = nil
    }
    
    // MARK: - Private Methods
    
    private func setup() {
        posterView.contentMode = .scaleAspectFill
        posterView.clipsToBounds = true
        posterView.layer.cornerRadius = 8
        posterView.translatesAutoresizingMaskIntoConstraints = false
        
        titleLabel.font = .preferredFont(forTextStyle: .headline)
        titleLabel.numberOfLines = 2
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        starsStack.axis = .horizontal
        starsStack.spacing = 4
        starsStack.translatesAutoresizingMaskIntoConstraints = false
        for i in 1...5 {
            let b = UIButton(type: .system)
            b.tag = i
            b.tintColor = .systemYellow
            b.setImage(UIImage(systemName: "star"), for: .normal)
            b.addTarget(self, action: #selector(starTapped(_:)), for: .touchUpInside)
            starButtons.append(b)
            starsStack.addArrangedSubview(b)
        }
        
        contentView.addSubview(posterView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(starsStack)
        
        NSLayoutConstraint.activate([
            posterView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            posterView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            posterView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12),
            posterView.widthAnchor.constraint(equalToConstant: 70),
            posterView.heightAnchor.constraint(equalToConstant: 100),
 
            titleLabel.topAnchor.constraint(equalTo: posterView.topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: posterView.trailingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
 
            starsStack.leadingAnchor.constraint(equalTo: posterView.trailingAnchor, constant: 12),
            starsStack.bottomAnchor.constraint(equalTo: posterView.bottomAnchor)
        ])
    }
    
    private func updateStars() {
        for button in starButtons {
            let filled = button.tag <= currentRating
            button.setImage(UIImage(systemName: filled ? "star.fill" : "star"), for: .normal)
        }
    }
    
    @objc private func starTapped(_ sender: UIButton) {
        currentRating = sender.tag
        updateStars()
        onRatingChanged?(currentRating)
    }
}
