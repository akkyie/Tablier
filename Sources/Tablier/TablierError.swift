public struct TablierError: Error {
    public let error: Error

    init(_ error: Error) {
        self.error = error
    }
}
