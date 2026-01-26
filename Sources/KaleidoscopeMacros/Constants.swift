struct PackageEntity: CustomStringConvertible, Hashable {
    let prefix: String
    let name: String

    init(prefix: String = Constants.packageName, name: String) {
        self.prefix = prefix
        self.name = name
    }

    var qualifiedName: String {
        "\(prefix).\(name)"
    }

    var description: String {
        qualifiedName
    }
}

enum Constants {
    static let packageName = "Kaleidoscope"

    enum Macro {
        static let kaleidoscope = PackageEntity(name: "kaleidoscope")
        static let regex = PackageEntity(name: "regex")
        static let token = PackageEntity(name: "token")
        static let skip = PackageEntity(name: "skip")
    }

    enum MacroArgument {
        static let priority = "priority"
        static let callback = "callback"
    }

    enum Types {
        static let lexerProtocol = PackageEntity(name: "LexerProtocol")
        static let lexerMachine = PackageEntity(name: "LexerMachine")
    }
}
