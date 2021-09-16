import UIKit

protocol UIAlarmAddLabelDelegate {
    func alarmAddLabel(labelText:AlarmAddLabelVC,text:String)
}

class AlarmAddLabelVC: UIViewController,UITextFieldDelegate {
    
    @IBOutlet weak var textField: UITextField!
    
    var text:String!
    var delegate:UIAlarmAddLabelDelegate!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //テキストを全削除するボタンを作成
        textField.clearButtonMode = .always
        //改行ボタンの種類を設定
        textField.returnKeyType = .done
        //UITextFieldを追加
        textField.delegate = self
        //デフォルトでキーボードを表示する
        textField.becomeFirstResponder()
        
        textField.text = text
    }
    
    //完了ボタンを押した時の処理
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        //textFieldの中身が空出ない時の処理
        if textField.text != "",let text = textField.text{
            delegate.alarmAddLabel(labelText: self, text: text)
            navigationController?.popViewController(animated: true)
        }
        return true
    }

}

