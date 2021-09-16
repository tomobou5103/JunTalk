import UIKit
import AVFoundation
protocol VoiceVCDelegate:AnyObject {
    func reloadView(voices:[VoiceComponent])
}

class VoiceVC: UIViewController {

    @IBOutlet weak var tableV: UITableView!{
        didSet{
            tableV.delegate = self
            tableV.dataSource = self
            tableV.register(UINib(nibName: "JunVoiceTableViewCell", bundle: nil), forCellReuseIdentifier: cellID)
        }
    }
//MARK:-Property
    private let tableViewCellHeight:CGFloat = 75
    private lazy var presenter:VoicePresenter = VoicePresenter(view: self)
    private let cellID = "Voice"
    private var voices:[VoiceComponent] = []
//MARK:-ViewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        self.presenter.launchPresenter()
    }
}
//MARK:-Extension UITableView
extension VoiceVC:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return voices.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableV.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as? JunVoiceTableViewCell
        switch indexPath.row {
        case 0:
            cell?.imageV.image = UIImage(named: "newCell1")
            cell?.titleTextLabel.text = ""
        default:
            cell?.imageV.image = UIImage(named: "newCell")
            cell?.titleTextLabel.text = convertTitleString(titleName: voices[indexPath.row - 1].name)
        }
        cell?.unkImageV.alpha = 0
        return cell!
    }
    func convertTitleString(titleName:String)->String{
        let st:String = titleName
        let arr:[String] = st.components(separatedBy: ".")
        return arr[0]
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return tableViewCellHeight
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableV.cellForRow(at: indexPath) as? JunVoiceTableViewCell
        if indexPath.row != 0{
            cell?.unkImageV.alpha = 1
            presenter.playSoundPresenter(sound: voices[indexPath.row - 1].name)
        }
    }
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let cell = tableV.cellForRow(at: indexPath) as? JunVoiceTableViewCell
        cell?.unkImageV.alpha = 0
    }
}
extension VoiceVC:VoiceVCDelegate{
    func reloadView(voices: [VoiceComponent]) {
        self.voices = voices
        tableV.reloadData()
    }
}
