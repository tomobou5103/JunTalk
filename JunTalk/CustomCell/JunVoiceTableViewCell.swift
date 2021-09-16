import UIKit

class JunVoiceTableViewCell: UITableViewCell {

    @IBOutlet weak var contentV: UIView!
    @IBOutlet weak var titleTextLabel: UILabel!
    @IBOutlet weak var unkImageV: UIImageView!
    @IBOutlet weak var imageV: UIImageView!
    override func prepareForReuse() {
        self.titleTextLabel.text = ""
        self.unkImageV.alpha = 1
    }
}
