protocol TopPresenterDelegate: AnyObject{
    func launchReloadData(sound:[[TalkSoundComponent]])
}
import Foundation
class TopPresenter:NSObject{
    weak var viewDelegate:TopVCDelegate?
    private lazy var model:TopModel = TopModel(presenter: self)
    init(view:TopVCDelegate) {
        self.viewDelegate = view
    }
    func launchReceivePresenter(){
        //ModelにViewを更新する通知
        model.launchReciveModel()
    }
    func downloadsoundsPresenter(talkSound:TalkSoundComponent,tag:String){
        model.downloadSoundsModel(talkSound: talkSound,tag: tag)
    }
}
extension TopPresenter:TopPresenterDelegate{
    func launchReloadData(sound:[[TalkSoundComponent]]) {
        self.viewDelegate?.reloadView(sound: sound)
    }
}
