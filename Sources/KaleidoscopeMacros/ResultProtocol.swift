protocol ResultProtocol {
    associatedtype Failure: Error
    associatedtype Success

    func get() throws(Failure) -> Success
}

extension Result: ResultProtocol {}

extension Result {
    /// - Note: == doesn't work on parameter packs yet.
    /// - Important: This This requires that all the `others` have the same `Failure` type as `self`.
    func together<R, each T: ResultProtocol>(
        with others: repeat each T,
        compose: (Success, repeat (each T).Success) -> R,
    ) -> Result<R, Failure> {
        for failureCheck in repeat (each T).Failure.self == Failure.self {
            assert(failureCheck, "All ResultProtocol types must have the same Failure type")
        }

        do {
            let selfValue = try get()
            let otherValues = try (repeat (each others).get())
            return .success(compose(selfValue, repeat each otherValues))
        } catch {
            return .failure(error as! Failure) // swiftlint:disable:this force_cast
        }
    }
}
