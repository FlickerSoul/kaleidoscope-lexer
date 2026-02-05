import Foundation
import SwiftSyntax

extension FixedWidthInteger {
    var hexString: String {
        "0x\(String(self, radix: 16, uppercase: true))"
    }

    var hexLiteral: TokenSyntax {
        .integerLiteral(hexString)
    }
}

extension FixedWidthInteger {
    var binaryString: String {
        "0b\(String(self, radix: 2, uppercase: true))"
    }

    var binaryLiteral: TokenSyntax {
        .integerLiteral(binaryString)
    }
}
