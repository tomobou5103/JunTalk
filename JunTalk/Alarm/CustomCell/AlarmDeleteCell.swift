import UIKit
protocol AlarmDeleteCellDelegate{
    func alarmDeleteCell(delete: UITableViewCell)
}

class AlarmDeleteCell:UITableViewCell{
    var delegate:AlarmDeleteCellDelegate!
    @IBAction func deleteButton(_ sender: Any) {
        delegate.alarmDeleteCell(delete: self)
    }
}

