
import BigInt

public struct StellarSendData {
    public var to: String
    public var value: Int

    public init(to: String, value: Int) {
        self.to = to
        self.value = value
    }
}
