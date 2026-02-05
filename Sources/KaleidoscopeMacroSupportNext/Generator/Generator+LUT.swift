import SwiftSyntax

extension Generator {
    private func tableIdentifier(for index: Int) -> TokenSyntax {
        .identifier("_TABLE_\(index)")
    }

    mutating func addTestToLUT(byteClass: ByteClass) -> (tableIdent: TokenSyntax, mask: UInt8) {
        let tableBits = byteClassToTableBits(byteClass)

        let loopId: Int
        if let existing = loopMasks[tableBits] {
            loopId = existing
        } else {
            loopId = loopMasks.count
            loopMasks[tableBits] = loopId
        }

        let tableIndex = loopId / 8
        let bitPosition = loopId % 8

        return (
            tableIdent: tableIdentifier(for: tableIndex),
            mask: 1 << bitPosition,
        )
    }

    func renderLUT() -> CodeBlockItemListSyntax {
        let sortedLUTs = loopMasks.sorted { lhs, rhs in
            lhs.value < rhs.value
        }
        var result = CodeBlockItemListSyntax {}
        for (lutIndex, bitArrays) in sortedLUTs.chunk(size: 8).enumerated() {
            var bitValues = [UInt8](repeating: 0, count: 256)
            for (bitIndex, (bits, _)) in bitArrays.enumerated() {
                for (arrayIndex, bit) in bits.enumerated() where bit {
                    bitValues[arrayIndex] |= (1 as UInt8) << bitIndex
                }
            }

            let ident = tableIdentifier(for: lutIndex)
            result.append(contentsOf: CodeBlockItemListSyntax {
                let elements = ArrayElementListSyntax(expressions: bitValues.map { bits in
                    let integer = bits.binaryLiteral

                    return ExprSyntax(IntegerLiteralExprSyntax(literal: integer))
                })

                "let \(ident): InlineArray<256, UInt8> = [\(elements)]"
            })
        }

        return result
    }
}
