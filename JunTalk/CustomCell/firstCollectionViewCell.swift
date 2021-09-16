import UIKit

class firstCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var titleNameLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var backImageV: UIImageView!
    @IBOutlet weak var downloadButton: UIButton!{
        didSet{
            downloadButton.setImage(UIImage(named: "downloadIcon"), for: .normal)
        }
    }
    var delegate:CustomCellDelgate!
    
    @IBAction func downloadSounds(_ sender: Any) {
        delegate.downloadSounds(index: self.downloadButton.tag)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        backImageV.image = UIImage(named: "backgroundPurple")
      
    }
}
