
import Foundation
import ObjectMapper

struct AmlCountry : Mappable {
	var isoCode : String?
	var name : String?
	var flagUrl : String?

    init() {}
	init?(map: Map) {

	}

	mutating func mapping(map: Map) {

		isoCode <- map["isoCode"]
		name <- map["name"]
		flagUrl <- map["flagUrl"]
	}

}


struct AmlCountryRequest : Mappable {
    
    var lang : String?
    var filterType : String? = "app"
    var nameFormat : String?
    
    init() {}
    init?(map: Map) {
        
    }
    
    mutating func mapping(map: Map) {
        
        lang <- map["lang"]
        filterType <- map["filterType"]
        nameFormat <- map["nameFormat"]
    }
}

struct AmlCountryResponse : Mappable {
    var status : Bool?
    var msg : String?
    var data : [AmlCountry]?
    
    init() {}
    init?(map: Map) {
        
    }
    
    mutating func mapping(map: Map) {
        
        status <- map["status"]
        msg <- map["msg"]
        data <- map["data"]
    }
    
}

struct AmlRegisterRequest : Mappable {
    
    var country : String?
    var birthday : String?
    var name : String?
    var chains : [UserChain]?
    
    init() {}
    init?(map: Map) {
        
    }
    
    mutating func mapping(map: Map) {
        
        country <- map["country"]
        birthday <- map["birthday"]
        name <- map["name"]
        chains <- map["chains"]
    }
}

struct AmlUserMetaResponse : Mappable {
    
    var status : Bool?
    var data : AmlUserMeta?
    var msg : String?
    var code : Int?
    
    init() {}
    init?(map: Map) {
        
    }
    
    mutating func mapping(map: Map) {
        
        status <- map["status"]
        data <- map["data"]
        msg <- map["msg"]
        code <- map["code"]
    }
}

struct UserChain : Mappable, Equatable {
    var network : String?
    var asset : String?
    var address : String?
    var isBinding : Bool?

    init() {}
    init?(map: Map) {

    }

    mutating func mapping(map: Map) {

        network <- map["network"]
        asset <- map["asset"]
        address <- map["address"]
        isBinding <- map["isBinding"]
    }

    static func ==(lhs: UserChain, rhs: UserChain) -> Bool { // Implement Equatable
        return lhs.network == rhs.network && lhs.asset == rhs.asset && lhs.address == rhs.address
    }
}


struct BaseRequest : Mappable {
    
    var lang : String?
    
    init() {}
    init?(map: Map) {
        
    }
    
    mutating func mapping(map: Map) {
        
        lang <- map["lang"]
    }
}
