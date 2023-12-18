import Foundation
import ObjectMapper

struct AmlUserMeta : Mappable {
	var ssoUserId : Int?
	var ssoId : String?
	var integratedStatus : String?
	var ssoUserMeta : SSOUserMeta?
	var ssoUserChains : [SSOUserChain]?

    init() {}
	init?(map: Map) {

	}

	mutating func mapping(map: Map) {

		ssoUserId <- map["ssoUserId"]
		ssoId <- map["ssoId"]
		integratedStatus <- map["integratedStatus"]
		ssoUserMeta <- map["ssoUserMeta"]
		ssoUserChains <- map["ssoUserChains"]
	}

}
