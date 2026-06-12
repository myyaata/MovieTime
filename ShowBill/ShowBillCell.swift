import UIKit

final class ShowBillCell: UITableViewCell {
    
    @IBOutlet weak var posterPick: UIImageView!
    
    @IBOutlet weak var filmName: UILabel!
    
    static let reuseIdentifier = "ShowBillCell"
    
    private var imageTask: URLSessionDataTask?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        posterPick.layer.cornerRadius = 12
        posterPick.clipsToBounds = true
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageTask?.cancel()
        imageTask = nil
        posterPick.image = nil
    }
    
    func configure(with movie: Movie) {
        filmName.text = movie.title
        
        guard let url = movie.posterURL else {
            posterPick.image = nil
            return
        }
        
        imageTask = URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
            guard let data, let image = UIImage(data: data) else { return }
            DispatchQueue.main.async {
                self?.posterPick.image = image
            }
        }
        imageTask?.resume()
    }
}

