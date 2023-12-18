import ObjectMapper
struct SSOProviderResponse : Mappable {
    var error : String?
    var code : String?
    var uuid : String?
    var secret : String?
    
    init() {}
    init?(map: Map) {
        
    }
    
    mutating func mapping(map: Map) {
        
        error <- map["error"]
        code <- map["code"]
        uuid <- map["uuid"]
        secret <- map["secret"]
    }
    
}

struct SSOProviderRequest : Mappable {
    
    var email : String?
    var password : String?
    
    init() {}
    init?(map: Map) {
        
    }
    
    mutating func mapping(map: Map) {
        
        email <- map["email"]
        password <- map["password"]
    }
}


struct Customer : Mappable {
    var uuid : String?
    var name : String?
    var email : String?
    var avatar : String?
    var createdAt : String?
    var updatedAt : String?
    
    init?(map: Map) {
        
    }
    
    mutating func mapping(map: Map) {
        
        uuid <- map["uuid"]
        name <- map["name"]
        email <- map["email"]
        avatar <- map["avatar"]
        createdAt <- map["created_at"]
        updatedAt <- map["updated_at"]
    }
    
}

struct SSOPasswordForgotRequest : Mappable {
    
    var email : String?
    var expectTo : String? = ""
    var subject : String?
    var tmpl : String?
    
    init() {}
    init?(map: Map) {
        
    }
    
    mutating func mapping(map: Map) {
        
        email <- map["email"]
        expectTo <- map["expectTo"]
        subject <- map["subject"]
        tmpl <- map["tmpl"]
    }
}

struct SSOPasswordForgotResponse : Mappable {
    var status : Bool?
    var msg : String?
    
    init() {}
    init?(map: Map) {
        
    }
    
    mutating func mapping(map: Map) {
        
        status <- map["status"]
        msg <- map["msg"]
    }
    
}
