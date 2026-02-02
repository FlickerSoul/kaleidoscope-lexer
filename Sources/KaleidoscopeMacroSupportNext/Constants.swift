import SwiftSyntax

public struct PackageEntity: CustomStringConvertible, Hashable, Sendable {
    public let prefix: String
    public let name: String

    init(prefix: String = Constants.packageName, name: String) {
        self.prefix = prefix
        self.name = name
    }

    public var qualifiedName: String {
        "\(prefix).\(name)"
    }

    public var description: String {
        qualifiedName
    }
}

public enum Constants {
    public static let packageName = "KaleidoscopeLexer"

    public enum Macro {
        public static let kaleidoscope = PackageEntity(name: "Kaleidoscope")
        public static let regex = PackageEntity(name: "regex")
        public static let token = PackageEntity(name: "token")
        public static let skip = PackageEntity(name: "skip")
    }

    public enum MacroArgument {
        public static let priority = "priority"
        public static let callback = "callback"
    }

    public enum Types {
        public static let lexerTokenProtocol = PackageEntity(name: "LexerTokenProtocol")
        public static let lexerMachine = PackageEntity(name: "LexerMachine")
        public static let callbackResult = PackageEntity(name: "_CallbackResult")
        public static let skipResult = PackageEntity(name: "_SkipResult")
        public static let skipResultSource = PackageEntity(name: "_SkipResultSource")
        public static let lexerError: TokenSyntax = .identifier("LexerError")
        public static let lexerOutput: TokenSyntax = .identifier("LexerOutput")
    }

    public enum Helpers {
        public static let __convertTupleToEnum: TokenSyntax = .identifier("__convertTupleToEnum")
    }

    public enum MacroConfiguration {
        public static let useStateMachineCodegen = "useStateMachineCodegen"
    }
}
