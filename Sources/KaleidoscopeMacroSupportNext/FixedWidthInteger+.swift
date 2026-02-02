import Foundation
import SwiftSyntax

extension Int {
    var hexString: String {
        String(format: "0x%X", self)
    }

    var hexLiteral: TokenSyntax {
        .integerLiteral(hexString)
    }
}
