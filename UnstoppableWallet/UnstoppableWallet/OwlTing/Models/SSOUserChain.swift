import Foundation
import ObjectMapper

struct SSOUserChain : Mappable, Equatable {
	var ssoUserChainId : Int?
	var ssoUserId : Int?
	var chainNetwork : String?
	var chainAsset : String?
	var chainAddress : String?
	var chainIsBinding : Bool?
    var wallet: Wallet?

    init() {}
	init?(map: Map) {

	}

	mutating func mapping(map: Map) {

		ssoUserChainId <- map["ssoUserChainId"]
		ssoUserId <- map["ssoUserId"]
		chainNetwork <- map["chainNetwork"]
		chainAsset <- map["chainAsset"]
		chainAddress <- map["chainAddress"]
		chainIsBinding <- map["chainIsBinding"]
        wallet <- map["wallet"]
	}

    static func ==(lhs: SSOUserChain, rhs: SSOUserChain) -> Bool { // Implement Equatable
        return lhs.chainNetwork == rhs.chainNetwork && lhs.chainAsset == rhs.chainAsset && lhs.chainAddress == rhs.chainAddress
    }
}
