import Foundation

// swiftlint:disable:next large_tuple
public func getUnicodeVersion() -> (major: UInt8, minor: UInt8, micro: UInt8, update: UInt8)? {
    typealias GetVersionFunc = @convention(c) (UnsafeMutablePointer<UInt8>) -> Void

    guard let handle = dlopen(nil, RTLD_NOW),
          let sym = dlsym(handle, "u_getUnicodeVersion") else {
        return nil
    }

    let getVersion = unsafeBitCast(sym, to: GetVersionFunc.self)
    var version: [UInt8] = [0, 0, 0, 0]
    getVersion(&version)

    return (major: version[0], minor: version[1], micro: version[2], update: version[3])
}

public let MAX_UNICODE_MAJOR: UInt8 = 16

public func unicodeVersionAllowed() -> Bool {
    guard let version = getUnicodeVersion() else {
        return false
    }
    return version.major <= MAX_UNICODE_MAJOR
}
