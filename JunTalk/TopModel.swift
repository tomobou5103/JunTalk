import Foundation
import Firebase
import UIKit

class TopModel:NSObject{
    
    private let era:[String] = ["2021","2020","2019","2018","2017"]
    private weak var presenterDelegate:TopPresenterDelegate?
    init(presenter:TopPresenterDelegate) {
        self.presenterDelegate = presenter
    }
    private var talkSoundsArray:[[TalkSoundComponent]] = []
    private static let storage = Storage.storage()
    private let storageRef = storage.reference(forURL: "gs://juntalk-e0518.appspot.com/")
    func launchReciveModel() ->Void {
        getMetaData()
    }
    func downloadSoundsModel(talkSound:TalkSoundComponent,tag:String){
        downloadData(talkSound: talkSound,tag: tag)
    }
    func downloadData(talkSound:TalkSoundComponent,tag:String){
        print("Started to download")
        let path:String = tag + "/" + talkSound.url
        let islandRef = storageRef.child(path)
        let LibraryPath = URL(fileURLWithPath: NSHomeDirectory() + "/Documents/\(tag)/\(String(describing: talkSound.url!))")
        print(LibraryPath)
        _ = islandRef.write(toFile: LibraryPath){ url,error in
            if let error = error{
                print(error)
            }else{
                print("complited downloading sounds in your Documents")
            }
        }
    }
    func sendTag(tag:String,completion: @escaping () -> Void){
            let files = storageRef.child(tag)
            files.listAll{res,error in
                if error != nil{
                    print("could not load metadata")
                }else{
                    var talkSounds:[TalkSoundComponent] = []
                    for item in res.items{
                        let str:String = item.name
                        let arr:[String] = str.components(separatedBy: "&")
                        let talkSound = TalkSoundComponent(title: arr[0], date: arr[1], time: arr[2], url: str)
                        talkSound.toDate(dateString: arr[1] + ",0000")
                        talkSounds.append(talkSound)
                    }
                    if talkSounds.isEmpty == false{
                        talkSounds = talkSounds.sorted(by: {
                            $0.date.compare($1.date) == .orderedDescending
                        })
                        self.talkSoundsArray.append(talkSounds)
                        completion()
                    }else{
                        print("talkSounds is empty")
                    }
                }
            }
    }
    func getMetaData(){
        self.sendTag(tag:self.era[0],completion: {[weak self]()->Void in
            self?.sendTag(tag: self!.era[1], completion: {[weak self]()->Void in
                self?.sendTag(tag: self!.era[2], completion: {[weak self]()->Void in
                    self?.sendTag(tag: self!.era[3], completion: {[weak self]()->Void in
                        self?.sendTag(tag: self!.era[4], completion: {[weak self]()->Void in
                            self!.presenterDelegate?.launchReloadData(sound: self!.talkSoundsArray)
                        })
                    })
                })
            })
        })
    }
}
