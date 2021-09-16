import UIKit

protocol AlarmSnoozeCellDelegate {
    func alarmSnoozeCell(switchOn:AlarmSnoozeCell,On:Bool)
}

class AlarmSnoozeCell:UITableViewCell{
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var snoozeSwitch: UISwitch!
    var delegate:AlarmSnoozeCellDelegate!
    @IBAction func switchChanged(_ sender: UISwitch) {
        delegate.alarmSnoozeCell(switchOn: self, On: sender.isOn)
    }
}

