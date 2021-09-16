
import UIKit
import UserNotifications

class AlarmVC: UIViewController{

//MARK:-Property
    private let sounds:[String] = [
        "どりゃあああああああああ","初やあ","今のセクター1000点","全軍突撃じゃあああ","じゃあオメエの言う普通ってなんだよ",
        "ひん","おいいくべえよ！","俺に感情はない","セピアに言って欲しい(Fullmetal Alchemist)","右ストレートでぶっとばす",
        "ジュンイチィィィ！！！","界王様","いいよぉ(ギアさん)","ダツラ戦勝ち筋","ダツラ戦負け筋","バックナックル",
        "キレたはいぷっちーん","フンッフンッフンッ","泥棒確保","泥棒擁護","セイー","何これ","ちん狼","俺の方が早かった(マインスイーパー)",
        "自己紹介(日中)","やってるー？","すばらしいことじゃない","あかんて！あかんて！","うっそおおおおおおお(坂田銀時)",
        "5,4,3,2,1 結果を表示します","たのしいいいいい！","パワー系シバチャンネル","びっくりした(DBD)","早起きじじい",
        "みゃこって手が汚ぇよな","するよなぁ","お前強すぎる","そにー","しようとする気持ちが必要"
    ]
    private let repeatTimeArray:[String] = ["300.0","600.0","900.0"]
    static let shared = AlarmVC()
    private var appDelegate = UIApplication.shared
    private var userDefaults = UserDefaults.standard
    private var timeArray:[AlarmTimeArray] = []
    private var index:Int!
    private let nextID:String = "showAlarmAdd"
    private let cellId = "AlarmTimeCell"
    
//MARK:-IBOutlet
    @IBOutlet weak var tableV: UITableView!{
        didSet{
            tableV.delegate = self
            tableV.dataSource = self
            //TableViewのエディットモードの設定(During Editingのみ可)
            tableV.allowsSelectionDuringEditing = true
            tableV.allowsSelection = false
            tableV.register(UINib(nibName: cellId, bundle: nil), forCellReuseIdentifier: cellId)
        }
    }
//MARK:-IBActionFunc
    @IBAction func addButton(_ sender: Any) {
        self.performSegue(withIdentifier: nextID, sender: nil)
    }
//MARK:-Func
    //To load Alarm information to timeArray
    func timeLoad(){
        if let timeArrayData = UserDefaults.standard.object(forKey: "timeArray") as? Data{
            if let getTimeArray = try! NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(timeArrayData) as? [AlarmTimeArray]{
                timeArray = getTimeArray
            }
        }
    }
    //To save timeArray to userDefaults
    func saveDate(){
        let timeArrayData = try! NSKeyedArchiver.archivedData(withRootObject: timeArray, requiringSecureCoding: false)
        UserDefaults.standard.set(timeArrayData,forKey: "timeArray")
        UserDefaults.standard.synchronize()
    }
    func getTime(date:Date) -> String{
        let f = DateFormatter()
        f.timeStyle = .short
        f.locale = Locale(identifier: "ja_JP")
        return f.string(from: date)
    }
    func getAlarm(from uuid:String, identifier:String){
        timeLoad()
        guard let alarm = timeArray.first(where: {$0.uuidString == uuid}) else{return}
        if alarm.week.isEmpty{
            alarm.onOff = false
        }
        saveDate()
        let center = UNUserNotificationCenter.current()
        center.removeAllDeliveredNotifications()
    }
//MARK:-ViewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        //EditButtonを追加する
        self.navigationItem.leftBarButtonItem = editButtonItem
        timeLoad()
        tableV.reloadData()
        NotificationCenter.default.addObserver(self, selector: #selector(self.methodOfReceivedNotification(notification:)), name: Notification.Name("NotificationIdentifier"), object: nil)
    }
    @objc func methodOfReceivedNotification(notification: Notification) {
        timeLoad()
        DispatchQueue.main.async {
            self.tableV.reloadData()
        }
    }
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        tableV.setEditing(editing, animated: animated)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == nextID{
            guard let vc:AlarmAddVC = segue.destination as? AlarmAddVC else {print("---notAlarmAddVC---"); return}
            vc.delegate = self
            //編集モードならdeleteを表示するBool
            vc.isEdit = tableV.isEditing
            if tableV.isEditing{
                vc.alarmTime = timeArray[index]
            }
        }else{
            print("---not nextID---")
        }
    }
    func weekDay(day:String) -> Int{
        let week = DateFormatter().weekdaySymbols!
        print(day)
        switch day {
        case week[0]:
            return 0
        case week[1]:
            return 1
        case week[2]:
            return 2
        case week[3]:
            return 3
        case week[4]:
            return 4
        case week[5]:
            return 5
        case week[6]:
            return 6
        default:
            return Int()
        }
    }
}
//MARK:-ExtensionUITableViewDelegate,Datasource
extension AlarmVC:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return timeArray.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableV.dequeueReusableCell(withIdentifier: cellId) as! AlarmTimeCell
        cell.timeLabel.text = getTime(date: timeArray[indexPath.row].date)
        cell.label.text = setCellLabel(index: indexPath.row)
        cell.sw.isOn =  timeArray[indexPath.row].onOff
        cell.sw.tag = indexPath.row
        cell.editingAccessoryType = .disclosureIndicator
        cell.delegate = self
        cell.backgroundColor = .clear
        if timeArray[indexPath.row].onOff{
            cell.label?.textColor = .white
            cell.timeLabel.textColor = .white
        }else{
            cell.label?.textColor = .lightGray
            cell.timeLabel.textColor = .lightGray
        }
        return cell
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete{
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [timeArray[indexPath.row].uuidString])
            timeArray.remove(at: indexPath.row)
            tableV.deleteRows(at: [indexPath], with: .fade)
            saveDate()
        }
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //画面遷移の準備
        print(tableView.isEditing)
        if tableV.isEditing == true{
            index = indexPath.row
            performSegue(withIdentifier:
                "showAlarmAdd", sender: nil)
        }
    }
    func setCellLabel(index:Int) -> String{
        if timeArray[index].repeatLabel == "Never"{
            return timeArray[index].label
        }else{
            return timeArray[index].label + "," + timeArray[index].repeatLabel
        }
    }
}
//MARK:-ExtensionAlarmAddDelegate
extension AlarmVC:AlarmAddDelegate{
    func AlarmAddVC(alarmAdd: AlarmAddVC, alarmTime: AlarmTimeArray) {
        if tableV.isEditing {
            timeArray[index] = alarmTime
        }else{
            timeArray.append(alarmTime)
        }
        timeArray.sort(){$0.date < $1.date}
        saveDate()
        self.setEditing(false, animated: false)
        tableV.reloadData()
    }
    func AlarmAddVC(alarmDelete: AlarmAddVC, alarmTime: AlarmTimeArray) {
        self.setEditing(false, animated: false)
        timeArray.remove(at: index)
        saveDate()
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [timeArray[index].uuidString])
    }
    func AlarmAddVC(alarmCancel: AlarmAddVC) {
        self.setEditing(false, animated: false)
    }
}
//MARK:-ExtensionAlarmtimeCellDelegate
extension AlarmVC:AlarmTimeCellDelegate{
    func AlarmTime(switchTappe: UITableViewCell, isOn: Bool, tag: Int) {
        timeArray[tag].onOff = isOn
        if timeArray[tag].onOff{
        
            let  Time =  timeArray[tag]
                removeAlarm(identifiers: Time.uuidString)
            let shortWeekday = DateFormatter().shortWeekdaySymbols!
            for i in shortWeekday{
                removeAlarm(identifiers: Time.uuidString+i)
            }
            if Time.week.isEmpty{
                setCategories(Time: tag)
                setNotificationC(day: "", repeats: Time.snooze,time: Time.date, Time: tag)

            }else{
                for i in Time.week{
                    setCategories(Time: tag)
                    setNotificationC(day: i, repeats: timeArray[tag].snooze,time: timeArray[tag].date, Time: tag)
                }
            }
        }else{
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [timeArray[tag].uuidString])
            let voice:String = "Snooze" + timeArray[tag].voice
            for i in repeatTimeArray{
                UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [voice+i])
            }
        }
        tableV.reloadData()
    }
    func setCategories(Time:Int){
        let snoozeAction = UNNotificationAction(identifier: timeArray[Time].voice, title: "Snooze 5 minutes", options: [])
        let noAction = UNNotificationAction(identifier: "stop \(timeArray[Time].voice)", title: "stop", options: [])
        
        var alarmCategory:UNNotificationCategory!
        //alarmTimeのsnoozeがtrueならアクションを追加する
        if timeArray[Time].snooze {
            alarmCategory = UNNotificationCategory(identifier: "alarmCategory", actions: [snoozeAction,noAction], intentIdentifiers: [], options: [])
        }else{
            alarmCategory = UNNotificationCategory(identifier: "alarmCategory", actions: [], intentIdentifiers: [], options: [])
        }
        UNUserNotificationCenter.current().setNotificationCategories([alarmCategory])
    }
    func setNotificationC(day:String, repeats:Bool, time:Date, Time:Int){
        let content = UNMutableNotificationContent()
        content.title = timeArray[Time].label
        //音声ファイルを挿入
        let voiceSound = timeArray[Time].voice+"r.mp3"
        let sound:UNNotificationSound = UNNotificationSound.criticalSoundNamed(UNNotificationSoundName(rawValue: voiceSound))
        content.sound = sound
        content.categoryIdentifier = "alarmCategory"
        var dateComponents = DateComponents()
        
        if !day.isEmpty{
            dateComponents.weekday = weekDay(day: day)
        }
        dateComponents.hour = Calendar.current.component(.hour, from: time)
        dateComponents.minute = Calendar.current.component(.minute, from: time)
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: repeats)
        let request = UNNotificationRequest(identifier: timeArray[Time].uuidString+day, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request){ (error) in
            if let error = error {
                print(error.localizedDescription)
            }
        }
    }
    func removeAlarm(identifiers:String){
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [identifiers])
    }
}

