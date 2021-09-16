enum CVSort{
    //CollectionView Sort
    case first
    case second
    case third
    case fourth
    case fifth
    case other
    
    init(collectionTag:Int) {
        switch collectionTag {
        case 2021:
            self = .first
        case 2020:
            self = .second
        case 2019:
            self = .third
        case 2018:
            self = .fourth
        case 2017:
            self = .fifth
        default:
            self = .other
        }
    }
    init(year:String) {
        switch year {
        case "2021":
            self = .first
        case "2020":
            self = .second
        case "2019":
            self = .third
        case "2018":
            self = .fourth
        case "2017":
            self = .fifth
        default:
            self = .other
        }
    }
    init(section:Int) {
        switch section {
        case 0:
            self = .first
        case 1:
            self = .second
        case 2:
            self = .third
        case 3:
            self = .fourth
        case 4:
            self = .fifth
        default:
            self = .other
        }
    }

    public func returnYear()->String{
        switch self {
        case .first:
            return "2021"
        case .second:
            return "2020"
        case .third:
            return "2019"
        case .fourth:
            return "2018"
        case .fifth:
            return "2017"
        case .other:
            return "99999"
        }
    }
    public func returnSectionNumber()->Int{
        switch self {
        case .first:
            return 0
        case .second:
            return 1
        case .third:
            return 2
        case .fourth:
            return 3
        case .fifth:
            return 4
        case .other:
            return 99999
        }
    }
    public func returnButtonTag(index:Int)->Int{
        switch self {
        case .first:
            return index
        case .second:
            return index + 1000
        case .third:
            return index + 2000
        case .fourth:
            return index + 3000
        case .fifth:
            return index + 4000
        case .other:
            return 99999
        }
    }
}
