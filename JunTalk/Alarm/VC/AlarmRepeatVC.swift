import UIKit

protocol AlarmRepeatVCDelegate{
    func AlarmRepeatVC(addRepeat:AlarmRepeatVC,week:[String])
}

class AlarmRepeatVC: UIViewController, UITableViewDelegate, UITableViewDataSource{
    
    @IBOutlet weak var tableV: UITableView!
    
    var week:[String] = []
    var shortWeek = DateFormatter().shortWeekdaySymbols
    var selectDay:[String] = []
    var delegate:AlarmRepeatVCDelegate!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        week = DateFormatter().weekdaySymbols!
        self.tableV.delegate = self
        self.tableV.dataSource = self
        
    }
    override func viewWillDisappear(_ animated: Bool) {
        //ビューが閉じる前に呼ばれるライフサイクル
        delegate.AlarmRepeatVC(addRepeat: self, week: sortWeek(selectDays: selectDay))
    }
    
    
    func sortWeek(selectDays:[String]) -> [String]{
        let week = DateFormatter().weekdaySymbols!
        var dayDictionary:[String:Int] = [:]
        for i in 0...6{
            dayDictionary[week[i]] = i
        }
        var daysOfWeek: [String] = selectDays
        daysOfWeek.sort { dayDictionary[$0] ?? 7 < dayDictionary[$1] ?? 7}
        return daysOfWeek
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return week.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:UITableViewCell = UITableViewCell()
        cell.backgroundColor = UIColor(red: 33, green: 33, blue: 33, alpha: 0)
        cell.textLabel?.textColor = .white
        cell.textLabel?.text = "Every" + week[indexPath.row]
        cell.selectionStyle = .none
        
        for i in selectDay{
            if week[indexPath.row] == i{
                cell.accessoryType = .checkmark
                break
            }else{
                cell.accessoryType = .none
            }
        }
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableV.cellForRow(at: indexPath)

        if cell?.accessoryType == UITableViewCell.AccessoryType.none{
            //チェックマークを入れる
            cell?.accessoryType = .checkmark
            selectDay.append(week[indexPath.row])
        }else{
            //チェックマークを外す
            cell?.accessoryType = .none
            selectDay = selectDay.filter { $0 != week[indexPath.row] }
        }
    }
}

