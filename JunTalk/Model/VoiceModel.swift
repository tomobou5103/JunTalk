import Foundation
import FirebaseStorage
import AVFoundation

class VoiceModel: NSObject {
    
    //AVPlayer
    private var player:AVPlayer?
    private var playerItem:AVPlayerItem?
    private weak var presenterDelegate:VoicePresenterDelegate?
    private static let storage = Storage.storage()
    private let storageRef = storage.reference(forURL: "gs://juntalk-e0518.appspot.com/")
    private var voices:[VoiceComponent] = []
    
    init(presenter:VoicePresenterDelegate) {
        self.presenterDelegate = presenter
    }
    public func getMetaData(){
        loadVoiceData(completion: {[weak self]()->Void in
            
            self!.presenterDelegate!.launchReloadData(voices: self!.voices)
        })
    }
    public func loadVoiceData(completion:@escaping ()->Void){
        let files = storageRef.child("Voice")
        files.listAll{res,error in
            if error != nil{
                print("could not load metadata")
            }else{
                for item in res.items{
                    let voice:VoiceComponent = VoiceComponent(name: item.name)
                    self.voices.append(voice)
                }
                completion()
            }
        }
    }
    public func playSound(sound:String){
        let files = storageRef.child("Voice" + "/" + sound)
        files.downloadURL(completion: {(hardUrl, error) in
            if error == nil,let url = hardUrl{
                self.playerItem = AVPlayerItem(url: url)
                self.player = AVPlayer(playerItem: self.playerItem)
                self.player?.play()
            }
        })
    }
}
