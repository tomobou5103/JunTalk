import Foundation

class TalkSoundComponent: NSObject {
    
    public var title:String!
    public var date:String!
    public var sortedDate:Date!
    public var time:String!
    public var url:String!
    
    init(title:String,date:String,time:String,url:String) {
        self.title = title
        self.date = date
        self.time = time
        self.url = url
    }
    public func toDate(dateString:String){
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM:dd,z"
        if let date = dateFormatter.date(from: dateString){
            self.sortedDate = date
        }
    }
    
}
