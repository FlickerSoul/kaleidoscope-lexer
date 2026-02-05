/// - Important: this is intended to be used only in generated code.
@inlinable
public func __apply<each E, R>(_ tuple: (repeat each E), on body: (repeat each E) -> R) -> R {
    body(repeat each tuple)
}
