import UIKit
import UserNotifications

protocol AlarmTimeCellDelegate {
    func AlarmTime(switchTappe:UITableViewCell,isOn:Bool,tag:Int)
}

class AlarmTimeCell: UITableViewCell {
    

    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var sw: UISwitch!
    var delegate:AlarmTimeCellDelegate!
    
    @IBAction func swAction(_ sender: UISwitch) {
        delegate.AlarmTime(switchTappe: self, isOn: sw.isOn, tag: sw.tag)
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

