//
//  Utils.swift
//  kaleidoscope-lexer
//
//  Created by Larry Zeng on 1/20/26.
//
import CustomDump
import Testing

func equals<T: Equatable>(
    actual: T,
    expected: T,
    fileID: String = #fileID,
    filePath: String = #filePath,
    line: Int = #line,
    column: Int = #column,
) {
    #expect(
        actual == expected,
        {
            var expectedString = ""
            var actualString = ""
            customDump(expected, to: &expectedString)
            customDump(actual, to: &actualString)

            return """
            Expected
            \(expectedString)
            But got
            \(actualString)
            Diff
            \(diff(actualString, expectedString))
            """
        }(),
        sourceLocation: .init(
            fileID: fileID,
            filePath: filePath,
            line: line,
            column: column,
        ),
    )
}
