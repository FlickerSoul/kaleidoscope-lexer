//
//  RegexConversionError.swift
//  kaleidoscope-lexer
//
//  Created by Larry Zeng on 1/15/26.
//
import _RegexParser

public struct RegexConversionError: Error, CustomStringConvertible, @unchecked Sendable, Hashable {
    let kind: RegexConversionErrorKind
    let source: SourceLocation

    public var description: String {
        "\(kind). Location: \(source)"
    }
}

public enum RegexConversionErrorKind: Sendable, Hashable, CustomStringConvertible {
    case unsupportedConstruct(String)
    case quantifierNumberInvalid(String)
    case unavailable(String)
    case invalid(String)

    func toError(with location: SourceLocation) -> RegexConversionError {
        RegexConversionError(kind: self, source: location)
    }

    public var description: String {
        switch self {
        case let .unsupportedConstruct(reason):
            "Unsupported construct: \(reason)"
        case let .quantifierNumberInvalid(reason):
            "Invalid quantifier number: \(reason)"
        case let .unavailable(reason):
            "Unavailable currently, may be added in the future: \(reason)"
        case let .invalid(reason):
            "Invalid regex: \(reason)"
        }
    }
}

extension RegexConversionError {
    static func unsupportedConstruct(_ reason: String) -> RegexConversionErrorKind {
        .unsupportedConstruct(reason)
    }

    static func quantifierNumberInvalid(_ reason: String) -> RegexConversionErrorKind {
        .quantifierNumberInvalid(reason)
    }

    static func unavailable(_ reason: String) -> RegexConversionErrorKind {
        .unavailable(reason)
    }

    static func invalid(_ reason: String) -> RegexConversionErrorKind {
        .invalid(reason)
    }
}
