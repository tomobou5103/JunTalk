import UIKit
import AVFoundation

class PlayerV: UIView {
//MARK:-Property
    //To Manage UISlider
    private var nowTouching:Bool = false
    //To Manage AVPlayer & PlayerView
    private var player:AVPlayer?
    private var playerItem:AVPlayerItem?
    public var itemDuration:Double = 0
    private var timeObserverToken:Any?
    private var skipInterval:Double = 10
    private var isPlaying:Bool{
        return player?.rate != 0 && player?.error == nil
    }

    
    //MARK:-AVPlayerView

        @IBOutlet weak var playerTitleLabel: UILabel!
        @IBOutlet weak var startStopLabel: UIButton!
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
        @IBOutlet weak var ItemDurationLabel: UILabel!
        @IBOutlet weak var RunningItemDurationLabel: UILabel!
        @IBOutlet weak var timeSlider: UISlider!

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
                self.player?.rate = rate!
            })
        }
        
        //再生に合わしてSeekBarを更新する
        public func addPeriodicTimeObserver(){
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
                //Update the NowPlayingInfoCenter
    //                self?.updateNowPlayig(time:CMTimeGetSeconds(time))
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
        
        
}
