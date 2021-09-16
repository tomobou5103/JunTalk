import UIKit
import AVFoundation
import UserNotifications

protocol AlarmSoundVCDelegate{
    func AlarmSoundVC(vc:AlarmSoundVC,sound:String)
}

class AlarmSoundVC: UIViewController, UITableViewDelegate,UITableViewDataSource{

    @IBOutlet weak var tableV: UITableView!
    
    let userdefaults = UserDefaults()
    var delegate:AlarmSoundVCDelegate!
    var audioPlayer:AVAudioPlayer!
    var voice:String!
    let sounds:[String] = [
        "どりゃあああああああああ","初やあ","今のセクター1000点","全軍突撃じゃあああ","じゃあオメエの言う普通ってなんだよ",
        "ひん","おいいくべえよ！","俺に感情はない","セピアに言って欲しい(Fullmetal Alchemist)","右ストレートでぶっとばす",
        "ジュンイチィィィ！！！","界王様","いいよぉ(ギアさん)","ダツラ戦勝ち筋","ダツラ戦負け筋","バックナックル",
        "キレたはいぷっちーん","フンッフンッフンッ","泥棒確保","泥棒擁護","セイー","何これ","ちん狼","俺の方が早かった",
        "自己紹介(日中)","やってるー？","すばらしいことじゃない","あかんて！あかんて！","うっそおお(坂田銀時)",
        "5,4,3,2,1 結果を表示します","たのしいいいいい！","パワー系シバチャンネル","びっくりした(DBD)","早起きじじい",
        "みゃこって手が汚ぇよな","するよなぁ","お前強すぎる","そにー","しようとする気持ち",
    ]
    //TableViewCellはメモリ節約のためにインスタンスを使いまわしている
    //accessoryを保持する変数
    var accessory = [Int:Bool]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableV.delegate = self
        tableV.dataSource = self
        tableV.allowsMultipleSelection = false
    }
    //-------------------tableView-------------------
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sounds.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:UITableViewCell = tableV.dequeueReusableCell(withIdentifier: "HARADA", for: indexPath)
        cell.textLabel!.text = sounds[indexPath.row]
        cell.textLabel?.textColor = .white
        cell.detailTextLabel?.text = ""
        if accessory[indexPath.row] == true{
            cell.accessoryType = .checkmark
        }else{
            cell.accessoryType = .none
        }
        return cell
    }
    
    func setNum(str:String)->Int{
        let arr = str.components(separatedBy: "k")
        return Int(arr[1])!
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            let sourceSound = "unk\(indexPath.row+1)"
            let cell = tableV.cellForRow(at: indexPath)
            cell?.accessoryType = .checkmark
            accessory = [indexPath.row:true]
            playSound(sound: getPath(name: sourceSound))
            delegate.AlarmSoundVC(vc: self, sound: sourceSound)
    }
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let cell = tableV.cellForRow(at: indexPath)
        cell?.accessoryType = .none
        accessory = [indexPath.row:false]
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
//MARK:-SoundFunction
    func getPath(name:String) -> URL{
        //音源のパス
        let soundFilePath = Bundle.main.path(forResource: name, ofType: "mp3") ?? ""
        //パスのURL
        if soundFilePath != ""{
            let sound:URL = URL(fileURLWithPath: soundFilePath)
            return sound
        }else{
            print("could not load soundFile-getPath-AlarmSoundVC")
            return URL(fileURLWithPath: "")
        }
    }
    func playSound(sound:URL){
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: sound, fileTypeHint: nil)
        }catch{
            print("could not load file")
        }
        audioPlayer.play()
    }
}

