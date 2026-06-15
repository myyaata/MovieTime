import UIKit

final class AwardCell: UICollectionViewCell {
    
    static let reuseIdentifier = "AwardCell"
    
    @IBOutlet weak var awardImageView: UIImageView!
    @IBOutlet weak var circleView: UIView!
    @IBOutlet weak var numberLabel: UILabel!
    
    private let accentColor = UIColor.systemYellow
    private let dimColor = UIColor.secondaryLabel
    
    override func awakeFromNib() {
        super.awakeFromNib()
        circleView.layer.borderWidth = 2
        circleView.layer.borderColor = dimColor.cgColor
        circleView.clipsToBounds = true
    }
    
    //Метод вызывается каждый раз, когда меняются размеры или расположение вью и его сабвью
    override func layoutSubviews() {
        super.layoutSubviews()
        circleView.layer.cornerRadius = circleView.bounds.width / 2
    }
    
    //Наполнение ячейки данными конкретной награды
    func configure(with award: Award) {
        awardImageView.image = UIImage(named: award.imageName)
        numberLabel.text = award.number
    }
    
    func updateAppearance(ratio: CGFloat) {
            let r = max(0, min(1, ratio))
            awardImageView.alpha = 0.4 + 0.6 * r
            let scale = 0.85 + 0.15 * r
            awardImageView.transform = CGAffineTransform(scaleX: scale, y: scale)
            circleView.backgroundColor = r > 0.5 ? accentColor : .systemBackground
            circleView.layer.borderColor = (r > 0.5 ? accentColor : dimColor).cgColor
            numberLabel.textColor = r > 0.5 ? .black : dimColor
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        awardImageView.transform = .identity // возвращаем обычный размер
        awardImageView.alpha = 1 // возвращаем полную видимость
    }
}
