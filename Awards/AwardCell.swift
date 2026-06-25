import UIKit

final class AwardCell: UICollectionViewCell {
    
    static let reuseIdentifier = "AwardCell"
    
    @IBOutlet weak var awardImageView: UIImageView!
    @IBOutlet weak var circleView: UIView!
    @IBOutlet weak var numberLabel: UILabel!
    
    private let accentColor = UIColor.systemYellow
    private let dimColor = UIColor.secondaryLabel
    private let lockImageView = UIImageView()
    private var isUnlocked = true
    
    override func awakeFromNib() {
        super.awakeFromNib()
        circleView.layer.borderWidth = 2
        circleView.layer.borderColor = dimColor.cgColor
        circleView.clipsToBounds = true
        
        lockImageView.image = UIImage(systemName: "lock.fill")
        lockImageView.tintColor = .secondaryLabel
        lockImageView.contentMode = .scaleAspectFit
        lockImageView.translatesAutoresizingMaskIntoConstraints = false
        lockImageView.isHidden = true
        circleView.addSubview(lockImageView)
        NSLayoutConstraint.activate([
            lockImageView.centerXAnchor.constraint(equalTo: circleView.centerXAnchor),
            lockImageView.centerYAnchor.constraint(equalTo: circleView.centerYAnchor),
            lockImageView.widthAnchor.constraint(equalToConstant: 18),
            lockImageView.heightAnchor.constraint(equalToConstant: 18)
        ])
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        circleView.layer.cornerRadius = circleView.bounds.width / 2
    }
    
    func configure(with award: Award, isUnlocked: Bool) {
        self.isUnlocked = isUnlocked

        awardImageView.image = UIImage(named: award.imageName)
        numberLabel.text = award.number
        lockImageView.isHidden = isUnlocked
        numberLabel.isHidden = !isUnlocked
        applyLockedStyle()
    }
    
    func updateAppearance(ratio: CGFloat) {
        let r = max(0, min(1, ratio))

        if isUnlocked {
            awardImageView.alpha = 0.4 + 0.6 * r
            let scale = 0.85 + 0.15 * r
            awardImageView.transform = CGAffineTransform(scaleX: scale, y: scale)
            circleView.backgroundColor = r > 0.5 ? accentColor : .systemBackground
            circleView.layer.borderColor = (r > 0.5 ? accentColor : dimColor).cgColor
            numberLabel.textColor = r > 0.5 ? .black : dimColor
        } else {
            awardImageView.alpha = 0.35
            awardImageView.transform = CGAffineTransform(scaleX: 0.85, y: 0.85)
            circleView.backgroundColor = .systemBackground
            circleView.layer.borderColor = dimColor.cgColor
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        awardImageView.transform = .identity
        awardImageView.alpha = 1
        isUnlocked = true
        lockImageView.isHidden = true
        numberLabel.isHidden = false
    }
    
    private func applyLockedStyle() {
        guard !isUnlocked else {
            awardImageView.alpha = 1
            awardImageView.tintColor = nil
            return
        }
        if let image = awardImageView.image {
            awardImageView.image = image.withRenderingMode(.alwaysTemplate)
            awardImageView.tintColor = .secondaryLabel
        }
        awardImageView.alpha = 0.35
    }
}
