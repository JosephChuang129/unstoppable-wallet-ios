
import BigInt

public struct StellarSendData {
    public var to: String
    public var value: Int
    public var memo: String?

    public init(to: String, value: Int, memo: String?) {
        self.to = to
        self.value = value
        self.memo = memo
    }
}
