// - Important: this is intended to be used only in generated code.
@inlinable
public func __convertTupleToEnum<each E, R>(_ tuple: (repeat each E), converter: (repeat each E) -> R) -> R {
    converter(repeat each tuple)
}
