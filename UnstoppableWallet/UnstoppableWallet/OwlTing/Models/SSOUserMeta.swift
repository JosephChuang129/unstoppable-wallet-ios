import Foundation
import ObjectMapper

struct SSOUserMeta : Mappable {
	var ssoUserMetaId : Int?
	var ssoUserId : Int?
	var name : String?
	var birthday : String?
	var country : AmlCountry?
	var email : String?

	init?(map: Map) {

	}

	mutating func mapping(map: Map) {

		ssoUserMetaId <- map["ssoUserMetaId"]
		ssoUserId <- map["ssoUserId"]
		name <- map["name"]
		birthday <- map["birthday"]
		country <- map["country"]
		email <- map["email"]
	}

}


struct CustomerProfileRequest : Mappable {
    
    var token : String?
    
    init() {}
    init?(map: Map) {
        
    }
    
    mutating func mapping(map: Map) {
        
        token <- map["token"]
    }
}

struct OwlPayQrcodeResponse : Mappable {
    
    var owltingUUID : String?
    var token : String?
    
    init?(map: Map) {
        
    }
    
    mutating func mapping(map: Map) {
        
        owltingUUID <- map["owlting_uuid"]
        token <- map["token"]
    }
}
