import UIKit
import UserNotifications

protocol AlarmAddDelegate {
    func AlarmAddVC(alarmAdd:AlarmAddVC,alarmTime:AlarmTimeArray)
    func AlarmAddVC(alarmDelete:AlarmAddVC,alarmTime:AlarmTimeArray)
    func AlarmAddVC(alarmCancel:AlarmAddVC)
}

class AlarmAddVC: UIViewController, UITableViewDelegate, UITableViewDataSource{
    let sounds:[String] = [
        "どりゃあ","初やあ","1000点","全軍突撃","オメエの言う普通",
        "ひん","いくべえよ","俺に感情はない","ハガレン","右ストレート",
        "ジュンイチ","界王様","いいよぉ","ダツラ勝ち","ダツラ負け","バックナックル",
        "ぷっちーん","フンッフンッ","泥棒確保","泥棒擁護","セイー","何これ","ちん狼","俺の方が早かった",
        "自己紹介","やってるー？","すばらしい","あかんて","うっそおお",
        "5,4,3,2,1","たのしいい！","シバチャンネル","びっくりした","早起きじじい",
        "みゃこ","するよなぁ","お前強すぎる","そにー","しようとする気持ち"
    ]
    var alarmTime:AlarmTimeArray = AlarmTimeArray()
    var isEdit:Bool = false
    var titleText = ["リピート","ラベル","ボイス"]
    var delegate:AlarmAddDelegate!
    
    func setNum(str:String)->Int{
        let arr = str.components(separatedBy: "k")
        return Int(arr[1])!
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 4
        case 1:
            return 1
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch indexPath.section {
        case 0:
            switch indexPath.row {
            case 0:
                let cell = tableView.dequeueReusableCell(withIdentifier: "AlarmAddCell") as! AlarmAddCell
                cell.titleLabel.text = titleText[indexPath.row]
                cell.subTitleLabel.text = alarmTime.repeatLabel
                
                return cell
            case 1:
                let cell = tableView.dequeueReusableCell(withIdentifier: "AlarmAddCell") as! AlarmAddCell
                cell.titleLabel.text = titleText[indexPath.row]
                cell.subTitleLabel.text = alarmTime.label
                return cell
            case 2:
                let cell = tableView.dequeueReusableCell(withIdentifier: "AlarmAddCell") as! AlarmAddCell
                cell.titleLabel.text = titleText[indexPath.row]
                let selectVoiceNum = setNum(str: alarmTime.voice)
                cell.subTitleLabel.text = sounds[selectVoiceNum-1]
                return cell
            case 3:
                let cell = tableView.dequeueReusableCell(withIdentifier: "AlarmSnoozeCell") as! AlarmSnoozeCell
                cell.titleLabel.text = "スヌーズ"
                cell.delegate = self
                cell.snoozeSwitch.isOn = alarmTime.snooze
                return cell
            default:
                break
            }
            break
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "AlarmDeleteCell") as! AlarmDeleteCell
            cell.delegate = self
            return cell
        default:
            break
        }
        return UITableViewCell()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return isEdit ? 2:1
    }
    
    //cellの登録
    func registerCell(cellName:String){
        tableView.register(UINib(nibName: cellName, bundle: nil), forCellReuseIdentifier: cellName)
    }
    //曜日設定
    func weekDay(day:String) -> Int{
        let week = DateFormatter().weekdaySymbols!
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
    

    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var tableView: UITableView!
    

    
    override func viewDidLoad() {
        super.viewDidLoad()

        datePicker.datePickerMode = .time
        datePicker.preferredDatePickerStyle = .wheels
        datePicker.locale = Locale(identifier: "jp_JP")
        datePicker.date = alarmTime.date
        datePicker.backgroundColor = .black
        datePicker.setValue(UIColor.white, forKey: "textColor")
        datePicker.setValue(false, forKey: "highlightsToday")
        tableView.register(UINib(nibName: "AlarmAddCell", bundle: nil), forCellReuseIdentifier: "AlarmAddCell")
        tableView.register(UINib(nibName: "AlarmSnoozeCell", bundle: nil), forCellReuseIdentifier: "AlarmSnoozeCell")
        tableView.register(UINib(nibName: "AlarmDeleteCell", bundle: nil), forCellReuseIdentifier: "AlarmDeleteCell")
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    @IBAction func saveButton(_ sender: Any) {
        
        //アラートを設定する関数
        alarmSet()
        print("addNotification")
        //仮datepicker
        delegate.AlarmAddVC(alarmAdd: self, alarmTime: alarmTime)
        performSegue(withIdentifier: "backView", sender: nil)
    }
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        if viewController is AlarmVC {
            delegate.AlarmAddVC(alarmCancel: self)
        }
    }
    
    func setCategories(){
        let snoozeAction = UNNotificationAction(identifier: alarmTime.voice, title: "Snooze 5 minutes", options: [])
        let noAction = UNNotificationAction(identifier: "stop \(alarmTime.voice)", title: "stop", options: [])
        
        var alarmCategory:UNNotificationCategory!
        //alarmTimeのsnoozeがtrueならアクションを追加する
        if alarmTime.snooze {
            alarmCategory = UNNotificationCategory(identifier: "alarmCategory", actions: [snoozeAction,noAction], intentIdentifiers: [], options: [])
        }else{
            alarmCategory = UNNotificationCategory(identifier: "alarmCategory", actions: [], intentIdentifiers: [], options: [])
        }
        UNUserNotificationCenter.current().setNotificationCategories([alarmCategory])
    }
    
    //通知設定
    func setNotificationC(day:String, repeats:Bool, time:Date){
        let content = UNMutableNotificationContent()
        content.title = alarmTime.label
        //音声ファイルを挿入
        let voiceSound = alarmTime.voice+"r.mp3"
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
        let request = UNNotificationRequest(identifier: alarmTime.uuidString+day, content: content, trigger: trigger)
        print(request)
        print(request.identifier)
        UNUserNotificationCenter.current().add(request){ (error) in
            if let error = error {
                print(error.localizedDescription)
                print("notificationエラー")
            }
        }
        alarmTime.date = datePicker.date
    }
    
    //アラート設定
    func alarmSet(){
        removeAlarm(identifiers: alarmTime.uuidString)
        let shortWeekday = DateFormatter().shortWeekdaySymbols!
        for i in shortWeekday{
            removeAlarm(identifiers: alarmTime.uuidString+i)
        }
        alarmTime.date = datePicker.date
        if alarmTime.week.isEmpty{
            setCategories()
            
            setNotificationC(day: "", repeats: false,time: alarmTime.date)
        }else{
            for i in alarmTime.week{
                setCategories()
                setNotificationC(day: i, repeats: true,time: alarmTime.date)
            }
        }
    }
    //アラーム設定削除
    func removeAlarm(identifiers:String){
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [identifiers])
    }

    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 0:
            switch indexPath.row {
            case 0:
                performSegue(withIdentifier: "showRepeat", sender: nil)
                break
            case 1:
                performSegue(withIdentifier: "showLabel", sender: nil)
                break
            case 2:
                performSegue(withIdentifier: "showSound", sender: nil)
                break
            default:
                break
            }
        default:
            break
        }
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "showRepeat":
            guard let nextVC:AlarmRepeatVC = segue.destination as? AlarmRepeatVC else {return}
            nextVC.delegate = self
            nextVC.selectDay = alarmTime.week
        case "showLabel":
            guard let nextVC:AlarmAddLabelVC = segue.destination as? AlarmAddLabelVC else{return}
            nextVC.delegate = self
            nextVC.text = alarmTime.label
        case "showSound":
            guard let nextVC:AlarmSoundVC = segue.destination as? AlarmSoundVC else {return}
            nextVC.delegate = self
            nextVC.voice = alarmTime.voice
        default:
            break
        }
    }
}

extension AlarmAddVC:AlarmRepeatVCDelegate{
    func AlarmRepeatVC(addRepeat: AlarmRepeatVC, week: [String]) {
        //初期化
        alarmTime.week = []
        alarmTime.repeatLabel = ""
        alarmTime.week += week
        
        //リピートが0,1,7の時の表示を変更
        if alarmTime.week.count == 1{
            alarmTime.repeatLabel = "Every"+alarmTime.week[0]
        }else if alarmTime.week.isEmpty{
            alarmTime.repeatLabel = "Never"
        }else if alarmTime.week.count == 7{
            alarmTime.repeatLabel = "Every Day"
        }else{
            let shortWeekday = DateFormatter().shortWeekdaySymbols!
            for i in alarmTime.week{
                if alarmTime.repeatLabel != ""{
                    alarmTime.repeatLabel += ","
                }
                alarmTime.repeatLabel += shortWeekday[weekDay(day: i)]
                
            }
        }
        tableView.reloadData()
    }
}

extension AlarmAddVC:UIAlarmAddLabelDelegate{
    func alarmAddLabel(labelText: AlarmAddLabelVC, text: String) {
        alarmTime.label = text
        tableView.reloadData()
    }
}

extension AlarmAddVC:AlarmSnoozeCellDelegate{
    func alarmSnoozeCell(switchOn: AlarmSnoozeCell, On: Bool) {
        alarmTime.snooze = On
    }
}

extension AlarmAddVC:AlarmDeleteCellDelegate{
    func alarmDeleteCell(delete: UITableViewCell) {
        delegate.AlarmAddVC(alarmDelete: self, alarmTime: alarmTime)
        performSegue(withIdentifier: "backView", sender: nil)
    }
    
    
}

extension AlarmAddVC:AlarmSoundVCDelegate{
    func AlarmSoundVC(vc: AlarmSoundVC, sound: String) {
        alarmTime.voice = sound
        tableView.reloadData()
    }
}

