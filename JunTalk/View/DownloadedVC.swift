import UIKit
import AVFoundation

class DownloadedVC: UIViewController {
//MARK:-Property
    private var downloadedSoundsArray:[[String]] = []
    private let dirPath:String = NSHomeDirectory() + "/Documents"
    //To Manage UISlider
    private var nowTouching:Bool = false
    //To Manage AVPlayer & PlayerView
    private var player:AVPlayer?
    private var playerItem:AVPlayerItem?
    private var itemDuration:Double = 0
    private var timeObserverToken:Any?
    private var skipInterval:Double = 10
    private var isPlaying:Bool{
        return player?.rate != 0 && player?.error == nil
    }
    //UITableViewCellHeight
    private let tableViewCellHeight:CGFloat = 75
//MARK:-IBOutlet
    @IBOutlet weak var tableV: UITableView!{
        didSet{
            tableV.delegate = self
            tableV.dataSource = self
            tableV.register(UINib(nibName: "JunVoiceTableViewCell", bundle: nil), forCellReuseIdentifier: "Voice")
        }
    }
    //PlayerView
    @IBOutlet weak var playerV: UIView!{didSet{self.playerV.alpha = 0}}
    @IBOutlet weak var playerTitleLabel: UILabel!
    @IBOutlet weak var startStopLabel: UIButton!
    @IBOutlet weak var ItemDurationLabel: UILabel!
    @IBOutlet weak var RunningItemDurationLabel: UILabel!
    @IBOutlet weak var timeSlider: UISlider!
//MARK:-IBOutletAction
    @IBAction func startStopButton(_ sender: Any) {
        guard let player = player else{return}
        if isPlaying{
            startStopLabel.setImage(UIImage(named: "play"), for: .normal)
            player.pause()
        }else{
            startStopLabel.setImage(UIImage(named: "pause"), for: .normal)
            player.play()
        }
    }
    @IBAction func backTenSec(_ sender: Any) {skip(interval: -skipInterval)}
    @IBAction func forwardTenSec(_ sender: Any) {skip(interval: skipInterval)}
    @IBAction func sliderDidTouchDown(_ sender: Any) {self.nowTouching = true}
    @IBAction func changePosition(_ sender: UISlider) {
        self.nowTouching = false
        let seconds = Double(sender.value) * self.itemDuration
        let timeScale = CMTimeScale(NSEC_PER_SEC)
        let time = CMTime(seconds: seconds, preferredTimescale: timeScale)
        changePosition(time:time)
    }
//MARK:-PlayerViewFunction
    private func skip(interval: Double){
        let timeScale = CMTimeScale(NSEC_PER_SEC)
        let rhs = CMTime(seconds: interval, preferredTimescale: timeScale)
        let time = CMTimeAdd(player!.currentTime(), rhs)
        changePosition(time:time)
    }
    private func changePosition(time:CMTime){
        let rate = self.player?.rate
        //stop the player
        player?.rate = 0
        //change the positon to the time
        player?.seek(to: time, completionHandler: {_ in
            //playerをもとのrateに戻す
            self.player?.rate = rate!
        })
    }
    private func addPeriodicTimeObserver(){
        //Notify every half second
        let timeScale = CMTimeScale(NSEC_PER_SEC)
        let time = CMTime(seconds: 0.1, preferredTimescale: timeScale)
        timeObserverToken = player?.addPeriodicTimeObserver(forInterval: time,queue:.main)
            {[weak self] time in
            //Upadate player tranport UI
            DispatchQueue.main.async {
            //Update the UISlider
                if let nowTouching = self?.nowTouching,nowTouching == false{
                    if let player = self?.player, player.rate > 0{
                        self?.updateSlider(exTime: time)
                    }
                }
           }
        }
    }
    private func updateSlider(exTime:CMTime){
        let time = player?.currentItem?.currentTime() ?? CMTime.zero
        if itemDuration != 0{
            timeSlider.value = Float(CMTimeGetSeconds(time) / self.itemDuration)
            self.RunningItemDurationLabel.text = exTime.positionalTime
        }
    }
//MARK:-ViewWllAppear
    override func viewWillAppear(_ animated: Bool) {
        setView()
    }
    private func setView(){
        //Refactoring
        downloadedSoundsArray.removeAll()
        downloadedSoundsArray = [["2021"],["2020"],["2019"],["2018"],["2017"]]
        let dirKey = ["2021","2020","2019","2018","2017"]
        for i in dirKey{
            let downloadedSounds = getFileInfoListInDir(dirName: dirPath + "/" + i)
            if downloadedSounds != [""]{
                let cvSortSection = CVSort.init(year: i).returnSectionNumber()
                self.downloadedSoundsArray[cvSortSection].append(contentsOf: downloadedSounds)
            }
        }
        if self.isPlaying{
            self.startStopLabel.setImage(UIImage(named: "pause"), for: .normal)
        }else{
            self.startStopLabel.setImage(UIImage(named: "play"),for: .normal)
        }
        tableV.reloadData()
    }
    
    func getFileInfoListInDir(dirName:String)->[String]{
        guard let fileNames = try? FileManager.default.contentsOfDirectory(atPath: dirName) else {
            return [""]
        }
        return fileNames
    }
    func removeDownloadedFile(path:URL)->Bool{
        let fileManager = FileManager.default
        do{
            try fileManager.removeItem(at: path)
        }catch{
            return false
        }
        return true
    }
    func convertString(title:String,time:Bool)->String{
        if time{
            let arr:[String] = title.components(separatedBy: "&")
            return arr[0] + " " + arr[2]
        }else{
            let arr:[String] = title.components(separatedBy: "&")
            return arr[0]
        }
    }
}
//MARK:-Extension TableViewDelegate-DataSource
extension DownloadedVC:UITableViewDelegate,UITableViewDataSource{

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.downloadedSoundsArray.isEmpty == false{
            return self.downloadedSoundsArray[section].count
        }else{
         return 0
        }
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        if self.downloadedSoundsArray.isEmpty == false{
            return self.downloadedSoundsArray.count
        }else{
            return 0
        }
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return tableViewCellHeight
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableV.cellForRow(at: indexPath) as? JunVoiceTableViewCell
        if indexPath.row != 0{
            cell?.unkImageV.alpha = 1
            self.playerV.alpha = 1
            playerTitleLabel.text = convertString(title: downloadedSoundsArray[indexPath.section][indexPath.row],time: false)
            playSound(indexPath: indexPath)
        }
    }
    func playSound(indexPath:IndexPath){
        let cvSortYear = CVSort(section: indexPath.section).returnYear()
        let soundPath:String = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).last! + "/\(cvSortYear)/" + self.downloadedSoundsArray[indexPath.section][indexPath.row]
        self.playerItem = AVPlayerItem(url: URL(fileURLWithPath: soundPath))
        self.player = AVPlayer(playerItem: self.playerItem)
        //SetItemDuration and SetSliderValue
        let asset:AVAsset = AVAsset(url: URL(fileURLWithPath: soundPath))
        self.itemDuration = CMTimeGetSeconds(asset.duration)
        self.timeSlider.value = 0
        let durationTime = asset.duration.durationText
        self.ItemDurationLabel.text = durationTime
        //PlayerViewObserver
        self.addPeriodicTimeObserver()
        self.player?.play()
    }
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let cell = tableV.cellForRow(at: indexPath) as? JunVoiceTableViewCell
            cell?.unkImageV.alpha = 0
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableV.dequeueReusableCell(withIdentifier: "Voice", for: indexPath) as? JunVoiceTableViewCell
        cell?.unkImageV.alpha = 0
        cell?.backgroundColor = UIColor(red: 232, green: 220, blue: 152, alpha: 1)
        if indexPath.row == 0{
            let cvSortYear = CVSort(section: indexPath.section).returnYear()
            cell?.imageV.image = UIImage(named: "download\(cvSortYear)")
            cell?.titleTextLabel.text = ""
        }else{
            let sound = self.downloadedSoundsArray[indexPath.section][safe:indexPath.row]
            if sound != ""{
                cell?.imageV.image = UIImage(named: "newCell")
                cell?.titleTextLabel.text = convertString(title: sound ?? "",time: true)
            }
        }
        return cell ?? JunVoiceTableViewCell()
    }
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        if indexPath.row != 0{
            let deleteAction = UIContextualAction(style: .destructive, title: "削除") { (action, view, completionHandler) in
                let cvSortYear = CVSort.init(section: indexPath.section).returnYear()
                let path = self.dirPath + "/\(cvSortYear)/" + self.downloadedSoundsArray[indexPath.section][indexPath.row]
                if self.removeDownloadedFile(path: URL(fileURLWithPath: path)){
                    self.downloadedSoundsArray[indexPath.section].remove(at: indexPath.row)
                    self.tableV.deleteRows(at: [indexPath], with: .fade)
                }else{
                    print("could not delete file-TrailingSwipeActionConfiguration")
                }
                print("finished deleting soundFile")
                completionHandler(true)
            }
            return UISwipeActionsConfiguration(actions: [deleteAction])
        }else{
            return nil
        }
    }
}
