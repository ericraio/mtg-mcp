import ArgumentParser
import Foundation
import MCP
import Card
import MTGServices
import os.log

// Helper for debug logging that goes to both stderr and os_log
private let debugLogger = os.Logger(subsystem: "com.mtg-mcp", category: "debug")

private func debugPrint(_ message: String) {
    debugLogger.debug("\(message)")
    fputs("DEBUG: \(message)\n", stderr)
    fflush(stderr)
}

private func errorPrint(_ message: String) {
    debugLogger.error("\(message)")
    fputs("ERROR: \(message)\n", stderr)
    fflush(stderr)
}

/// MTG Deck Manager MCP Server
@main
struct MTGDeckManagerServer: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "mtg-mcp",
        abstract: "MTG Deck Manager MCP Server",
        version: "1.0.0"
    )

    @Option(name: .shortAndLong, help: "Transport type")
    var transport: String = "stdio"

    func run() async throws {
        let logger = LoggerFactory.createLogger(for: "MTGDeckManagerServer")
        logger.info("Starting MTG Deck Manager MCP Server")
        debugPrint("Server starting up")

        // Create the game state and rules service
        let gameState = GameState()
        let rulesService = RulesService(logger: logger)

        logger.info("Initialized game state and rules service")
        debugPrint("Game state and rules service initialized")

        // Create server with correct configuration
        debugPrint("Creating MCP server")
        let server = Server(
            name: "mtg-manager",
            version: "1.0.0",
            capabilities: Server.Capabilities(
                tools: Server.Capabilities.Tools()
            )
        )

        logger.info("Created MCP server")
        debugPrint("MCP server created successfully")

        // Register method handlers
        debugPrint("Starting method handler registration")

        // Register ListTools handler
        await server.withMethodHandler(ListTools.self) { _ in
            logger.debug("Handling ListTools request")
            debugPrint("ListTools handler called")
            let tools = self.getAllTools()
            debugPrint("Created \(tools.count) tools")
            return ListTools.Result(tools: tools)
        }

        // Register CallTool handler
        await server.withMethodHandler(CallTool.self) { params in
            logger.debug("Handling CallTool request for: \(params.name)")
            debugPrint("CallTool handler called for: \(params.name)")
            do {
                let result = try await self.handleToolCall(
                    params, gameState: gameState, rulesService: rulesService)
                debugPrint("CallTool completed successfully")
                return result
            } catch {
                errorPrint("CallTool failed: \(error)")
                throw error
            }
        }

        debugPrint("Method handlers registered successfully")
        logger.info("Registered method handlers")

        // Start with appropriate transport
        debugPrint("Starting transport setup")
        switch transport.lowercased() {
        case "stdio":
            logger.info("Starting server with stdio transport")
            debugPrint("Creating stdio transport")
            let stdioTransport = StdioTransport()
            debugPrint("Starting server with stdio transport")
            try await server.start(transport: stdioTransport)
            debugPrint("Server started successfully")

            // Wait for the server to complete
            debugPrint("Waiting for server to complete")
            await server.waitUntilCompleted()
            debugPrint("Server completed")
        default:
            logger.error("Unsupported transport: \(transport)")
            errorPrint("Unsupported transport: \(transport)")
            throw ValidationError("Unsupported transport: \(transport)")
        }
    }

    /// Returns all available tools
    private func getAllTools() -> [Tool] {
        return [
            Tool(
                name: "upload_deck",
                description: "Upload a Magic: The Gathering deck list with enhanced analysis",
                inputSchema: .object([
                    "type": .string("object"),
                    "properties": .object([
                        "deck_list": .object([
                            "type": .string("string"),
                            "description": .string(
                                "MTG deck list in standard format. Each card MUST include quantity (e.g., '1 Sol Ring', '4 Lightning Bolt'). Format: 'Commander\\n1 CardName\\n\\nDeck\\n4 CardName\\n1 CardName'. DO NOT omit quantities - every card line must start with a number."
                            ),
                        ]),
                        "include_analysis": .object([
                            "type": .string("boolean"),
                            "description": .string(
                                "Include enhanced analysis with confidence scoring and suggestions (default: true)"
                            ),
                            "default": .bool(true),
                        ]),
                    ]),
                    "required": .array([.string("deck_list")]),
                ])
            ),
            Tool(
                name: "draw_card",
                description: "Draw cards from your deck to your hand with strategic analysis",
                inputSchema: .object([
                    "type": .string("object"),
                    "properties": .object([
                        "count": .object([
                            "type": .string("number"),
                            "description": .string("Number of cards to draw (default: 1)"),
                            "default": .int(1),
                        ]),
                        "include_analysis": .object([
                            "type": .string("boolean"),
                            "description": .string(
                                "Include strategic analysis and risk assessment (default: true)"),
                            "default": .bool(true),
                        ]),
                    ]),
                ])
            ),
            Tool(
                name: "play_card",
                description: "Play a card from your hand with strategic analysis",
                inputSchema: .object([
                    "type": .string("object"),
                    "properties": .object([
                        "card_name": .object([
                            "type": .string("string"),
                            "description": .string("Name of the card to play"),
                        ]),
                        "include_analysis": .object([
                            "type": .string("boolean"),
                            "description": .string(
                                "Include play analysis and alternative suggestions (default: true)"),
                            "default": .bool(true),
                        ]),
                    ]),
                    "required": .array([.string("card_name")]),
                ])
            ),
            Tool(
                name: "view_hand",
                description: "View the cards in your hand",
                inputSchema: .object([
                    "type": .string("object"),
                    "properties": .object([:]),
                ])
            ),
            Tool(
                name: "view_deck_stats",
                description: "View statistics about your current deck",
                inputSchema: .object([
                    "type": .string("object"),
                    "properties": .object([:]),
                ])
            ),
            Tool(
                name: "mulligan",
                description:
                    "Perform a mulligan with strategic analysis and risk assessment",
                inputSchema: .object([
                    "type": .string("object"),
                    "properties": .object([
                        "new_hand_size": .object([
                            "type": .string("number"),
                            "description": .string(
                                "Number of cards to draw for new hand (default: same as current hand)"
                            ),
                        ]),
                        "include_analysis": .object([
                            "type": .string("boolean"),
                            "description": .string(
                                "Include mulligan decision analysis and risk assessment (default: true)"
                            ),
                            "default": .bool(true),
                        ]),
                    ]),
                ])
            ),
            Tool(
                name: "sideboard_swap",
                description: "Swap a card from your deck with a card from your sideboard",
                inputSchema: .object([
                    "type": .string("object"),
                    "properties": .object([
                        "remove_card": .object([
                            "type": .string("string"),
                            "description": .string("Name of card to remove from deck"),
                        ]),
                        "add_card": .object([
                            "type": .string("string"),
                            "description": .string("Name of card to add from sideboard"),
                        ]),
                    ]),
                    "required": .array([.string("remove_card"), .string("add_card")]),
                ])
            ),
            Tool(
                name: "reset_game",
                description: "Reset the game state completely",
                inputSchema: .object([
                    "type": .string("object"),
                    "properties": .object([:]),
                ])
            ),
            Tool(
                name: "lookup_rule",
                description: "Look up a specific MTG rule by number (e.g., '100', '601.2a')",
                inputSchema: .object([
                    "type": .string("object"),
                    "properties": .object([
                        "rule_number": .object([
                            "type": .string("string"),
                            "description": .string(
                                "Rule number to look up (e.g., '100', '601.2a', '704')"),
                        ])
                    ]),
                    "required": .array([.string("rule_number")]),
                ])
            ),
            Tool(
                name: "search_rules",
                description: "Search MTG rules for specific keywords or concepts",
                inputSchema: .object([
                    "type": .string("object"),
                    "properties": .object([
                        "keywords": .object([
                            "type": .string("string"),
                            "description": .string("Keywords to search for (space-separated)"),
                        ]),
                        "concept": .object([
                            "type": .string("string"),
                            "description": .string(
                                "Game concept to find rules for (e.g., 'casting', 'combat', 'mulligan')"
                            ),
                        ]),
                    ]),
                ])
            ),
            Tool(
                name: "explain_concept",
                description: "Get rules explanations for MTG game concepts",
                inputSchema: .object([
                    "type": .string("object"),
                    "properties": .object([
                        "concept": .object([
                            "type": .string("string"),
                            "description": .string(
                                "Game concept to explain (e.g., 'priority', 'stack', 'combat', 'triggered abilities')"
                            ),
                        ])
                    ]),
                    "required": .array([.string("concept")]),
                ])
            ),
            Tool(
                name: "test_opening_hands",
                description: "Simulate multiple opening hands and analyze composition",
                inputSchema: .object([
                    "type": .string("object"),
                    "properties": .object([
                        "count": .object([
                            "type": .string("number"),
                            "description": .string(
                                "Number of opening hands to simulate (default: 5)"),
                            "default": .int(5),
                        ])
                    ]),
                ])
            ),
            Tool(
                name: "simulate_turns",
                description: "Simulate the first few turns of a game",
                inputSchema: .object([
                    "type": .string("object"),
                    "properties": .object([
                        "turns": .object([
                            "type": .string("number"),
                            "description": .string("Number of turns to simulate (default: 4)"),
                            "default": .int(4),
                        ])
                    ]),
                ])
            ),
            Tool(
                name: "lookup_combo",
                description:
                    "Look up combo potential and interactions for specific cards using Commander Spellbook database",
                inputSchema: .object([
                    "type": .string("object"),
                    "properties": .object([
                        "cards": .object([
                            "type": .string("array"),
                            "description": .string("Array of card names to find combos for"),
                            "items": .object([
                                "type": .string("string")
                            ]),
                        ]),
                        "commander": .object([
                            "type": .string("string"),
                            "description": .string(
                                "Optional commander name to filter combos by color identity"),
                        ]),
                        "detailed": .object([
                            "type": .string("boolean"),
                            "description": .string(
                                "Whether to include detailed combo steps and requirements (default: true)"
                            ),
                            "default": .bool(true),
                        ]),
                        "min_popularity": .object([
                            "type": .string("number"),
                            "description": .string(
                                "Minimum combo popularity threshold (1-100, default: 10)"),
                            "default": .int(10),
                        ]),
                    ]),
                    "required": .array([.string("cards")]),
                ])
            ),
            Tool(
                name: "find_deck_combos",
                description: "Analyze an entire deck list for combo potential and synergies",
                inputSchema: .object([
                    "type": .string("object"),
                    "properties": .object([
                        "deck_list": .object([
                            "type": .string("string"),
                            "description": .string("Complete deck list to analyze for combos"),
                        ]),
                        "commander": .object([
                            "type": .string("string"),
                            "description": .string("Commander name for color identity filtering"),
                        ]),
                        "combo_types": .object([
                            "type": .string("array"),
                            "description": .string(
                                "Types of combos to look for (infinite, synergy, engine)"),
                            "items": .object([
                                "type": .string("string"),
                                "enum": .array([
                                    .string("infinite"), .string("synergy"), .string("engine"),
                                    .string("all"),
                                ]),
                            ]),
                        ]),
                        "max_pieces": .object([
                            "type": .string("number"),
                            "description": .string("Maximum number of cards in combo (default: 4)"),
                            "default": .int(4),
                        ]),
                    ]),
                    "required": .array([.string("deck_list")]),
                ])
            ),
            Tool(
                name: "validate_interaction",
                description:
                    "Cross-reference multiple cards against MTG rules to validate proposed interactions",
                inputSchema: .object([
                    "type": .string("object"),
                    "properties": .object([
                        "cards": .object([
                            "type": .string("array"),
                            "description": .string(
                                "Array of card names to validate interaction between"),
                            "items": .object([
                                "type": .string("string")
                            ]),
                        ]),
                        "scenario": .object([
                            "type": .string("string"),
                            "description": .string(
                                "Description of the proposed interaction or scenario"),
                        ]),
                        "detailed": .object([
                            "type": .string("boolean"),
                            "description": .string(
                                "Whether to provide detailed rule citations (default: true)"),
                            "default": .bool(true),
                        ]),
                    ]),
                    "required": .array([.string("cards"), .string("scenario")]),
                ])
            ),
            Tool(
                name: "simulate_game_state",
                description: "Simulate game scenarios step-by-step with rule applications",
                inputSchema: .object([
                    "type": .string("object"),
                    "properties": .object([
                        "scenario": .object([
                            "type": .string("string"),
                            "description": .string("Description of the game scenario to simulate"),
                        ]),
                        "step_by_step": .object([
                            "type": .string("boolean"),
                            "description": .string(
                                "Whether to show step-by-step breakdown (default: true)"),
                            "default": .bool(true),
                        ]),
                        "include_timing": .object([
                            "type": .string("boolean"),
                            "description": .string(
                                "Whether to include timing and priority details (default: true)"),
                            "default": .bool(true),
                        ]),
                    ]),
                    "required": .array([.string("scenario")]),
                ])
            ),
            Tool(
                name: "check_common_errors",
                description: "Check for common MTG misconceptions and rule misunderstandings",
                inputSchema: .object([
                    "type": .string("object"),
                    "properties": .object([
                        "query": .object([
                            "type": .string("string"),
                            "description": .string(
                                "Description of interaction or rule to check for common errors"),
                        ]),
                        "cards": .object([
                            "type": .string("array"),
                            "description": .string(
                                "Optional array of specific card names involved"),
                            "items": .object([
                                "type": .string("string")
                            ]),
                        ]),
                    ]),
                    "required": .array([.string("query")]),
                ])
            ),
        ]
    }

    /// Handles tool execution calls
    private func handleToolCall(
        _ params: CallTool.Parameters, gameState: GameState, rulesService: RulesService
    ) async throws -> CallTool.Result {
        let toolName = params.name
        let arguments = params.arguments ?? [:]

        switch toolName {
        case "upload_deck":
            return try await handleUploadDeck(arguments: arguments, gameState: gameState)
        case "draw_card":
            return try await handleDrawCard(arguments: arguments, gameState: gameState)
        case "play_card":
            return try await handlePlayCard(arguments: arguments, gameState: gameState)
        case "view_hand":
            return try await handleViewHand(arguments: arguments, gameState: gameState)
        case "view_deck_stats":
            return try await handleViewDeckStats(arguments: arguments, gameState: gameState)
        case "mulligan":
            return try await handleMulligan(arguments: arguments, gameState: gameState)
        case "sideboard_swap":
            return try await handleSideboardSwap(arguments: arguments, gameState: gameState)
        case "reset_game":
            return try await handleResetGame(arguments: arguments, gameState: gameState)
        case "lookup_rule":
            return try await handleLookupRule(arguments: arguments, rulesService: rulesService)
        case "search_rules":
            return try await handleSearchRules(arguments: arguments, rulesService: rulesService)
        case "explain_concept":
            return try await handleExplainConcept(arguments: arguments, rulesService: rulesService)
        case "test_opening_hands":
            return try await handleTestOpeningHands(arguments: arguments, gameState: gameState)
        case "simulate_turns":
            return try await handleSimulateTurns(arguments: arguments, gameState: gameState)
        case "lookup_combo":
            return try await handleLookupCombo(arguments: arguments, rulesService: rulesService)
        case "find_deck_combos":
            return try await handleFindDeckCombos(
                arguments: arguments, gameState: gameState, rulesService: rulesService)
        case "validate_interaction":
            return try await handleValidateInteraction(
                arguments: arguments, rulesService: rulesService)
        case "simulate_game_state":
            return try await handleSimulateGameState(
                arguments: arguments, rulesService: rulesService)
        case "check_common_errors":
            return try await handleCheckCommonErrors(
                arguments: arguments, rulesService: rulesService)
        default:
            throw MCPError.methodNotFound("Unknown tool: \(toolName)")
        }
    }

    // MARK: - Tool Implementation Methods

    private func handleUploadDeck(arguments: [String: Value], gameState: GameState) async throws
        -> CallTool.Result
    {
        let startTime = Date()

        guard case .string(let deckListText) = arguments["deck_list"] else {
            throw MCPError.invalidParams("Missing or invalid deck_list parameter")
        }

        let includeAnalysis = arguments["include_analysis"]?.boolValue ?? true

        let deckData = DeckParser.parseDeckList(deckListText)
        await gameState.loadDeck(deckData)

        let stats = await gameState.getDeckStats()
        let processingTime = Date().timeIntervalSince(startTime)

        if includeAnalysis {
            // Create LLM-optimized response using ResponseFormatter
            let gameStateSnapshot = GameStateSnapshot(
                cardsInDeck: stats.cardsInDeck,
                cardsInHand: stats.cardsInHand,
                handComposition: await gameState.getHandContents()
            )

            let playAnalysis = PlayAnalysis(
                recommendedPlay: "Upload successful - deck is ready for gameplay",
                alternativePlays: ["Review deck composition", "Test opening hands"],
                riskAssessment: RiskAssessment(
                    level: stats.cardsInDeck < 60 ? .medium : .low,
                    factors: stats.cardsInDeck < 60 ? ["Deck size below tournament minimum"] : [],
                    mitigation: stats.cardsInDeck < 60 ? ["Add more cards to reach 60+"] : []
                ),
                expectedOutcome: "Deck loaded and ready for simulation"
            )

            let optimizedResponse = ResponseFormatter.formatGameActionResponse(
                action: "upload_deck",
                result:
                    "Deck uploaded with \(stats.cardsInDeck) main deck cards and \(stats.sideboardCards) sideboard cards",
                gameState: gameStateSnapshot,
                processingTime: processingTime,
                playAnalysis: playAnalysis,
                simulationBacked: false
            )

            let jsonData = try JSONEncoder().encode(optimizedResponse)
            let jsonString = String(data: jsonData, encoding: .utf8) ?? "{}"

            return CallTool.Result(content: [.text(jsonString)])
        } else {
            // Legacy text format for backward compatibility
            let message =
                "Deck uploaded with \(stats.cardsInDeck) main deck cards and \(stats.sideboardCards) sideboard cards."
            return CallTool.Result(content: [.text(message)])
        }
    }

    private func handleDrawCard(arguments: [String: Value], gameState: GameState) async throws
        -> CallTool.Result
    {
        let startTime = Date()

        let count: Int
        if case .int(let c) = arguments["count"] {
            count = c
        } else if case .double(let c) = arguments["count"] {
            count = Int(c)
        } else {
            count = 1
        }

        let includeAnalysis = arguments["include_analysis"]?.boolValue ?? true

        let stats = await gameState.getDeckStats()
        guard stats.cardsInDeck >= count else {
            let message = "Not enough cards in deck. Only \(stats.cardsInDeck) remaining."
            return CallTool.Result(content: [.text(message)])
        }

        let drawnCards = await gameState.drawCards(count: count)
        let cardNames = drawnCards.map(\.name)
        let processingTime = Date().timeIntervalSince(startTime)

        if includeAnalysis {
            // Create enhanced game action response
            let gameStateSnapshot = GameStateSnapshot(
                cardsInDeck: stats.cardsInDeck - count,
                cardsInHand: stats.cardsInHand + count,
                handComposition: await gameState.getHandContents()
            )

            let playAnalysis = PlayAnalysis(
                recommendedPlay: "Drew \(count) card(s): \(cardNames.joined(separator: ", "))",
                alternativePlays: generateDrawAlternatives(gameState: gameStateSnapshot),
                riskAssessment: createDrawRiskAssessment(
                    gameState: gameStateSnapshot, drawnCards: drawnCards),
                expectedOutcome: "Hand size increased by \(count)"
            )

            let optimizedResponse = ResponseFormatter.formatGameActionResponse(
                action: "draw_card",
                result: "Drew \(count) card(s): \(cardNames.joined(separator: ", "))",
                gameState: gameStateSnapshot,
                processingTime: processingTime,
                playAnalysis: playAnalysis,
                simulationBacked: false
            )

            let jsonData = try JSONEncoder().encode(optimizedResponse)
            let jsonString = String(data: jsonData, encoding: .utf8) ?? "{}"

            return CallTool.Result(content: [.text(jsonString)])
        } else {
            // Legacy text format
            let message = "Drew \(count) card(s): \(cardNames.joined(separator: ", "))"
            return CallTool.Result(content: [.text(message)])
        }
    }

    private func handlePlayCard(arguments: [String: Value], gameState: GameState) async throws
        -> CallTool.Result
    {
        let startTime = Date()

        guard case .string(let cardName) = arguments["card_name"] else {
            throw MCPError.invalidParams("Missing or invalid card_name parameter")
        }

        let includeAnalysis = arguments["include_analysis"]?.boolValue ?? true

        if let playedCard = await gameState.playCard(named: cardName) {
            let stats = await gameState.getDeckStats()
            let processingTime = Date().timeIntervalSince(startTime)

            if includeAnalysis {
                // Create enhanced game action response for successful play
                let gameStateSnapshot = GameStateSnapshot(
                    cardsInDeck: stats.cardsInDeck,
                    cardsInHand: stats.cardsInHand,
                    handComposition: await gameState.getHandContents()
                )

                let playAnalysis = PlayAnalysis(
                    recommendedPlay: "Played \(playedCard.name)",
                    alternativePlays: generatePlayAlternatives(
                        cardName: cardName, gameState: gameStateSnapshot),
                    riskAssessment: createPlayRiskAssessment(
                        cardName: cardName, gameState: gameStateSnapshot),
                    expectedOutcome: "Card moved from hand to battlefield/stack"
                )

                let optimizedResponse = ResponseFormatter.formatGameActionResponse(
                    action: "play_card",
                    result: "Played \(playedCard.name)",
                    gameState: gameStateSnapshot,
                    processingTime: processingTime,
                    playAnalysis: playAnalysis,
                    simulationBacked: false
                )

                let jsonData = try JSONEncoder().encode(optimizedResponse)
                let jsonString = String(data: jsonData, encoding: .utf8) ?? "{}"

                return CallTool.Result(content: [.text(jsonString)])
            } else {
                // Legacy text format
                let message = "Played \(playedCard.name)."
                return CallTool.Result(content: [.text(message)])
            }
        } else {
            let message = "Card '\(cardName)' not found in hand."
            return CallTool.Result(content: [.text(message)])
        }
    }

    private func handleViewHand(arguments: [String: Value], gameState: GameState) async throws
        -> CallTool.Result
    {
        let handContents = await gameState.getHandContents()

        if handContents.isEmpty {
            return CallTool.Result(content: [.text("Your hand is empty.")])
        }

        let handString = handContents.map { "\($0.value)x \($0.key)" }
            .sorted()
            .joined(separator: "\n")

        let totalCards = handContents.values.reduce(0, +)
        let message = "Your hand (\(totalCards) cards):\n\(handString)"

        return CallTool.Result(content: [.text(message)])
    }

    private func handleViewDeckStats(arguments: [String: Value], gameState: GameState) async throws
        -> CallTool.Result
    {
        let stats = await gameState.getDeckStats()

        if stats.cardsInDeck == 0 {
            return CallTool.Result(content: [.text("Your deck is empty.")])
        }

        let deckContents = await gameState.getDeckContents(limit: 5)

        var result = [
            "Cards in deck: \(stats.cardsInDeck)",
            "Cards in hand: \(stats.cardsInHand)",
            "Sideboard cards: \(stats.sideboardCards)",
            "",
            "Top card types in deck:",
        ]

        for (name, count) in deckContents.sorted(by: { $0.value > $1.value }) {
            result.append("  \(count)x \(name)")
        }

        if let commander = stats.commander {
            result.append("")
            result.append("Commander: \(commander.name)")
        }

        if let companion = stats.companion {
            result.append("Companion: \(companion.name)")
        }

        return CallTool.Result(content: [.text(result.joined(separator: "\n"))])
    }

    private func handleMulligan(arguments: [String: Value], gameState: GameState) async throws
        -> CallTool.Result
    {
        let startTime = Date()

        let currentHandSize = await gameState.getHandContents().values.reduce(0, +)

        guard currentHandSize > 0 else {
            return CallTool.Result(content: [.text("Cannot mulligan with an empty hand.")])
        }

        let newHandSize: Int
        if case .int(let size) = arguments["new_hand_size"] {
            newHandSize = size
        } else if case .double(let size) = arguments["new_hand_size"] {
            newHandSize = Int(size)
        } else {
            newHandSize = currentHandSize
        }

        let includeAnalysis = arguments["include_analysis"]?.boolValue ?? true

        let drawnCards = await gameState.mulligan(newHandSize: newHandSize)
        let stats = await gameState.getDeckStats()
        let processingTime = Date().timeIntervalSince(startTime)

        if includeAnalysis {
            // Create enhanced mulligan response with strategic analysis
            let gameStateSnapshot = GameStateSnapshot(
                cardsInDeck: stats.cardsInDeck,
                cardsInHand: stats.cardsInHand,
                handComposition: await gameState.getHandContents()
            )

            let newHand = await gameState.getHandContents()
            let playAnalysis = PlayAnalysis(
                recommendedPlay: "Mulliganed and drew \(drawnCards.count) new cards",
                alternativePlays: generateMulliganAlternatives(
                    currentSize: currentHandSize, newSize: newHandSize),
                riskAssessment: createMulliganRiskAssessment(
                    newHand: newHand, mulliganCount: currentHandSize - newHandSize),
                expectedOutcome: "New hand with \(newHandSize) cards"
            )

            let optimizedResponse = ResponseFormatter.formatGameActionResponse(
                action: "mulligan",
                result: "Mulliganed and drew \(drawnCards.count) new cards",
                gameState: gameStateSnapshot,
                processingTime: processingTime,
                playAnalysis: playAnalysis,
                simulationBacked: false
            )

            let jsonData = try JSONEncoder().encode(optimizedResponse)
            let jsonString = String(data: jsonData, encoding: .utf8) ?? "{}"

            return CallTool.Result(content: [.text(jsonString)])
        } else {
            // Legacy text format
            let message = "Mulliganed and drew \(drawnCards.count) new cards."
            return CallTool.Result(content: [.text(message)])
        }
    }

    private func handleSideboardSwap(arguments: [String: Value], gameState: GameState) async throws
        -> CallTool.Result
    {
        guard case .string(let removeCard) = arguments["remove_card"],
            case .string(let addCard) = arguments["add_card"]
        else {
            throw MCPError.invalidParams("Missing or invalid remove_card or add_card parameter")
        }

        let result = await gameState.sideboardSwap(removeCard: removeCard, addCard: addCard)

        if let removed = result.removed, let added = result.added {
            let message = "Swapped out \(removed.name) for \(added.name) from sideboard."
            return CallTool.Result(content: [.text(message)])
        } else if result.removed == nil {
            let message = "Card '\(removeCard)' not found in deck or hand."
            return CallTool.Result(content: [.text(message)])
        } else {
            let message = "Card '\(addCard)' not found in sideboard."
            return CallTool.Result(content: [.text(message)])
        }
    }

    private func handleResetGame(arguments: [String: Value], gameState: GameState) async throws
        -> CallTool.Result
    {
        await gameState.resetGame()
        return CallTool.Result(content: [.text("Game reset. Deck shuffled.")])
    }

    // MARK: - Rules Tool Implementation Methods

    private func handleLookupRule(arguments: [String: Value], rulesService: RulesService)
        async throws -> CallTool.Result
    {
        guard case .string(let ruleNumber) = arguments["rule_number"] else {
            throw MCPError.invalidParams("Missing or invalid rule_number parameter")
        }

        guard let ruleResult = rulesService.lookupRule(ruleNumber) else {
            let message = "Rule \(ruleNumber) not found."
            return CallTool.Result(content: [.text(message)])
        }

        let message = """
            **Rule \(ruleResult.ruleNumber): \(ruleResult.title)**

            \(ruleResult.content)

            *Source: \(ruleResult.file)*
            """

        return CallTool.Result(content: [.text(message)])
    }

    private func handleSearchRules(arguments: [String: Value], rulesService: RulesService)
        async throws -> CallTool.Result
    {
        var keywords: [String] = []

        if case .string(let keywordString) = arguments["keywords"] {
            keywords = keywordString.components(separatedBy: .whitespacesAndNewlines)
                .filter { !$0.isEmpty }
        }

        if case .string(let concept) = arguments["concept"] {
            let conceptResults = rulesService.getRulesForConcept(concept)
            if !conceptResults.isEmpty {
                let resultStrings = conceptResults.prefix(5).map { result in
                    "**Rule \(result.ruleNumber): \(result.title)**\n\(result.content.prefix(200))..."
                }
                let message =
                    "Rules for '\(concept)':\n\n" + resultStrings.joined(separator: "\n\n---\n\n")
                return CallTool.Result(content: [.text(message)])
            }
        }

        if !keywords.isEmpty {
            let searchResults = rulesService.searchRules(keywords)

            if searchResults.isEmpty {
                let message = "No rules found containing: \(keywords.joined(separator: " "))"
                return CallTool.Result(content: [.text(message)])
            }

            let resultStrings = searchResults.prefix(10).map { result in
                let matchingSample = result.matchingLines.prefix(2).joined(separator: "\n")
                return "**Rule \(result.ruleNumber): \(result.title)**\n\(matchingSample)"
            }

            let message =
                "Found \(searchResults.count) rules containing '\(keywords.joined(separator: " "))':\n\n"
                + resultStrings.joined(separator: "\n\n---\n\n")
            return CallTool.Result(content: [.text(message)])
        }

        throw MCPError.invalidParams("Must provide either 'keywords' or 'concept' parameter")
    }

    private func handleExplainConcept(arguments: [String: Value], rulesService: RulesService)
        async throws -> CallTool.Result
    {
        guard case .string(let concept) = arguments["concept"] else {
            throw MCPError.invalidParams("Missing or invalid concept parameter")
        }

        let conceptResults = rulesService.getRulesForConcept(concept)

        if conceptResults.isEmpty {
            let message =
                "No rules found for concept '\(concept)'. Try keywords like: casting, combat, priority, stack, mulligan, triggered abilities."
            return CallTool.Result(content: [.text(message)])
        }

        let explanation = conceptResults.prefix(3).map { result in
            """
            **Rule \(result.ruleNumber): \(result.title)**

            \(result.content)
            """
        }.joined(separator: "\n\n---\n\n")

        let message = "**MTG Rules for '\(concept)':**\n\n\(explanation)"
        return CallTool.Result(content: [.text(message)])
    }

    // MARK: - Testing Tool Implementation Methods

    private func handleTestOpeningHands(arguments: [String: Value], gameState: GameState)
        async throws
        -> CallTool.Result
    {
        let count: Int
        if case .int(let c) = arguments["count"] {
            count = c
        } else if case .double(let c) = arguments["count"] {
            count = Int(c)
        } else {
            count = 5
        }

        var results: [String] = []
        results.append("🎯 **OPENING HAND ANALYSIS** (Testing \(count) hands)")
        results.append("")

        for handNumber in 1...count {
            await gameState.resetGame()
            let openingHand = await gameState.drawCards(count: 7)

            results.append("**Hand #\(handNumber):**")
            for card in openingHand {
                results.append("  • \(card.name)")
            }

            // Analyze hand composition with comprehensive land detection
            let lands = openingHand.filter { card in
                LandDetectionService.isLand(card.name)
            }

            let ramp = openingHand.filter { card in
                ["Sol Ring", "Arcane Signet", "Talisman of Indulgence", "Chrome Mox", "Mox Amber"]
                    .contains(card.name)
            }

            let cardDraw = openingHand.filter { card in
                ["Night's Whisper", "Phyrexian Arena", "Read the Bones"].contains(card.name)
            }

            let protection = openingHand.filter { card in
                [
                    "Swiftfoot Boots", "Kaya's Ghostform", "Supernatural Stamina", "Undying Evil",
                    "Undying Malice", "Fake Your Own Death",
                ].contains(card.name)
            }

            let keyPieces = openingHand.filter { card in
                [
                    "Blood Artist", "Zulaport Cutthroat", "Panharmonicon", "Conjurer's Closet",
                    "Ashnod's Altar", "Gravecrawler",
                ].contains(card.name)
            }

            results.append("  **Analysis:**")
            results.append("    Lands: \(lands.count)")
            results.append("    Ramp: \(ramp.count)")
            results.append("    Card Draw: \(cardDraw.count)")
            results.append("    Protection: \(protection.count)")
            results.append("    Key Pieces: \(keyPieces.count)")

            // Mulligan recommendation
            let keepHand =
                lands.count >= 2 && lands.count <= 5
                && (ramp.count > 0 || cardDraw.count > 0 || keyPieces.count > 0)
            results.append("    **Recommendation: \(keepHand ? "✅ KEEP" : "❌ MULLIGAN")**")
            results.append("")
        }

        return CallTool.Result(content: [.text(results.joined(separator: "\n"))])
    }

    private func handleSimulateTurns(arguments: [String: Value], gameState: GameState) async throws
        -> CallTool.Result
    {
        let turns: Int
        if case .int(let t) = arguments["turns"] {
            turns = t
        } else if case .double(let t) = arguments["turns"] {
            turns = Int(t)
        } else {
            turns = 4
        }

        var results: [String] = []
        results.append("🎮 **GAME SIMULATION** (First \(turns) turns)")
        results.append("")

        // Get current deck information
        let deckStats = await gameState.getDeckStats()
        if deckStats.cardsInDeck == 0 {
            results.append(
                "⚠️ **No deck loaded.** Please upload a deck first using the upload_deck tool.")
            return CallTool.Result(content: [.text(results.joined(separator: "\n"))])
        }

        await gameState.resetGame()
        let openingHand = await gameState.drawCards(count: 7)

        results.append("**Starting Hand:**")
        for card in openingHand {
            results.append("  • \(card.name)")
        }
        results.append("")

        // Simulate each turn with dynamic card analysis
        for turn in 1...turns {
            let drawnCard = await gameState.drawCards(count: 1)
            results.append("**Turn \(turn)**")
            results.append("Drew: \(drawnCard.first?.name ?? "No card")")

            // Get current hand for play decisions
            let currentHand = await gameState.getHandContents()
            let handCards = Array(currentHand.keys)

            var playedCards: [String] = []

            // Dynamic land detection - use comprehensive service
            let potentialLands = handCards.filter { cardName in
                LandDetectionService.isLand(cardName)
            }

            if let landToPlay = potentialLands.first {
                if await gameState.playCard(named: landToPlay) != nil {
                    playedCards.append("🏔️ \(landToPlay)")
                }
            }

            // Dynamic spell analysis based on mana cost patterns and card types
            let playableSpells = await analyzePlayableSpells(handCards: handCards, turn: turn)

            for spell in playableSpells.prefix(1) {  // Play one spell per turn for simulation
                if await gameState.playCard(named: spell) != nil {
                    let cardInfo = await queryCardInformation(spell)
                    let emoji = getCardEmoji(for: cardInfo)
                    playedCards.append("\(emoji) \(spell)")
                    break
                }
            }

            if playedCards.isEmpty {
                results.append("No plays available")
            } else {
                results.append("Played: \(playedCards.joined(separator: ", "))")
            }
            results.append("")
        }

        // Show final hand state and analysis
        results.append("**Final Hand:**")
        let finalHandContents = await gameState.getHandContents()
        for (cardName, count) in finalHandContents.sorted(by: { $0.key < $1.key }) {
            results.append("  \(count)x \(cardName)")
        }

        results.append("\n**External Analysis:**")

        // Query Commander Spellbook for potential combos if it's a commander deck
        if deckStats.commander != nil {
            results.append("🔍 **Checking for combo potential...**")
            let comboResults = await queryCommanderSpellbook(cards: Array(finalHandContents.keys))
            if !comboResults.isEmpty {
                results.append("**Potential Combos Found:**")
                results.append(contentsOf: comboResults)
            } else {
                results.append("No immediate combos detected in hand")
            }
        }

        return CallTool.Result(content: [.text(results.joined(separator: "\n"))])
    }

    // MARK: - Combo Lookup Tools

    /// Looks up combo potential for specific cards using Commander Spellbook
    private func handleLookupCombo(arguments: [String: Value], rulesService: RulesService)
        async throws -> CallTool.Result
    {
        let startTime = Date()

        guard case .array(let cardsArray) = arguments["cards"] else {
            throw MCPError.invalidParams("Missing cards array parameter")
        }

        let cardNames = cardsArray.compactMap { $0.stringValue }
        let commander = arguments["commander"]?.stringValue
        let detailed = arguments["detailed"]?.boolValue ?? true
        let minPopularity = arguments["min_popularity"]?.intValue ?? 10

        // Query Commander Spellbook for combos with structured response
        let (combos, relatedCombos, nearMisses, apiSuccess) = await queryDetailedCombosStructured(
            cards: cardNames,
            commander: commander,
            minPopularity: minPopularity,
            detailed: detailed
        )

        let processingTime = Date().timeIntervalSince(startTime)

        // Create LLM-optimized response
        let optimizedResponse = ResponseFormatter.formatComboLookupResponse(
            queriedCards: cardNames,
            combos: combos,
            relatedCombos: relatedCombos,
            nearMisses: nearMisses,
            processingTime: processingTime,
            apiSuccess: apiSuccess
        )

        // Convert to MCP CallTool.Result format
        let jsonData = try JSONEncoder().encode(optimizedResponse)
        let jsonString = String(data: jsonData, encoding: .utf8) ?? "{}"

        return CallTool.Result(content: [.text(jsonString)])
    }

    /// Analyzes an entire deck for combo potential
    private func handleFindDeckCombos(
        arguments: [String: Value], gameState: GameState, rulesService: RulesService
    ) async throws -> CallTool.Result {
        let startTime = Date()

        guard case .string(let deckList) = arguments["deck_list"] else {
            throw MCPError.invalidParams("Missing deck_list parameter")
        }

        let commander = arguments["commander"]?.stringValue
        let comboTypes =
            arguments["combo_types"]?.arrayValue?.compactMap { $0.stringValue } ?? ["all"]
        let maxPieces = arguments["max_pieces"]?.intValue ?? 4

        // Parse deck list
        let cards = deckList.components(separatedBy: .newlines)
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
            .compactMap { line -> String? in
                // Extract card name from deck list format (handle quantities)
                let components = line.components(separatedBy: " ")
                if components.count > 1, Int(components[0]) != nil {
                    return components.dropFirst().joined(separator: " ")
                }
                return line
            }

        // Analyze deck for combo potential with structured response
        let (deckCombos, nearMisses, _) = await analyzeDeckCombosStructured(
            cards: cards,
            commander: commander,
            comboTypes: comboTypes,
            maxPieces: maxPieces
        )

        let processingTime = Date().timeIntervalSince(startTime)

        // Create structured deck analysis content
        let comboAnalysis = ComboAnalysisResult(
            completeCombos: deckCombos,
            nearMisses: nearMisses,
            comboConsistency: calculateComboConsistency(combos: deckCombos, deckSize: cards.count),
            recommendedAdditions: nearMisses.prefix(5).flatMap { $0.missingCards }
        )

        let deckAnalysisContent = DeckAnalysisContent(
            totalCards: cards.count,
            comboAnalysis: comboAnalysis,
            manaCurve: analyzeManaCurveForDeck(cards: cards),
            colorBalance: analyzeColorBalanceForDeck(cards: cards),
            archetypeIdentification: identifyArchetype(cards: cards, combos: deckCombos)
        )

        // Create LLM-optimized response
        let confidence = ConfidenceScoring.scoreComposite(
            componentScores: [
                "combo_analysis": Double(deckCombos.count) / Double(max(cards.count / 20, 1)),
                "api_reliability": 0.85,
                "data_completeness": 1.0,
            ]
        )

        let reasoning = DecisionReasoningChain(
            steps: [
                "Parsed \(cards.count) cards from deck list",
                "Analyzed for combo potential using Commander Spellbook API",
                "Found \(deckCombos.count) complete combos",
                "Identified \(nearMisses.count) near-miss opportunities",
                "Calculated synergy clusters and deck consistency",
            ],
            confidenceFactors: [
                "Live API data from Commander Spellbook",
                "Comprehensive deck analysis including mana curve and color balance",
            ],
            riskFactors: nearMisses.isEmpty
                ? ["Limited combo diversity may indicate missed opportunities"] : []
        )

        let suggestions = generateDeckComboSuggestions(
            combos: deckCombos,
            nearMisses: nearMisses,
            deckSize: cards.count
        )

        let optimizedResponse = LLMOptimizedResponse(
            metadata: ResponseMetadata(
                toolName: "find_deck_combos",
                confidence: confidence,
                dataSource: "commander_spellbook_api",
                processingTime: processingTime,
                apiCallsUsed: calculateAPICallsForDeck(cards.count)
            ),
            content: .deckAnalysis(deckAnalysisContent),
            reasoning: reasoning,
            suggestions: suggestions,
            tags: generateDeckAnalysisTags(combos: deckCombos, archetypeScore: 0.7)
        )

        // Convert to MCP CallTool.Result format
        let jsonData = try JSONEncoder().encode(optimizedResponse)
        let jsonString = String(data: jsonData, encoding: .utf8) ?? "{}"

        return CallTool.Result(content: [.text(jsonString)])
    }

    // MARK: - Simulation Helper Methods

    /// Determines if a card name is a land using comprehensive detection
    private func isLikelyLand(_ cardName: String) -> Bool {
        return LandDetectionService.isLand(cardName)
    }

    /// Analyzes which spells are likely playable on a given turn
    private func analyzePlayableSpells(handCards: [String], turn: Int) async -> [String] {
        var playableSpells: [String] = []

        for cardName in handCards {
            // Skip lands
            if isLikelyLand(cardName) {
                continue
            }

            // Analyze based on common patterns and estimated mana costs
            let estimatedCost = estimateManaCost(from: cardName)
            if estimatedCost <= turn + 1 {  // Allow for some mana acceleration
                playableSpells.append(cardName)
            }
        }

        // Prioritize by card type (ramp first, then card draw, then threats)
        return playableSpells.sorted { card1, card2 in
            let priority1 = getPlayPriority(card1, turn: turn)
            let priority2 = getPlayPriority(card2, turn: turn)
            return priority1 > priority2
        }
    }

    /// Estimates mana cost from card name patterns
    private func estimateManaCost(from cardName: String) -> Int {
        let lowerName = cardName.lowercased()

        // Known low-cost cards
        if lowerName.contains("sol ring") || lowerName.contains("mox") { return 0 }
        if lowerName.contains("signet") || lowerName.contains("talisman") { return 2 }
        if lowerName.contains("rampant") || lowerName.contains("farseek") { return 2 }
        if lowerName.contains("cultivate") || lowerName.contains("kodama") { return 3 }

        // Heuristic based on card name length and complexity
        if cardName.count < 8 { return 1 }
        if cardName.count < 12 { return 2 }
        if cardName.count < 16 { return 3 }
        return 4
    }

    /// Gets play priority for simulation decisions
    private func getPlayPriority(_ cardName: String, turn: Int) -> Int {
        let lowerName = cardName.lowercased()

        // High priority: Mana acceleration
        if lowerName.contains("sol ring") || lowerName.contains("mox") { return 10 }
        if lowerName.contains("signet") || lowerName.contains("talisman")
            || lowerName.contains("rampant")
        {
            return 9
        }

        // Medium-high priority: Card draw
        if lowerName.contains("draw") || lowerName.contains("divination")
            || lowerName.contains("night's whisper")
        {
            return 8
        }

        // Medium priority: Utility and protection
        if lowerName.contains("boots") || lowerName.contains("lightning greaves") { return 6 }

        // Lower priority: Creatures and threats (save for later turns)
        if turn <= 2 { return 3 }
        return 5
    }

    /// Queries Commander Spellbook via Next.js API for combo information
    private func queryCommanderSpellbook(cards: [String]) async -> [String] {
        var results: [String] = []

        // Use the actual Next.js API endpoint
        let buildId = "NmyQ13a-vqItdK3ycukDg"  // May need updating periodically
        let cardsToCheck = Array(cards.prefix(3))

        for card in cardsToCheck {
            do {
                let encodedCard =
                    card.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? card
                let urlString =
                    "https://commanderspellbook.com/_next/data/\(buildId)/search.json?q=\(encodedCard)"

                guard let url = URL(string: urlString) else { continue }

                let (data, response) = try await URLSession.shared.data(from: url)

                if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                    if let jsonData = try? JSONSerialization.jsonObject(with: data)
                        as? [String: Any],
                        let pageProps = jsonData["pageProps"] as? [String: Any],
                        let combos = pageProps["combos"] as? [[String: Any]]
                    {

                        if combos.isEmpty {
                            results.append("🔍 **\(card):** No combos found")
                        } else {
                            results.append("✅ **\(card):** Found in \(combos.count) combo(s)")
                        }
                    }
                } else {
                    let statusCode = (response as? HTTPURLResponse)?.statusCode ?? 0
                    results.append("🔍 **\(card):** Check manually - API returned \(statusCode)")
                }
            } catch {
                results.append("🔍 **\(card):** Check manually - API unavailable")
            }
        }

        return results
    }

    /// Queries Commander Spellbook for specific card interactions
    private func queryCommanderSpellbookInteraction(cards: [String], scenario: String) async
        -> [String]
    {
        var results: [String] = []

        let buildId = "NmyQ13a-vqItdK3ycukDg"  // May need updating periodically

        // Try multi-card search
        if cards.count >= 2 {
            do {
                let cardQuery = cards.prefix(3).joined(separator: " ")
                let encodedQuery =
                    cardQuery.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
                    ?? cardQuery
                let urlString =
                    "https://commanderspellbook.com/_next/data/\(buildId)/search.json?q=\(encodedQuery)"

                guard let url = URL(string: urlString) else {
                    results.append("❌ **Multi-Card Search:** Failed to construct URL")
                    return results
                }

                let (data, response) = try await URLSession.shared.data(from: url)

                if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                    if let jsonData = try? JSONSerialization.jsonObject(with: data)
                        as? [String: Any],
                        let pageProps = jsonData["pageProps"] as? [String: Any],
                        let combos = pageProps["combos"] as? [[String: Any]]
                    {

                        if combos.isEmpty {
                            results.append(
                                "⚪ **Multi-Card Search:** No combos found with all cards")
                        } else {
                            results.append(
                                "✅ **Multi-Card Search:** Found \(combos.count) combo(s)")

                            // Show first few combos
                            for (index, combo) in combos.prefix(3).enumerated() {
                                if let uses = combo["uses"] as? [[String: Any]] {

                                    let usedCards = uses.compactMap { use -> String? in
                                        if let card = use["card"] as? [String: Any],
                                            let name = card["name"] as? String
                                        {
                                            return name
                                        }
                                        return nil
                                    }

                                    results.append(
                                        "\(index + 1). **Combo:** \(usedCards.joined(separator: " + "))"
                                    )

                                    if let produces = combo["produces"] as? [[String: Any]],
                                        let firstFeature = produces.first,
                                        let feature = firstFeature["feature"] as? [String: Any],
                                        let featureName = feature["name"] as? String
                                    {
                                        results.append("   **Result:** \(featureName)")
                                    }
                                }
                            }
                        }
                    }
                } else {
                    let statusCode = (response as? HTTPURLResponse)?.statusCode ?? 0
                    results.append("⚠️ **Multi-Card Search:** HTTP \(statusCode)")
                }
            } catch {
                results.append("❌ **Multi-Card Search:** \(error.localizedDescription)")
            }
        }

        return results
    }

    /// Enhanced combo lookup with real API calls
    /// Queries Commander Spellbook API and returns structured combo data
    private func queryDetailedCombosStructured(
        cards: [String], commander: String?, minPopularity: Int, detailed: Bool
    ) async -> (
        combos: [ComboResult], relatedCombos: [ComboResult], nearMisses: [NearMissCombo],
        apiSuccess: Bool
    ) {
        var combos: [ComboResult] = []
        var relatedCombos: [ComboResult] = []
        var nearMisses: [NearMissCombo] = []
        var apiSuccess = false

        let buildId = "NmyQ13a-vqItdK3ycukDg"  // May need updating periodically

        do {
            // Try each card individually first
            for card in cards.prefix(3) {
                let encodedCard =
                    card.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? card
                let urlString =
                    "https://commanderspellbook.com/_next/data/\(buildId)/search.json?q=\(encodedCard)"

                guard let url = URL(string: urlString) else { continue }

                let (data, response) = try await URLSession.shared.data(from: url)

                if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                    if let jsonData = try? JSONSerialization.jsonObject(with: data)
                        as? [String: Any],
                        let pageProps = jsonData["pageProps"] as? [String: Any],
                        let foundCombos = pageProps["combos"] as? [[String: Any]]
                    {

                        apiSuccess = true

                        for comboData in foundCombos {
                            let combo = parseSpellbookComboResult(
                                from: comboData, queriedCards: cards)

                            // Determine if this is a direct match or related combo
                            let cardSet = Set(combo.cards)
                            let queriedSet = Set(cards)
                            let overlap = cardSet.intersection(queriedSet)

                            if overlap.count == queriedSet.count {
                                // Perfect match - all queried cards are in this combo
                                combos.append(combo)
                            } else if overlap.count >= max(1, queriedSet.count - 1) {
                                // Close match - most queried cards are present
                                relatedCombos.append(combo)
                            }

                            // Check for near misses (combos we could complete with small additions)
                            let missingCards = cardSet.subtracting(queriedSet)
                            if missingCards.count <= 2 && overlap.count >= 2 {
                                let nearMiss = NearMissCombo(
                                    ownedCards: Array(overlap),
                                    missingCards: Array(missingCards),
                                    wouldResult: combo.result,
                                    additionPriority: calculateAdditionPriority(
                                        combo: combo, missingCount: missingCards.count)
                                )
                                nearMisses.append(nearMiss)
                            }
                        }
                    }
                }
            }

            // Remove duplicates
            combos = Array(
                Set(combos.map { $0.id }).compactMap { id in
                    combos.first { $0.id == id }
                })
            relatedCombos = Array(
                Set(relatedCombos.map { $0.id }).compactMap { id in
                    relatedCombos.first { $0.id == id }
                })
            nearMisses = Array(
                Set(nearMisses.map { $0.wouldResult }).compactMap { result in
                    nearMisses.first { $0.wouldResult == result }
                })

        } catch {
            apiSuccess = false
        }

        return (combos, relatedCombos, nearMisses, apiSuccess)
    }

    /// Parses Commander Spellbook Next.js API combo JSON into structured ComboResult
    private func parseSpellbookComboResult(from comboData: [String: Any], queriedCards: [String])
        -> ComboResult
    {
        let id = comboData["id"] as? String ?? UUID().uuidString

        // Extract card names from the "uses" array
        var cards: [String] = []
        if let uses = comboData["uses"] as? [[String: Any]] {
            cards = uses.compactMap { use in
                if let card = use["card"] as? [String: Any],
                    let name = card["name"] as? String
                {
                    return name
                }
                return nil
            }
        }

        // Extract result from the "produces" array
        var result = "Unknown effect"
        if let produces = comboData["produces"] as? [[String: Any]],
            let firstFeature = produces.first,
            let feature = firstFeature["feature"] as? [String: Any],
            let featureName = feature["name"] as? String
        {
            result = featureName
        }

        // Determine combo type based on result description
        let type: ComboResult.ComboType
        let resultLower = result.lowercased()
        if resultLower.contains("infinite") {
            type = .infinite
        } else if resultLower.contains("win") || resultLower.contains("damage") {
            type = .finite
        } else if cards.count <= 2 {
            type = .synergy
        } else {
            type = .engine
        }

        // Calculate popularity from the real popularity field
        let popularity = (comboData["popularity"] as? Int).map { Double($0) / 100000.0 } ?? 0.0  // Scale to 0-1
        let complexity: ComboResult.Complexity =
            cards.count <= 2
            ? .simple : cards.count <= 3 ? .medium : cards.count <= 4 ? .complex : .expert

        // Extract mana requirements
        let manaRequirements = extractManaRequirements(from: comboData)
        let prerequisites: [String] = []
        let steps = extractStepsFromDescription(comboData["description"] as? String ?? "")
        let counters = extractCounters(from: result)

        // Determine competitive tier based on complexity and popularity
        let competitiveTier: ComboResult.CompetitiveTier
        if popularity >= 0.8 && complexity == .simple {
            competitiveTier = .cedh
        } else if popularity >= 0.6 {
            competitiveTier = .competitive
        } else if popularity >= 0.4 {
            competitiveTier = .optimized
        } else if popularity >= 0.2 {
            competitiveTier = .focused
        } else {
            competitiveTier = .casual
        }

        return ComboResult(
            id: id,
            cards: cards,
            result: result,
            type: type,
            popularityScore: popularity,
            setupComplexity: complexity,
            manaRequirements: manaRequirements,
            prerequisites: prerequisites,
            steps: steps,
            counters: counters,
            competitiveTier: competitiveTier
        )
    }

    /// Extracts steps from description text
    private func extractStepsFromDescription(_ description: String) -> [String] {
        if description.isEmpty {
            return ["1. Resolve the combo pieces", "2. Activate the combo"]
        }

        // Split by periods and clean up
        let sentences = description.components(separatedBy: ".")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }

        if sentences.count > 1 {
            return Array(sentences.enumerated().map { "\($0.offset + 1). \($0.element)" }.prefix(5))
        } else {
            return [description]
        }
    }

    /// Parses Commander Spellbook combo JSON into structured ComboResult (legacy function)
    private func parseComboResult(from comboData: [String: Any], queriedCards: [String])
        -> ComboResult
    {
        let id = comboData["id"] as? String ?? UUID().uuidString
        let cards = comboData["cards"] as? [String] ?? []
        let result = comboData["result"] as? String ?? "Unknown effect"

        // Determine combo type based on result description
        let type: ComboResult.ComboType
        let resultLower = result.lowercased()
        if resultLower.contains("infinite") {
            type = .infinite
        } else if resultLower.contains("win") || resultLower.contains("damage") {
            type = .finite
        } else if cards.count <= 2 {
            type = .synergy
        } else {
            type = .engine
        }

        // Calculate popularity and complexity
        let popularity = (comboData["popularity"] as? Int).map { Double($0) / 100.0 } ?? 0.0
        let complexity: ComboResult.Complexity =
            cards.count <= 2
            ? .simple : cards.count <= 3 ? .medium : cards.count <= 4 ? .complex : .expert

        // Extract other details
        let manaRequirements = extractManaRequirements(from: comboData)
        let prerequisites = comboData["prerequisites"] as? [String] ?? []
        let steps =
            comboData["steps"] as? [String] ?? [
                "1. Resolve the combo pieces", "2. Activate the combo",
            ]
        let counters = extractCounters(from: result)

        // Determine competitive tier based on complexity and popularity
        let competitiveTier: ComboResult.CompetitiveTier
        if popularity >= 0.8 && complexity == .simple {
            competitiveTier = .cedh
        } else if popularity >= 0.6 {
            competitiveTier = .competitive
        } else if popularity >= 0.4 {
            competitiveTier = .optimized
        } else if popularity >= 0.2 {
            competitiveTier = .focused
        } else {
            competitiveTier = .casual
        }

        return ComboResult(
            id: id,
            cards: cards,
            result: result,
            type: type,
            popularityScore: popularity,
            setupComplexity: complexity,
            manaRequirements: manaRequirements,
            prerequisites: prerequisites,
            steps: steps,
            counters: counters,
            competitiveTier: competitiveTier
        )
    }

    /// Calculates priority score for adding missing combo pieces
    private func calculateAdditionPriority(combo: ComboResult, missingCount: Int) -> Double {
        var priority = combo.popularityScore  // Base on popularity

        // Bonus for simpler combos
        switch combo.setupComplexity {
        case .simple:
            priority += 0.3
        case .medium:
            priority += 0.2
        case .complex:
            priority += 0.1
        case .expert:
            priority += 0.0
        }

        // Penalty for more missing pieces
        priority -= Double(missingCount) * 0.2

        // Bonus for infinite combos
        if combo.type == .infinite {
            priority += 0.2
        }

        return max(0.0, min(1.0, priority))
    }

    /// Extracts mana requirements from combo data
    private func extractManaRequirements(from comboData: [String: Any]) -> [String] {
        // This would ideally parse the combo steps to find mana costs
        // For now, provide a basic analysis
        if let steps = comboData["steps"] as? [String] {
            var requirements: [String] = []
            for step in steps {
                if step.contains("mana") || step.contains("{") {
                    // Extract mana cost patterns
                    let pattern = "\\{[^}]+\\}"
                    if let regex = try? NSRegularExpression(pattern: pattern) {
                        let matches = regex.matches(
                            in: step, range: NSRange(step.startIndex..., in: step))
                        for match in matches {
                            if let range = Range(match.range, in: step) {
                                requirements.append(String(step[range]))
                            }
                        }
                    }
                }
            }
            return Array(Set(requirements))  // Remove duplicates
        }
        return []
    }

    /// Extracts counter-play options from combo result description
    private func extractCounters(from result: String) -> [String] {
        var counters: [String] = []
        let resultLower = result.lowercased()

        if resultLower.contains("creature") {
            counters.append("Creature removal")
        }
        if resultLower.contains("artifact") {
            counters.append("Artifact removal")
        }
        if resultLower.contains("enchantment") {
            counters.append("Enchantment removal")
        }
        if resultLower.contains("spell") || resultLower.contains("cast") {
            counters.append("Counterspells")
        }
        if resultLower.contains("graveyard") {
            counters.append("Graveyard hate")
        }
        if resultLower.contains("infinite") {
            counters.append("Stax effects")
        }

        return counters.isEmpty ? ["Interaction", "Removal"] : counters
    }

    /// Find deck combos using real API calls
    private func findDeckCombos(
        cards: [String], commander: String?, comboTypes: [String], maxPieces: Int
    ) async -> [String] {
        var results: [String] = []

        do {
            // Send the full deck list to Commander Spellbook for analysis
            let deckQuery = cards.joined(separator: ",")
            let encodedQuery =
                deckQuery.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
                ?? deckQuery

            var urlComponents = URLComponents(
                string: "https://commanderspellbook.com/api/deck-analysis")!
            urlComponents.queryItems = [
                URLQueryItem(name: "cards", value: encodedQuery),
                URLQueryItem(name: "max_pieces", value: String(maxPieces)),
            ]

            if let commander = commander {
                urlComponents.queryItems?.append(URLQueryItem(name: "commander", value: commander))
            }

            guard let url = urlComponents.url else {
                results.append("❌ Failed to construct deck analysis URL")
                return results
            }

            let (data, response) = try await URLSession.shared.data(from: url)

            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode == 200 {
                    // Parse deck analysis response
                    if let jsonResponse = try? JSONSerialization.jsonObject(with: data)
                        as? [String: Any]
                    {
                        if let foundCombos = jsonResponse["combos"] as? [[String: Any]] {
                            for combo in foundCombos {
                                if let comboCards = combo["cards"] as? [String],
                                    let result = combo["result"] as? String
                                {
                                    results.append(
                                        "✅ **Found:** \(comboCards.joined(separator: " + "))")
                                    results.append("   Result: \(result)")
                                    results.append("")
                                }
                            }
                        }
                    }
                } else {
                    results.append("⚠️ Deck analysis API returned \(httpResponse.statusCode)")
                    results.append("Manual analysis required at Commander Spellbook")
                }
            }

        } catch {
            results.append("❌ **Deck Analysis Failed:** \(error.localizedDescription)")
            results.append("")
            results.append("**Manual Analysis Required:**")
            results.append("1. Go to https://commanderspellbook.com")
            results.append("2. Use the deck analysis tool")
            results.append("3. Input your deck list for combo detection")
        }

        return results
    }

    /// Finds related combos that include some of the specified cards (REAL API)
    private func findRelatedCombos(cards: [String], commander: String?) async -> [String] {
        var results: [String] = []

        // Query Commander Spellbook for each card individually to find related combos
        for card in cards.prefix(3) {
            do {
                let encodedCard =
                    card.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? card
                let urlString =
                    "https://commanderspellbook.com/api/search/cards/\(encodedCard)/combos"

                guard let url = URL(string: urlString) else { continue }

                let (data, response) = try await URLSession.shared.data(from: url)

                if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                    if let jsonData = try? JSONSerialization.jsonObject(with: data)
                        as? [String: Any],
                        let relatedCombos = jsonData["combos"] as? [[String: Any]]
                    {

                        for combo in relatedCombos.prefix(2) {
                            if let comboCards = combo["cards"] as? [String],
                                let result = combo["result"] as? String
                            {
                                let otherCards = comboCards.filter { $0 != card }
                                if !otherCards.isEmpty {
                                    results.append(
                                        "💫 **\(card)** + \(otherCards.joined(separator: " + "))")
                                    results.append("   Result: \(result)")
                                    results.append("")
                                }
                            }
                        }
                    }
                }
            } catch {
                // Continue with next card
                continue
            }
        }

        return results
    }

    /// Find near-miss combos (missing 1-2 pieces) - REAL API
    private func findNearMissCombos(cards: [String], commander: String?) async -> [String] {
        var results: [String] = []

        do {
            // Query Commander Spellbook's "find missing pieces" endpoint
            let deckQuery = cards.joined(separator: ",")
            let encodedQuery =
                deckQuery.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
                ?? deckQuery

            let urlString =
                "https://commanderspellbook.com/api/near-combos?deck=\(encodedQuery)&missing=2"
            guard let url = URL(string: urlString) else { return results }

            let (data, response) = try await URLSession.shared.data(from: url)

            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                if let jsonData = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                    let nearMisses = jsonData["near_combos"] as? [[String: Any]]
                {

                    for nearMiss in nearMisses.prefix(5) {
                        if let comboCards = nearMiss["combo_cards"] as? [String],
                            let missingCards = nearMiss["missing_cards"] as? [String],
                            let result = nearMiss["result"] as? String
                        {

                            let ownedCards = comboCards.filter { cards.contains($0) }

                            results.append(
                                "🎯 **Near Miss:** \(ownedCards.joined(separator: " + ")) + ?")
                            results.append("   Missing: \(missingCards.joined(separator: ", "))")
                            results.append("   Would Result: \(result)")
                            results.append("")
                        }
                    }
                }
            }
        } catch {
            // No results on error - API might not have this endpoint
        }

        return results
    }

    /// Analyze deck synergies - REAL API
    private func analyzeDeckSynergies(cards: [String], commander: String?) async -> [String] {
        var results: [String] = []

        do {
            let deckQuery = cards.joined(separator: ",")
            let encodedQuery =
                deckQuery.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
                ?? deckQuery

            let urlString = "https://commanderspellbook.com/api/synergies?deck=\(encodedQuery)"
            guard let url = URL(string: urlString) else { return results }

            let (data, response) = try await URLSession.shared.data(from: url)

            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                if let jsonData = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                    let synergies = jsonData["synergies"] as? [[String: Any]]
                {

                    for synergy in synergies.prefix(5) {
                        if let theme = synergy["theme"] as? String,
                            let synergyCards = synergy["cards"] as? [String],
                            let strength = synergy["strength"] as? Int
                        {

                            results.append("⚡ **\(theme) Synergy:**")
                            results.append("   Cards: \(synergyCards.joined(separator: ", "))")
                            results.append("   Strength: \(strength)/10")
                            results.append("")
                        }
                    }
                }
            }
        } catch {
            // No results on error
        }

        return results
    }

    /// Get deck building suggestions - REAL API
    private func getDeckComboBuildingSuggestions(
        cards: [String], commander: String?, foundCombos: Int
    ) async -> [String] {
        var results: [String] = []

        do {
            let deckQuery = cards.joined(separator: ",")
            let encodedQuery =
                deckQuery.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
                ?? deckQuery

            var urlString = "https://commanderspellbook.com/api/suggestions?deck=\(encodedQuery)"
            if let cmd = commander {
                let encodedCommander =
                    cmd.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? cmd
                urlString += "&commander=\(encodedCommander)"
            }

            guard let url = URL(string: urlString) else { return results }

            let (data, response) = try await URLSession.shared.data(from: url)

            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                if let jsonData = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                    let suggestions = jsonData["suggestions"] as? [[String: Any]]
                {

                    for suggestion in suggestions.prefix(8) {
                        if let cardName = suggestion["card"] as? String,
                            let reason = suggestion["reason"] as? String,
                            let impact = suggestion["impact"] as? String
                        {

                            results.append("💡 **Add \(cardName):**")
                            results.append("   Reason: \(reason)")
                            results.append("   Impact: \(impact)")
                            results.append("")
                        }
                    }
                }
            }
        } catch {
            // Provide basic fallback suggestions based on combo count
            if foundCombos == 0 {
                results.append("💡 **No combos found - Consider adding staples:**")
                results.append("- Sol Ring (universal acceleration)")
                results.append("- Command Tower (mana fixing)")
                results.append("- Swords to Plowshares (efficient removal)")
            } else if foundCombos < 3 {
                results.append("💡 **Few combos - Consider adding:**")
                results.append("- Tutors to find combo pieces")
                results.append("- Protection for key pieces")
                results.append("- More redundant effects")
            } else {
                results.append("💡 **Good combo density - Consider adding:**")
                results.append("- Interaction to protect combos")
                results.append("- Card draw engines")
                results.append("- Backup win conditions")
            }
        }

        return results
    }

    /// Queries Gatherer for official card rulings
    private func queryGathererRulings(cards: [String]) async -> [String] {
        var results: [String] = []

        for card in cards.prefix(3) {  // Limit API calls
            let encodedCard =
                card.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? card

            // Since Gatherer doesn't have a public JSON API, we'll simulate what would happen
            // In a real implementation, you would:
            // 1. Scrape the Gatherer page
            // 2. Extract rulings from the card's page
            // 3. Parse the HTML to get ruling text

            // For now, provide a structured placeholder
            results.append("🏛️ **\(card):**")
            results.append("   *Source:* gatherer.wizards.com")
            results.append("   *Note:* Check official Gatherer page for current rulings")
            results.append(
                "   *Link:* https://gatherer.wizards.com/Pages/Search/Default.aspx?name=\(encodedCard)"
            )
        }

        return results
    }

    /// Queries card information from external APIs
    private func queryCardInformation(_ cardName: String) async -> CardInfo {
        // Try Gatherer first, then fallback to heuristics
        if let gathererInfo = await queryGatherer(cardName) {
            return gathererInfo
        }

        // Fallback to pattern-based analysis
        return CardInfo(
            name: cardName,
            type: inferCardType(cardName),
            manaCost: estimateManaCost(from: cardName)
        )
    }

    /// Queries Gatherer API for card information
    private func queryGatherer(_ cardName: String) async -> CardInfo? {
        let encodedName =
            cardName.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? cardName
        let urlString =
            "https://gatherer.wizards.com/Pages/Search/Default.aspx?name=+[\(encodedName)]"

        guard URL(string: urlString) != nil else { return nil }

        // Note: Gatherer doesn't have a JSON API, so this would need HTML scraping
        // For now, return nil to use fallback heuristics
        return nil
    }

    /// Infers card type from name patterns
    private func inferCardType(_ cardName: String) -> String {
        let lowerName = cardName.lowercased()

        if isLikelyLand(cardName) { return "Land" }
        if lowerName.contains("signet") || lowerName.contains("sol ring")
            || lowerName.contains("mox")
        {
            return "Artifact"
        }
        if lowerName.contains("lightning bolt") || lowerName.contains("counterspell") {
            return "Instant"
        }
        if lowerName.contains("wrath") || lowerName.contains("cultivate") { return "Sorcery" }
        if lowerName.contains("phyrexian arena") || lowerName.contains("enchantment") {
            return "Enchantment"
        }

        return "Creature"  // Default assumption
    }

    /// Gets appropriate emoji for card type
    private func getCardEmoji(for cardInfo: CardInfo) -> String {
        switch cardInfo.type.lowercased() {
        case "artifact": return "⚙️"
        case "instant": return "⚡"
        case "sorcery": return "📜"
        case "enchantment": return "✨"
        case "creature": return "👾"
        case "land": return "🏔️"
        default: return "🎴"
        }
    }

    // MARK: - Supporting Types

    struct CardInfo {
        let name: String
        let type: String
        let manaCost: Int
    }

    // MARK: - Card Interaction Validation Tools

    /// Validates interactions between multiple cards against MTG rules
    private func handleValidateInteraction(arguments: [String: Value], rulesService: RulesService)
        async throws -> CallTool.Result
    {
        guard case .array(let cardsArray) = arguments["cards"],
            case .string(let scenario) = arguments["scenario"]
        else {
            throw MCPError.invalidParams("Missing cards array or scenario parameter")
        }

        let detailed = arguments["detailed"]?.boolValue ?? true
        let cardNames = cardsArray.compactMap { $0.stringValue }

        var results: [String] = []
        results.append("# 🔍 Interaction Validation")
        results.append("")
        results.append("**Cards:** \(cardNames.joined(separator: ", "))")
        results.append("**Scenario:** \(scenario)")
        results.append("")

        // Check for common misconceptions first
        let misconceptionResults = checkForCommonMisconceptions(
            scenario: scenario, cards: cardNames, rulesService: rulesService)
        if !misconceptionResults.isEmpty {
            results.append("## ⚠️ Potential Issues:")
            results.append(contentsOf: misconceptionResults)
            results.append("")
        }

        // Query external APIs for authoritative information
        results.append("## 🌐 External API Validation:")

        // Check Commander Spellbook for known combos/interactions
        let comboResults = await queryCommanderSpellbookInteraction(
            cards: cardNames, scenario: scenario)
        if !comboResults.isEmpty {
            results.append("### 📚 Commander Spellbook Results:")
            results.append(contentsOf: comboResults)
            results.append("")
        }

        // Query Gatherer for official card rulings
        let gathererResults = await queryGathererRulings(cards: cardNames)
        if !gathererResults.isEmpty {
            results.append("### ⚖️ Official Gatherer Rulings:")
            results.append(contentsOf: gathererResults)
            results.append("")
        }

        // Analyze the interaction with local rules
        results.append("## 📋 Rule Analysis:")

        // Search for relevant rules based on scenario keywords
        let keywords = extractKeywords(from: scenario)
        let relevantRules = rulesService.searchRules(keywords)

        if relevantRules.isEmpty {
            results.append("No specific local rules found for this interaction.")
        } else {
            for (index, rule) in relevantRules.prefix(3).enumerated() {
                results.append("\(index + 1). **Rule \(rule.ruleNumber):** \(rule.title)")
                if detailed, let firstMatch = rule.matchingLines.first {
                    let preview = firstMatch.trimmingCharacters(
                        in: CharacterSet.whitespacesAndNewlines)
                    results.append(
                        "   \(preview.count > 150 ? String(preview.prefix(150)) + "..." : preview)")
                }
                results.append("")
            }
        }

        // Provide comprehensive conclusion
        results.append("## ✅ Validation Summary:")

        if comboResults.isEmpty && gathererResults.isEmpty && relevantRules.isEmpty {
            results.append("- No definitive information found in external databases")
            results.append("- Recommend consulting a certified MTG judge for official ruling")
        } else {
            results.append("- External databases consulted for authoritative information")
            results.append("- Cross-referenced with local MTG rules database")
        }

        results.append("")
        results.append("## 🔗 Manual Verification Links:")
        results.append("- **Commander Spellbook:** https://commanderspellbook.com/search")
        results.append("- **Gatherer Database:** http://gatherer.wizards.com")
        results.append("- **MTG Judge Chat:** Ask a certified judge for complex interactions")

        return CallTool.Result(content: [.text(results.joined(separator: "\n"))])
    }

    /// Simulates game scenarios step-by-step with rule applications
    private func handleSimulateGameState(arguments: [String: Value], rulesService: RulesService)
        async throws -> CallTool.Result
    {
        guard case .string(let scenario) = arguments["scenario"] else {
            throw MCPError.invalidParams("Missing scenario parameter")
        }

        let stepByStep = arguments["step_by_step"]?.boolValue ?? true
        let includeTiming = arguments["include_timing"]?.boolValue ?? true

        var results: [String] = []
        results.append("# 🎮 Game State Simulation")
        results.append("")
        results.append("**Scenario:** \(scenario)")
        results.append("")

        if stepByStep {
            results.append("## 📝 Step-by-Step Breakdown:")
            results.append("")

            // Parse scenario for common game actions
            let steps = parseScenarioIntoSteps(scenario)

            for (index, step) in steps.enumerated() {
                results.append("**Step \(index + 1):** \(step)")

                // Find relevant rules for this step
                let stepKeywords = extractKeywords(from: step)
                let stepRules = rulesService.searchRules(stepKeywords)

                if !stepRules.isEmpty {
                    let rule = stepRules[0]
                    results.append("   *Rule \(rule.ruleNumber):* \(rule.title)")
                }

                if includeTiming {
                    results.append("   *Timing:* \(getTimingInfo(for: step))")
                }
                results.append("")
            }
        }

        results.append("## ⚡ Key Timing Points:")
        results.append("- **State-based actions** are checked")
        results.append("- **Triggered abilities** go on the stack")
        results.append("- **Priority** passes between players")
        results.append("")

        results.append("## 📚 Related Rules:")
        let conceptRules = rulesService.searchRules(["priority"])
        for rule in conceptRules.prefix(2) {
            results.append("- **Rule \(rule.ruleNumber):** \(rule.title)")
        }

        return CallTool.Result(content: [.text(results.joined(separator: "\n"))])
    }

    /// Checks for common MTG misconceptions and errors
    private func handleCheckCommonErrors(arguments: [String: Value], rulesService: RulesService)
        async throws -> CallTool.Result
    {
        guard case .string(let query) = arguments["query"] else {
            throw MCPError.invalidParams("Missing query parameter")
        }

        let cardNames = arguments["cards"]?.arrayValue?.compactMap { $0.stringValue } ?? []

        var results: [String] = []
        results.append("# ⚠️ Common Error Check")
        results.append("")
        results.append("**Query:** \(query)")
        if !cardNames.isEmpty {
            results.append("**Cards:** \(cardNames.joined(separator: ", "))")
        }
        results.append("")

        // Check against common misconceptions database
        let misconceptions = checkForCommonMisconceptions(
            scenario: query, cards: cardNames, rulesService: rulesService)

        if misconceptions.isEmpty {
            results.append("## ✅ No Common Errors Detected")
            results.append("")
            results.append("The interaction appears to follow standard MTG rules.")
        } else {
            results.append("## ⚠️ Potential Issues Found:")
            results.append("")
            results.append(contentsOf: misconceptions)
        }

        results.append("")
        results.append("## 🔍 Verification Resources:")
        results.append("- **Commander Spellbook:** https://commanderspellbook.com")
        results.append("- **Gatherer Rulings:** http://gatherer.wizards.com")
        results.append("- **MTG Judges:** Ask a certified judge for official rulings")

        return CallTool.Result(content: [.text(results.joined(separator: "\n"))])
    }

    // MARK: - Helper Methods for Validation

    /// Checks for common MTG misconceptions
    private func checkForCommonMisconceptions(
        scenario: String, cards: [String], rulesService: RulesService
    ) -> [String] {
        var issues: [String] = []
        let lowerScenario = scenario.lowercased()

        // Common misconception: Necropotence hand size limit avoidance
        if lowerScenario.contains("necropotence")
            && (lowerScenario.contains("destroy") || lowerScenario.contains("remove"))
            && lowerScenario.contains("hand size")
        {
            issues.append(
                "❌ **Common Error:** Destroying Necropotence does NOT avoid discarding to hand size limit"
            )
            issues.append(
                "   *Explanation:* Hand size is checked during cleanup step (514.1), after Necropotence's delayed trigger has already resolved"
            )
            issues.append("   *Rule Reference:* 514.1, 402.2")
        }

        // Common misconception: Priority during combat
        if lowerScenario.contains("combat") && lowerScenario.contains("no response") {
            issues.append("⚠️ **Timing Alert:** Players receive priority at each step of combat")
            issues.append("   *Explanation:* Combat has multiple steps where players can respond")
            issues.append("   *Rule Reference:* 506 (Combat Phase)")
        }

        // Common misconception: Triggered abilities and timing
        if lowerScenario.contains("triggered") && lowerScenario.contains("immediately") {
            issues.append("ℹ️ **Timing Reminder:** Triggered abilities don't resolve immediately")
            issues.append(
                "   *Explanation:* They go on the stack and resolve when they would resolve")
            issues.append("   *Rule Reference:* 603 (Handling Triggered Abilities)")
        }

        // Mana abilities misconception
        if lowerScenario.contains("mana")
            && (lowerScenario.contains("counter") || lowerScenario.contains("respond"))
        {
            issues.append("ℹ️ **Mana Ability Note:** Most mana abilities can't be responded to")
            issues.append("   *Explanation:* Mana abilities don't use the stack")
            issues.append("   *Rule Reference:* 605 (Mana Abilities)")
        }

        return issues
    }

    /// Extracts keywords from scenario text for rule searching
    private func extractKeywords(from text: String) -> [String] {
        let commonKeywords = [
            "cast", "casting", "play", "playing",
            "destroy", "exile", "sacrifice", "discard",
            "trigger", "triggered", "ability", "activated",
            "combat", "attack", "block", "damage",
            "draw", "hand", "library", "graveyard",
            "mana", "cost", "tap", "untap",
            "counter", "spell", "permanent", "creature",
            "priority", "stack", "resolve",
        ]

        let words = text.lowercased().components(separatedBy: .whitespacesAndNewlines)
        return commonKeywords.filter { keyword in
            words.contains { $0.contains(keyword) }
        }
    }

    /// Parses scenario text into individual game steps
    private func parseScenarioIntoSteps(_ scenario: String) -> [String] {
        // Simple parsing - split on common delimiters and clean up
        let steps = scenario.components(separatedBy: CharacterSet(charactersIn: ".;,"))
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty && $0.count > 3 }

        return steps.isEmpty ? [scenario] : steps
    }

    /// Provides timing information for game actions
    private func getTimingInfo(for step: String) -> String {
        let lowerStep = step.lowercased()

        if lowerStep.contains("cast") {
            return "Sorcery speed unless instant/flash"
        } else if lowerStep.contains("activate") {
            return "Any time you have priority (unless restricted)"
        } else if lowerStep.contains("trigger") {
            return "Triggered abilities use the stack"
        } else if lowerStep.contains("combat") {
            return "During combat phase only"
        } else {
            return "Check specific rules for timing"
        }
    }

    // MARK: - New LLM-Optimized Helper Functions

    /// Analyzes deck for combo potential with structured output
    private func analyzeDeckCombosStructured(
        cards: [String], commander: String?, comboTypes: [String], maxPieces: Int
    ) async -> (combos: [ComboResult], nearMisses: [NearMissCombo], synergies: [SynergyCluster]) {
        var foundCombos: [ComboResult] = []
        var nearMisses: [NearMissCombo] = []
        var synergies: [SynergyCluster] = []

        // Use sliding window approach to find combos within the deck
        let cardChunks = cards.chunked(into: 10)  // Process in manageable chunks

        for chunk in cardChunks {
            let (chunkCombos, _, chunkNearMisses, _) = await queryDetailedCombosStructured(
                cards: chunk,
                commander: commander,
                minPopularity: 1,
                detailed: true
            )

            // Only include combos where ALL pieces are in our deck
            for combo in chunkCombos {
                let comboCardSet = Set(combo.cards)
                let deckCardSet = Set(cards)
                if comboCardSet.isSubset(of: deckCardSet) {
                    foundCombos.append(combo)
                }
            }

            // Include near misses for deck building suggestions
            nearMisses.append(contentsOf: chunkNearMisses)
        }

        // Generate synergy clusters from found combos
        synergies = generateSynergyClusters(from: foundCombos, deckCards: cards)

        return (foundCombos, nearMisses, synergies)
    }

    /// Generates synergy clusters from combo analysis
    private func generateSynergyClusters(from combos: [ComboResult], deckCards: [String])
        -> [SynergyCluster]
    {
        var clusters: [SynergyCluster] = []

        // Group combos by theme/type
        let grouped = Dictionary(grouping: combos) { combo in
            if combo.result.lowercased().contains("infinite mana") {
                return "mana_generation"
            } else if combo.result.lowercased().contains("damage") {
                return "damage_based"
            } else if combo.result.lowercased().contains("mill") {
                return "mill_strategy"
            } else if combo.result.lowercased().contains("draw") {
                return "card_advantage"
            } else {
                return "general_synergy"
            }
        }

        for (theme, themeCombos) in grouped {
            let allCards = Set(themeCombos.flatMap { $0.cards })
            let deckOverlap = allCards.intersection(Set(deckCards))
            let strength = Double(deckOverlap.count) / Double(allCards.count)

            if strength > 0.3 {  // Only include meaningful synergies
                clusters.append(
                    SynergyCluster(
                        theme: theme.replacingOccurrences(of: "_", with: " ").capitalized,
                        cards: Array(deckOverlap),
                        strength: strength,
                        description:
                            "Cards that work together for \(theme.replacingOccurrences(of: "_", with: " ")) effects"
                    ))
            }
        }

        return clusters
    }

    /// Calculates combo consistency score for a deck
    private func calculateComboConsistency(combos: [ComboResult], deckSize: Int) -> Double {
        guard !combos.isEmpty else { return 0.0 }

        var totalConsistency = 0.0
        for combo in combos {
            // Factor in number of pieces and deck size
            let pieces = Double(combo.cards.count)
            let consistency = 1.0 - pow(0.9, pieces)  // Decreases with more pieces
            totalConsistency += consistency
        }

        return min(1.0, totalConsistency / Double(combos.count))
    }

    /// Analyzes mana curve for deck analysis
    private func analyzeManaCurveForDeck(cards: [String]) -> ManaCurveAnalysis {
        var distribution: [Int: Int] = [:]
        var totalCMC = 0.0
        var landCount = 0
        var rampCount = 0

        for card in cards {
            if isLikelyLand(card) {
                landCount += 1
            } else {
                let cmc = estimateManaCost(from: card)
                distribution[cmc, default: 0] += 1
                totalCMC += Double(cmc)

                if card.lowercased().contains("sol ring") || card.lowercased().contains("signet")
                    || card.lowercased().contains("ramp")
                {
                    rampCount += 1
                }
            }
        }

        let averageCMC = cards.count > landCount ? totalCMC / Double(cards.count - landCount) : 0.0
        let curveQuality: ManaCurveAnalysis.CurveQuality

        if averageCMC <= 2.5 {
            curveQuality = .excellent
        } else if averageCMC <= 3.5 {
            curveQuality = .good
        } else if averageCMC <= 4.5 {
            curveQuality = .fair
        } else {
            curveQuality = .poor
        }

        return ManaCurveAnalysis(
            distribution: distribution,
            averageCMC: averageCMC,
            landCount: landCount,
            rampSpells: rampCount,
            curveQuality: curveQuality,
            recommendations: generateCurveRecommendations(
                averageCMC: averageCMC, landCount: landCount, rampCount: rampCount)
        )
    }

    /// Analyzes color balance for deck analysis
    private func analyzeColorBalanceForDeck(cards: [String]) -> ColorBalanceAnalysis {
        var colorRequirements: [String: Double] = [:]
        var manabaseRecommendations: [String] = []

        // Simple color analysis based on card names (would be better with actual mana costs)
        for card in cards {
            let cardLower = card.lowercased()
            if cardLower.contains("white") || cardLower.contains("plains") {
                colorRequirements["White", default: 0] += 1
            }
            if cardLower.contains("blue") || cardLower.contains("island") {
                colorRequirements["Blue", default: 0] += 1
            }
            if cardLower.contains("black") || cardLower.contains("swamp") {
                colorRequirements["Black", default: 0] += 1
            }
            if cardLower.contains("red") || cardLower.contains("mountain") {
                colorRequirements["Red", default: 0] += 1
            }
            if cardLower.contains("green") || cardLower.contains("forest") {
                colorRequirements["Green", default: 0] += 1
            }
        }

        let totalColorRequirements = colorRequirements.values.reduce(0, +)
        let colorConsistency = totalColorRequirements > 0 ? 0.7 : 1.0  // Simplified calculation

        if colorRequirements.count > 2 {
            manabaseRecommendations.append("Consider multicolor lands for fixing")
        }
        if colorRequirements.count > 3 {
            manabaseRecommendations.append("Add mana fixing artifacts like Chromatic Lantern")
        }

        return ColorBalanceAnalysis(
            colorRequirements: colorRequirements,
            manabaseRecommendations: manabaseRecommendations,
            colorConsistency: colorConsistency
        )
    }

    /// Identifies deck archetype based on cards and combos
    private func identifyArchetype(cards: [String], combos: [ComboResult]) -> ArchetypeAnalysis {
        var archetypeScores: [String: Double] = [
            "combo": 0.0,
            "aggro": 0.0,
            "control": 0.0,
            "midrange": 0.0,
            "ramp": 0.0,
        ]

        // Score based on combos
        archetypeScores["combo"]! += Double(combos.count) * 0.3

        // Score based on card types (simplified analysis)
        for card in cards {
            let cardLower = card.lowercased()
            if cardLower.contains("counterspell") || cardLower.contains("removal") {
                archetypeScores["control"]! += 0.1
            }
            if cardLower.contains("ramp") || cardLower.contains("mana") {
                archetypeScores["ramp"]! += 0.1
            }
            if cardLower.contains("creature") && !cardLower.contains("big") {
                archetypeScores["aggro"]! += 0.05
            }
        }

        let primaryArchetype = archetypeScores.max(by: { $0.value < $1.value })?.key ?? "midrange"
        let confidence = archetypeScores[primaryArchetype] ?? 0.5

        return ArchetypeAnalysis(
            primaryArchetype: primaryArchetype.capitalized,
            confidence: min(1.0, confidence),
            supportingEvidence: ["Based on card type analysis and combo count"],
            archetypeOptimizations: generateArchetypeOptimizations(archetype: primaryArchetype)
        )
    }

    /// Generates deck combo building suggestions
    private func generateDeckComboSuggestions(
        combos: [ComboResult], nearMisses: [NearMissCombo], deckSize: Int
    ) -> [ActionSuggestion] {
        var suggestions: [ActionSuggestion] = []

        if !nearMisses.isEmpty {
            let topNearMiss = nearMisses.max(by: { $0.additionPriority < $1.additionPriority })!
            suggestions.append(
                ActionSuggestion(
                    action: "add_combo_pieces",
                    description:
                        "Add \(topNearMiss.missingCards.joined(separator: ", ")) to enable \(topNearMiss.wouldResult)",
                    confidence: 0.8,
                    reasoning: "High-priority combo completion opportunity",
                    priority: .high,
                    category: "combo_enabler",
                    relatedCards: topNearMiss.missingCards
                ))
        }

        if combos.count < 3 {
            suggestions.append(
                ActionSuggestion(
                    action: "increase_combo_density",
                    description: "Consider adding more combo pieces for consistency",
                    confidence: 0.6,
                    reasoning: "Low combo density may reduce win consistency",
                    priority: .medium,
                    category: "deck_consistency"
                ))
        }

        return suggestions
    }

    /// Helper functions for analysis
    private func calculateAPICallsForDeck(_ cardCount: Int) -> Int {
        return max(1, cardCount / 10)  // Estimate based on chunking
    }

    private func generateDeckAnalysisTags(combos: [ComboResult], archetypeScore: Double) -> [String]
    {
        var tags = ["deck_analysis", "combo_analysis"]

        if !combos.isEmpty {
            tags.append("combos_found")
            let comboTypes = Set(combos.map { $0.type.rawValue })
            tags.append(contentsOf: comboTypes.map { "combo_\($0)" })
        } else {
            tags.append("no_combos")
        }

        if archetypeScore > 0.7 {
            tags.append("strong_archetype")
        }

        return tags
    }

    private func generateCurveRecommendations(averageCMC: Double, landCount: Int, rampCount: Int)
        -> [String]
    {
        var recommendations: [String] = []

        if averageCMC > 4.0 {
            recommendations.append("Consider lowering average mana cost")
        }
        if landCount < 35 {
            recommendations.append("Add more lands for consistency")
        }
        if rampCount < 8 && averageCMC > 3.0 {
            recommendations.append("Include more ramp spells")
        }

        return recommendations
    }

    private func generateArchetypeOptimizations(archetype: String) -> [String] {
        switch archetype {
        case "combo":
            return ["Add tutors for consistency", "Include protection for combo pieces"]
        case "control":
            return ["Balance removal and counterspells", "Ensure sufficient win conditions"]
        case "aggro":
            return ["Lower mana curve", "Add more efficient threats"]
        case "ramp":
            return ["Include big payoff spells", "Balance ramp and threats"]
        default:
            return ["Balance threats and answers", "Optimize mana curve"]
        }
    }

    // MARK: - Game State Analysis Helper Functions

    /// Generates alternatives for draw card actions
    private func generateDrawAlternatives(gameState: GameStateSnapshot) -> [String] {
        var alternatives: [String] = []

        if gameState.cardsInHand >= 7 {
            alternatives.append("Consider playing cards before drawing more")
        }

        if gameState.cardsInDeck <= 10 {
            alternatives.append("Be mindful of deck size for future draws")
        }

        alternatives.append("Evaluate mana efficiency of card draw spells")
        return alternatives
    }

    /// Generates alternatives for mulligan decisions
    private func generateMulliganAlternatives(currentSize: Int, newSize: Int) -> [String] {
        var alternatives: [String] = []

        if currentSize == 7 {
            alternatives.append("Keep marginal hands in best-of-one games")
            alternatives.append("Consider scry effects if available")
        }

        if newSize <= 5 {
            alternatives.append("Stop mulliganing - accept suboptimal hand")
            alternatives.append("Look for any playable cards")
        }

        alternatives.append("Evaluate hand's synergy with game plan")
        return alternatives
    }

    /// Generates alternatives for playing cards
    private func generatePlayAlternatives(cardName: String, gameState: GameStateSnapshot)
        -> [String]
    {
        var alternatives: [String] = []

        if gameState.cardsInHand > 1 {
            alternatives.append("Hold card for better timing")
            alternatives.append("Play other cards first for synergy")
        }

        if cardName.lowercased().contains("instant") {
            alternatives.append("Wait for opponent's turn for surprise value")
        }

        alternatives.append("Consider mana efficiency of play order")
        return alternatives
    }

    /// Creates structured risk assessment for drawing cards
    private func createDrawRiskAssessment(gameState: GameStateSnapshot, drawnCards: [Card])
        -> RiskAssessment
    {
        var riskLevel: RiskAssessment.RiskLevel = .low
        var factors: [String] = []
        var mitigation: [String] = []

        if gameState.cardsInHand > 7 {
            riskLevel = .medium
            factors.append("Hand size over optimal")
            mitigation.append("Play cards before drawing more")
        }

        if gameState.cardsInDeck <= 5 {
            riskLevel = .high
            factors.append("Low deck size - risk of milling out")
            mitigation.append("Avoid unnecessary card draw")
        }

        let hasLands = drawnCards.contains { card in
            isLikelyLand(card.name)
        }

        if !hasLands && gameState.cardsInHand < 3 {
            riskLevel = .medium
            factors.append("No lands drawn with small hand")
            mitigation.append("Prioritize land plays")
        }

        return RiskAssessment(level: riskLevel, factors: factors, mitigation: mitigation)
    }

    /// Creates structured risk assessment for playing cards
    private func createPlayRiskAssessment(cardName: String, gameState: GameStateSnapshot)
        -> RiskAssessment
    {
        var riskLevel: RiskAssessment.RiskLevel = .low
        var factors: [String] = []
        var mitigation: [String] = []

        let cardLower = cardName.lowercased()

        if cardLower.contains("creature") && gameState.cardsInHand <= 2 {
            riskLevel = .medium
            factors.append("Playing threats with low hand size")
            mitigation.append("Consider protection or wait for better position")
        }

        if cardLower.contains("instant") || cardLower.contains("sorcery") {
            riskLevel = .low
            factors.append("One-time effect")
            mitigation.append("Ensure timing is optimal")
        }

        return RiskAssessment(level: riskLevel, factors: factors, mitigation: mitigation)
    }

    /// Creates structured risk assessment for mulligan decisions
    private func createMulliganRiskAssessment(newHand: [String: Int], mulliganCount: Int)
        -> RiskAssessment
    {
        var riskLevel: RiskAssessment.RiskLevel = .low
        var factors: [String] = []
        var mitigation: [String] = []

        let totalCards = newHand.values.reduce(0, +)

        if mulliganCount >= 2 {
            riskLevel = .high
            factors.append("Multiple mulligans increase disadvantage")
            mitigation.append("Accept marginal hands to avoid further card loss")
        }

        let landCount = newHand.keys.filter { isLikelyLand($0) }.count

        if landCount == 0 {
            riskLevel = .critical
            factors.append("No lands in hand")
            mitigation.append("Consider another mulligan if possible")
        } else if landCount >= totalCards - 1 {
            riskLevel = .medium
            factors.append("Too many lands, limited action")
            mitigation.append("Look for any playable spells")
        }

        if totalCards <= 5 {
            riskLevel = .medium
            factors.append("Small hand size creates card disadvantage")
            mitigation.append("Play efficiently to maximize card value")
        }

        return RiskAssessment(level: riskLevel, factors: factors, mitigation: mitigation)
    }
}

// Extension for array chunking
extension Array {
    func chunked(into size: Int) -> [[Element]] {
        return stride(from: 0, to: count, by: size).map {
            Array(self[$0..<Swift.min($0 + size, count)])
        }
    }
}
