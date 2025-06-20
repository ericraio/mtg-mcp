import Testing
@testable import Mulligan

struct StrategyTests {

    @Test func testValidateValidValues() {
        #expect(Strategy.validate("NEVER"))
        #expect(Strategy.validate("LONDON"))
    }

    @Test func testValidateInvalidValue() {
        #expect(!Strategy.validate("INVALID"))
        #expect(!Strategy.validate(""))
    }

    @Test func testSetValidValue() {
        let resultNever: (success: Bool, strategy: Strategy?) = Strategy.set(value: "NEVER")
        #expect(resultNever.success)
        #expect(resultNever.strategy == .never)

        let resultLondon: (success: Bool, strategy: Strategy?) = Strategy.set(value: "LONDON")
        #expect(resultLondon.success)
        #expect(resultLondon.strategy == .london)
    }

    @Test func testSetInvalidValue() {
        let result: (success: Bool, strategy: Strategy?) = Strategy.set(value: "INVALID")
        #expect(!result.success)
        #expect(result.strategy == nil)
    }

    @Test func testNewValidValue() {
        let sNever: Strategy? = Strategy.new("NEVER")
        #expect(sNever == .never)

        let sLondon: Strategy? = Strategy.new("LONDON")
        #expect(sLondon == .london)
    }

    @Test func testNewInvalidValue() {
        let s: Strategy? = Strategy.new("INVALID")
        #expect(s == nil)
    }
}
