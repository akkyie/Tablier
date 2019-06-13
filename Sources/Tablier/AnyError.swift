#if canImport(Result)
#else

public struct AnyError: Error {
    public let error: Error

    init(_ error: Error) {
        self.error = error
    }
}

#endif
