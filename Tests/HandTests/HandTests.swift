import Testing
import Card
@testable import Hand

struct HandTests {

    @Test func testSetOpeningAndDrawsSlices() {
        let land1 = Card.basicLand(name: "Land1")
        let land2 = Card.basicLand(name: "Land2")
        let rock = Card.manaRock(name: "Rock", manaCost: "{1}")
        let creature = Card.creature(name: "Creature", manaCost: "{2}")

        let hand = Hand()
        hand.setOpeningAndDraws(opening: [land1, rock], draws: [creature, land2])

        // Opening slice
        let opening = hand.opening()
        #expect(opening.count == 2)
        #expect(opening.map { $0.hash } == [land1.nameHash, rock.nameHash])

        // Draws slice
        let draws = hand.draws(drawCount: 2)
        #expect(draws.count == 2)
        #expect(draws.map { $0.hash } == [creature.nameHash, land2.nameHash])

        // Opening with draws
        let combined = hand.openingWithDraws(draws: 2)
        #expect(combined.count == 4)
    }

    @Test func testLandAndManaRockCounts() {
        let land = Card.basicLand(name: "L")
        let rock = Card.manaRock(name: "R", manaCost: "{1}")

        let hand = Hand()
        hand.setOpeningAndDraws(opening: [land, rock, land], draws: [])

        #expect(hand.landCount() == 2)
        #expect(hand.manaRockCount() == 1)
    }

    @Test func testAvailableManaSourcesByTurn() {
        let land = Card.basicLand(name: "L")
        let rock = Card.manaRock(name: "R", manaCost: "{1}")

        let hand = Hand()
        // 2 lands and 1 rock
        hand.setOpeningAndDraws(opening: [land, rock, land], draws: [])

        // Turn 1: only one land can tap
        #expect(hand.availableManaSourcesByTurn(turn: 1) == 1)

        // Turn 2: two lands
        #expect(hand.availableManaSourcesByTurn(turn: 2) == 3)

        // Turn 3: two lands + rock played on turn 2 = 3 sources
        #expect(hand.availableManaSourcesByTurn(turn: 3) == 3)
    }

    @Test func testCountInOpeningWithDrawsPredicate() {
        let land = Card.basicLand(name: "L")
        let creature = Card.creature(name: "C", manaCost: "{2}")

        let hand = Hand()
        hand.setOpeningAndDraws(opening: [land, creature], draws: [land, creature])

        // Count lands and creatures together
        let totalLands = hand.countInOpeningWithDraws(draws: 2) { $0.kind.isLand }
        #expect(totalLands == 2)

        let totalCreatures = hand.countInOpeningWithDraws(draws: 2) { $0.kind.isCreature }
        #expect(totalCreatures == 2)
    }
}
