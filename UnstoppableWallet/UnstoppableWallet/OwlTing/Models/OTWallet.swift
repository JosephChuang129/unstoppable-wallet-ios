import ObjectMapper

struct OTWallet : Mappable {
    
    var address : String?
    var currency : String?
    var decimals : String?
    var symbol : String?
    var vendor : String?
    var type : String?
    var data : String?
    
    init() {}
    init?(map: Map) {
        
    }
    
    mutating func mapping(map: Map) {
        
        address <- map["address"]
        currency <- map["currency"]
        decimals <- map["decimals"]
        symbol <- map["symbol"]
        vendor <- map["vendor"]
        type <- map["type"]
        data <- map["data"]
    }
}

struct OTWalletToken : Mappable {
    var access : String?
    var refresh : String?
    
    init() {}
    init?(map: Map) {
        
    }
    
    mutating func mapping(map: Map) {
        
        access <- map["access"]
        refresh <- map["refresh"]
    }
    
}

struct WalletSync : Mappable {
    var wallets : [OTWallet]?
    
    init() {}
    init?(map: Map) {
        
    }
    
    mutating func mapping(map: Map) {
        
        wallets <- map["wallet"]
    }
}

struct OTWalletResponse : Mappable {
    var status : Bool?
    var data : [OTWallet]?

    init?(map: Map) {

    }

    mutating func mapping(map: Map) {

        status <- map["status"]
        data <- map["data"]
    }

}

struct OTWalletLoginRequest : Mappable {
    
    var uuid : String?
    var secret : String?
    var expire : Float?
    var email : String?
    var password : String?
    
    init() {}
    init?(map: Map) {
        
    }
    
    mutating func mapping(map: Map) {
        
        uuid <- map["uuid"]
        secret <- map["secret"]
        expire <- map["expire"]
        email <- map["email"]
        password <- map["password"]
    }
}

struct OTWalletLoginResponse : Mappable {
    
    var status : Bool?
    var code : String?
    var token : OTWalletToken?
    var customer : Customer?
    var msg : String?
    
    init() {}
    init?(map: Map) {
        
    }
    
    mutating func mapping(map: Map) {
        
        status <- map["status"]
        code <- map["code"]
        token <- map["token"]
        customer <- map["customer"]
        msg <- map["msg"]
    }
}

struct OTWalletTokenRefreshResponse : Mappable {
    
    var status : Bool?
    var token : OTWalletToken?
    
    init() {}
    init?(map: Map) {
        
    }
    
    mutating func mapping(map: Map) {
        
        status <- map["status"]
        token <- map["token"]
    }
}

struct OTWalletRegisterRequest : Mappable {
    
    var email : String?
    var password : String?
    var name : String?
    var gender : String?
    var birthday : String?
    
    init() {}
    init?(map: Map) {
        
    }
    
    mutating func mapping(map: Map) {
        
        email <- map["email"]
        password <- map["password"]
        name <- map["name"]
        gender <- map["gender"]
        birthday <- map["birthday"]
    }
}

struct OTWalletRegisterResponse : Mappable {
    
    var status : Bool?
    var token : OTWalletToken?
    var customer : Customer?
    var msg : String?
    
    init() {}
    init?(map: Map) {
        
    }
    
    mutating func mapping(map: Map) {
        
        status <- map["status"]
        token <- map["token"]
        customer <- map["customer"]
        msg <- map["msg"]
    }
}
