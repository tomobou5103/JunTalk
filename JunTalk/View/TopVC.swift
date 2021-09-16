import UIKit
import Firebase
import AVFoundation
protocol  TopVCDelegate: AnyObject{
    func reloadView(sound:[[TalkSoundComponent]])
}
protocol CustomCellDelgate {
    func downloadSounds(index:Int)
}
class TopVC: UIViewController{
    
//MARK:-IBOutlet
    //AVPlayerView
    @IBOutlet weak var playerV: UIView!{didSet{self.playerV.alpha = 0}}
    @IBOutlet weak var playerTitleLabel: UILabel!
    @IBOutlet weak var startStopLabel: UIButton!
    @IBOutlet weak var ItemDurationLabel: UILabel!
    @IBOutlet weak var RunningItemDurationLabel: UILabel!
    @IBOutlet weak var timeSlider: UISlider!
    
    //UICollectionView
    @IBOutlet weak var firstCollectionV: UICollectionView!{
        didSet{collectionSetting(collection: firstCollectionV, cellId: cellId)}
    }
    @IBOutlet weak var secondCollectionV: UICollectionView!{
        didSet{collectionSetting(collection: secondCollectionV, cellId: cellId)}
    }
    @IBOutlet weak var thirdCollectionV: UICollectionView!{
        didSet{collectionSetting(collection: thirdCollectionV, cellId: cellId)}
    }
    @IBOutlet weak var fourthCollectionV: UICollectionView!{
        didSet{collectionSetting(collection: fourthCollectionV, cellId: cellId)}
    }
    @IBOutlet weak var fifthCollectionV: UICollectionView!{
        didSet{collectionSetting(collection: fifthCollectionV, cellId: cellId)}
    }
//MARK:-Property
    private lazy var presenter:TopPresenter = TopPresenter(view: self)
    public var talkSoundsArray:[[TalkSoundComponent]]?
    private let storage = Storage.storage()
    
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
    private let cellId = "firstCollectionViewCell"
//MARK:-IBOutletActionFunc
    //AVPlayerView
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
    @IBAction func backTenSec(_ sender: Any) {
        skip(interval: -skipInterval)
    }
    @IBAction func forwardTenSec(_ sender: Any) {
        skip(interval: skipInterval)
    }
    @IBAction func sliderDidTouchDown(_ sender: Any) {
        self.nowTouching = true
    }
    @IBAction func changePosition(_ sender: UISlider) {
        self.nowTouching = false
        let seconds = Double(sender.value) * self.itemDuration
        let timeScale = CMTimeScale(NSEC_PER_SEC)
        let time = CMTime(seconds: seconds, preferredTimescale: timeScale)
        changePosition(time:time)
    }
    //MainView to SafariBrowser
    @IBAction func toSafariBrowser(_ sender: Any) {
        let url = URL(string: "https://www.youtube.com/c/junchannel")!
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
            UIApplication.shared.openURL(url)
        }
    }
//MARK:-AVPlayerView

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
//MARK:-CollectionViewSetting
    private func collectionSetting(collection:UICollectionView,cellId:String){
        collection.register(UINib(nibName: cellId, bundle: nil), forCellWithReuseIdentifier: cellId)
        if let layout = collection.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
            layout.invalidateLayout()
        }
        collection.delegate = self
        collection.dataSource = self
        collection.backgroundColor = .black
    }
    private func collectionLayoutSetting(itemSpace:CGFloat,widthRatio:CGFloat)->UICollectionViewFlowLayout{
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = itemSpace
        layout.minimumLineSpacing = itemSpace
        let height = self.firstCollectionV.frame.height
        let width = height * widthRatio
        layout.itemSize = CGSize(width: width, height: height)
        return layout
    }
//MARK:-ViewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        firstCollectionV.collectionViewLayout = collectionLayoutSetting(itemSpace: 10, widthRatio: 1.85)
        secondCollectionV.collectionViewLayout = collectionLayoutSetting(itemSpace: 10, widthRatio: 1.85)
        thirdCollectionV.collectionViewLayout = collectionLayoutSetting(itemSpace: 10, widthRatio: 1.85)
        fourthCollectionV.collectionViewLayout = collectionLayoutSetting(itemSpace: 10, widthRatio: 1.85)
        fifthCollectionV.collectionViewLayout = collectionLayoutSetting(itemSpace: 10, widthRatio: 1.85)
        //PresenterにViewを更新する通知
        self.presenter.launchReceivePresenter()
    }
}
//MARK:-ExtensionCollectionView
extension TopVC:UICollectionViewDelegate,UICollectionViewDataSource{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let cvSort = CVSort(collectionTag: collectionView.tag).returnSectionNumber()
        if self.talkSoundsArray?[safe: cvSort]?.isEmpty == false{
            return self.talkSoundsArray![safe:cvSort]!.count
        }else{
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "firstCollectionViewCell", for: indexPath) as? firstCollectionViewCell
        cell?.delegate = self
        let cvSort = CVSort(collectionTag: collectionView.tag)
        let cvSortSection = cvSort.returnSectionNumber()
        if let talkSounds = self.talkSoundsArray?[safe: cvSortSection]{
            setCell(cell: cell ?? firstCollectionViewCell(), talkSounds: talkSounds, cellForItemAt: indexPath)
        }
        cell?.downloadButton.tag = cvSort.returnButtonTag(index: indexPath.row)
        return cell ?? firstCollectionViewCell()
    }

    func setCell(cell:firstCollectionViewCell,talkSounds:[TalkSoundComponent],cellForItemAt indexPath:IndexPath){
        let dateSt:String = talkSounds[indexPath.row].date
        let dateComponent:[String] = dateSt.components(separatedBy: ":")
        let timeSt:String = dateComponent[0] + "/" + dateComponent[1] + " - " + talkSounds[indexPath.row].time
        cell.timeLabel.text = timeSt
        cell.titleNameLabel.text = talkSounds[indexPath.row].title
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cvSort = CVSort(collectionTag: collectionView.tag)
        let cvSortSection = cvSort.returnSectionNumber()
        if let talkSounds = self.talkSoundsArray?[safe: cvSortSection]{
            playSound(tag: String(collectionView.tag), name: talkSounds[indexPath.row].url)
            self.playerTitleLabel.text = talkSounds[indexPath.row].title
        }else{
            print("could not load file-TopVC_didselectItemAt")
        }
        self.playerV.alpha = 1
    }

    func playSound(tag:String,name:String){
        let storageRef = storage.reference(forURL: "gs://juntalk-e0518.appspot.com/")
        let files = storageRef.child("\(tag)/\(name)")
        files.downloadURL { (hardUrl, error) in
          if error == nil,let url = hardUrl {
            self.playerItem = AVPlayerItem(url: url)
            self.player = AVPlayer(playerItem: self.playerItem)
            
            //SetItemDuration and SetSliderValue
            let asset = AVAsset(url: url)
            self.itemDuration = CMTimeGetSeconds(asset.duration)
            self.timeSlider.value = 0

            let durationTime = asset.duration.durationText
            self.ItemDurationLabel.text = durationTime
            
            //PlayerViewObserver
            self.addPeriodicTimeObserver()
            self.player?.play()
            
          }else{
            print("could not load sounds//playSound_TopVC")
          }
        }
    }
}
//MARK:-DelegateMethod
extension TopVC:TopVCDelegate{
    func reloadView(sound: [[TalkSoundComponent]]) {
        self.talkSoundsArray = sound
        firstCollectionV.reloadData()
        secondCollectionV.reloadData()
        thirdCollectionV.reloadData()
        fourthCollectionV.reloadData()
        fifthCollectionV.reloadData()
    }
}
extension TopVC:CustomCellDelgate{
    func downloadSounds(index:Int) {
        //cellのbuttonのタグによって分岐
        if index < 1000{
            self.presenter.downloadsoundsPresenter(talkSound: talkSoundsArray![0][index],tag: "2021")
        }else if index < 2000{
            self.presenter.downloadsoundsPresenter(talkSound: talkSoundsArray![1][index - 1000],tag: "2020")
        }else if index < 3000{
            self.presenter.downloadsoundsPresenter(talkSound: talkSoundsArray![2][index - 2000], tag: "2019")
        }else if index < 4000{
            self.presenter.downloadsoundsPresenter(talkSound: talkSoundsArray![3][index - 3000], tag: "2018")
        }else if index < 5000{
            self.presenter.downloadsoundsPresenter(talkSound: talkSoundsArray![3][index - 4000], tag: "2017")
        }else{
            print("could not find the sound-TopVC-CustomCellDelegate")
        }
    }
}
//MARK:-CMTimeExtension-relate AVPlayer
extension CMTime {
    var durationText:String {
        let totalSeconds = CMTimeGetSeconds(self)
        let hours:Int = Int(totalSeconds / 3600)
        let minutes:Int = Int(totalSeconds.truncatingRemainder(dividingBy: 3600) / 60)
        let seconds:Int = Int(totalSeconds.truncatingRemainder(dividingBy: 60))

        if hours > 0 {
            return String(format: "%02i:%02i:%02i", hours, minutes, seconds)
        } else {
            return String(format: "%02i:%02i", minutes, seconds)
        }
    }
    var positionalTime: String {
        let floorSeconds: TimeInterval = floor(seconds)
        let hours = Int(floorSeconds / 3600)
        let minute = Int(floorSeconds.truncatingRemainder(dividingBy: 3600) / 60)
        let second = Int(floorSeconds.truncatingRemainder(dividingBy: 60))
        return String(format: "%02i:%02i:%02i", hours, minute, second)
    }
}
extension Array {
    subscript (safe index: Index) -> Element? {
        //indexが配列内なら要素を返し、配列外ならnilを返す（三項演算子）
        return indices.contains(index) ? self[index] : nil
    }
}
