import Foundation
protocol VoicePresenterDelegate:AnyObject{
    func launchReloadData(voices:[VoiceComponent])
}

class VoicePresenter: NSObject{
    
    private lazy var model:VoiceModel = VoiceModel(presenter: self)
    private weak var viewDelegate:VoiceVCDelegate?
    init(view:VoiceVCDelegate){
        self.viewDelegate = view
    }
    func launchPresenter(){
        model.getMetaData()
    }
    func playSoundPresenter(sound:String){
        model.playSound(sound: sound)
    }
}
extension VoicePresenter:VoicePresenterDelegate{
    func launchReloadData(voices: [VoiceComponent]) {
        self.viewDelegate?.reloadView(voices:voices)
    }
}
