public struct AnyEquatable: Equatable, CustomStringConvertible {
    private let value: Any
    private let equals: (Any) -> Bool

    public let description: String

    public init<T: Equatable>(_ value: T) {
        self.value = value
        self.equals = { ($0 as? T == value) }
        self.description = "\(value)"
    }

    public init<T: Equatable & CustomStringConvertible>(_ value: T) {
        self.value = value
        self.equals = { ($0 as? T == value) }
        self.description = value.description
    }

    static public func == (lhs: AnyEquatable, rhs: AnyEquatable) -> Bool {
        return lhs.equals(rhs.value)
    }
}
