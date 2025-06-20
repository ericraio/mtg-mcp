# MTG MCP Servers

A Swift implementation of Magic: The Gathering (MTG) Model Context Protocol (MCP) servers, providing deck management and card search capabilities through the MCP protocol.

## Overview

This project provides two MCP servers:

1. **MTG Deck Manager** (`mtg-mcp`) - Game state management including deck loading, card drawing, mulligans, and sideboarding
2. **Scryfall API Server** (`scryfall-mcp`) - Card information retrieval using the Scryfall API

Both servers implement the MCP protocol for seamless integration with MCP-compatible clients like Claude Desktop.

## Features

### MTG Deck Manager
- **Deck Loading**: Parse and load deck lists in various formats
- **Game State Management**: Track deck, hand, and sideboard contents
- **Card Drawing**: Draw cards from deck to hand with proper shuffling
- **Mulligan Support**: London mulligan implementation
- **Sideboarding**: Swap cards between main deck/sideboard and hand
- **Game Reset**: Reset to initial game state
- **Statistics**: Real-time deck and hand statistics

### Scryfall API Server
- **Card Search**: Advanced card search using Scryfall query syntax
- **Random Cards**: Generate random cards with optional filters
- **Name Lookup**: Find cards by exact or fuzzy name matching
- **Rich Card Data**: Complete card information including images, prices, and legalities

## Installation

### Prerequisites

- Swift 6.2 or later
- macOS 13 or later

### Build from Source

```bash
# Clone the repository
git clone <repository-url>
cd mtg-mcp

# Build the project
swift build

# Run tests
swift test
```

### Install Executables

```bash
# Build in release mode
swift build -c release

# Install to local bin (optional)
cp .build/release/mtg-mcp /usr/local/bin/
cp .build/release/scryfall-mcp /usr/local/bin/
```

## Usage

### Running the Servers

#### MTG Deck Manager Server
```bash
# Run with stdio transport (for MCP integration)
swift run mtg-mcp --transport stdio

# Run standalone for testing
swift run mtg-mcp --transport stdio --verbose
```

#### Scryfall API Server
```bash
# Run with stdio transport
swift run scryfall-mcp --transport stdio

# Run with debug output
swift run scryfall-mcp --transport stdio --verbose
```

### MCP Integration

#### Claude Desktop Configuration

Add the servers to your Claude Desktop configuration file. The configuration file is typically located at:

- **macOS**: `~/Library/Application Support/Claude/claude_desktop_config.json`
- **Windows**: `%APPDATA%\Claude\claude_desktop_config.json`

##### Option 1: Using Swift Run (Development)

```json
{
  "mcpServers": {
    "mtg-deck-manager": {
      "command": "swift",
      "args": ["run", "mtg-mcp", "--transport", "stdio"],
      "cwd": "/path/to/mtg-mcp"
    },
    "scryfall-api": {
      "command": "swift", 
      "args": ["run", "scryfall-mcp", "--transport", "stdio"],
      "cwd": "/path/to/mtg-mcp"
    },
    "rules-splitter": {
      "command": "swift",
      "args": ["run", "rules-splitter"],
      "cwd": "/path/to/mtg-mcp"
    }
  }
}
```

##### Option 2: Using Built Executables (Production)

```json
{
  "mcpServers": {
    "mtg-deck-manager": {
      "command": "/path/to/.build/release/mtg-mcp",
      "args": ["--transport", "stdio"]
    },
    "scryfall-api": {
      "command": "/path/to/.build/release/scryfall-mcp", 
      "args": ["--transport", "stdio"]
    }
  }
}
```

##### Complete Configuration Example

```json
{
  "mcpServers": {
    "mtg-deck-manager": {
      "command": "swift",
      "args": ["run", "mtg-mcp", "--transport", "stdio"],
      "cwd": "/Users/ericraio/mcp/mtg-mcp"
    },
    "scryfall-api": {
      "command": "swift", 
      "args": ["run", "scryfall-mcp", "--transport", "stdio"],
      "cwd": "/Users/ericraio/mcp/mtg-mcp"
    }
  }
}
```

##### Production Configuration (Recommended)

First, build the executables:
```bash
cd /Users/ericraio/mcp/mtg-mcp
swift build -c release
```

Then use this configuration:
```json
{
  "mcpServers": {
    "mtg-deck-manager": {
      "command": "/Users/ericraio/mcp/mtg-mcp/.build/release/mtg-mcp",
      "args": ["--transport", "stdio"]
    },
    "scryfall-api": {
      "command": "/Users/ericraio/mcp/mtg-mcp/.build/release/scryfall-mcp",
      "args": ["--transport", "stdio"]
    }
  }
}
```

**Important Notes:**
- The `cwd` path must point to `/Users/ericraio/mcp/mtg-mcp` where Package.swift exists
- Production builds are faster and more reliable than development builds
- Restart Claude Desktop after updating the configuration

#### Verifying the Setup

After adding the configuration:

1. **Restart Claude Desktop**
2. **Start a new conversation**
3. **Test the integration** by asking Claude to:
   - "Show me what MTG tools are available"
   - "Load a simple MTG deck and draw some cards"
   - "Search for Lightning Bolt using Scryfall"
   - "Look up MTG rule 100.1"

#### Tool Usage Examples

Once connected, you can use these tools through your MCP client:

##### Basic Deck Management
```
# Load a deck
upload_deck with deck_list: "
Deck
4 Lightning Bolt
4 Counterspell  
4 Island
4 Mountain
44 Basic lands

Sideboard
2 Negate
1 Spell Pierce
"

# Draw opening hand
draw_card with count: 7

# View your hand
view_hand

# Get deck statistics
view_deck_stats

# Play a card
play_card with card_name: "Lightning Bolt"

# Mulligan to 6 cards
mulligan with new_hand_size: 6
```

##### Rules Lookup & Learning
```
# Look up specific rules
lookup_rule with rule_number: "100.1"
lookup_rule with rule_number: "601.2a"

# Search for rules about concepts
search_rules with concept: "mulligan"
search_rules with concept: "combat"
search_rules with keywords: "cast spell"

# Get comprehensive explanations
explain_concept with concept: "priority"
explain_concept with concept: "triggered abilities"
explain_concept with concept: "stack"
```

##### Card Search & Information
```
# Search for cards
search_cards with query: "c:red cmc<=3 t:instant"
search_cards with query: "t:creature pow>=4"

# Get random cards
get_random_card
get_random_card with query: "c:blue t:counterspell"

# Look up specific cards
lookup_card_exact with exact: "Lightning Bolt"
lookup_card_fuzzy with fuzzy: "Jace Mind Sculptor"
```

##### Advanced Game Scenarios
```
# Sideboarding
sideboard_swap with remove_card: "Lightning Bolt" and add_card: "Negate"

# Reset game state
reset_game

# Commander deck setup
upload_deck with deck_list: "
Commander
1 Atraxa, Praetors' Voice

Deck  
1 Sol Ring
1 Command Tower
98 Forest
"
```

## Example Claude Prompts

Here are example prompts you can use with Claude Desktop once the MCP servers are configured:

### 🎮 **Game Management Prompts**

**"Help me test my burn deck"**
```
Load this burn deck and simulate an opening hand:

4 Lightning Bolt
4 Lava Spike  
4 Monastery Swiftspear
4 Eidolon of the Great Revel
20 Mountain
4 Fireblast

Sideboard:
3 Smash to Smithereens
2 Pyroblast

Then draw 7 cards and tell me what kind of opening hand I got.
```

**"Simulate a mulligan decision"**
```
I want to practice mulligan decisions. Load a competitive deck, draw a 7-card opening hand, and tell me if you think I should keep it or mulligan based on the cards drawn.
```

### 📚 **Rules Learning Prompts**

**"Teach me about the stack"**
```
I'm confused about how the stack works in Magic. Can you:
1. Look up the official rules about the stack
2. Explain how priority works with it
3. Give me an example of how spells and abilities resolve
```

**"Combat damage rules"**
```
Look up the official MTG rules about combat damage and explain:
- When damage is dealt
- How first strike works
- What happens with deathtouch
- How trample calculates excess damage
```

### 🔍 **Card Research Prompts**

**"Find cards for my combo deck"**
```
I'm building an artifact combo deck. Search for:
1. Red instants that cost 3 mana or less
2. Artifacts that produce mana
3. Cards that let me draw cards when artifacts enter

Show me the most relevant options.
```

**"Random deck inspiration"**
```
Give me 5 random cards and help me brainstorm a deck theme that could use all of them together.
```

### 🏆 **Learning & Strategy Prompts**

**"Rules quiz me"**
```
Quiz me on MTG rules! Look up a random rule number and ask me to explain what it means, then show me the official rule text to check my answer.
```

**"Deck analysis"**
```  
Load this deck list and analyze it:
- What's the mana curve?
- What's the game plan?
- What rules should I know for the key cards?
- What are potential weaknesses?

[paste deck list here]
```

## Deck Format Support

The deck parser supports multiple formats:

### Standard Format
```
Deck
4 Lightning Bolt
4 Counterspell
20 Island

Sideboard
2 Negate
1 Spell Pierce
```

### Commander Format
```
Commander
1 Atraxa, Praetors' Voice

Deck
1 Sol Ring
1 Command Tower
98 Forest
```

### With Set Information
```
Deck
4 Lightning Bolt (LEA) 
4 Counterspell [7ED]
20 Island
```

### Headerless Format
```
4 Lightning Bolt
4 Counterspell  
20 Island
```

## Available MCP Tools

### MTG Deck Manager Tools

| Tool | Description | Parameters |
|------|-------------|------------|
| `upload_deck` | Load a deck list | `deck_list`: String containing deck list |
| `draw_card` | Draw cards from deck | `count`: Number of cards to draw (default: 1) |
| `view_hand` | Get current hand contents | None |
| `view_deck_stats` | Get deck statistics | None |  
| `play_card` | Play a card from hand | `card_name`: Name of card to play |
| `mulligan` | Mulligan to new hand size | `new_hand_size`: Size of new hand (optional) |
| `sideboard_swap` | Swap cards with sideboard | `remove_card`: Card to remove<br>`add_card`: Card to add |
| `reset_game` | Reset game state | None |
| `lookup_rule` | Look up specific MTG rule | `rule_number`: Rule number (e.g., "100", "601.2a") |
| `search_rules` | Search MTG rules | `keywords`: Keywords to search (optional)<br>`concept`: Game concept (optional) |
| `explain_concept` | Get comprehensive rule explanations | `concept`: Game concept to explain |

### Scryfall API Tools

| Tool | Description | Parameters |
|------|-------------|------------|
| `search_cards` | Search for cards | `query`: Scryfall search query<br>`page`: Page number (optional) |
| `get_random_card` | Get random card | `query`: Filter query (optional) |
| `lookup_card_exact` | Find card by exact name | `exact`: Exact card name |
| `lookup_card_fuzzy` | Find card by fuzzy name | `fuzzy`: Approximate card name |

### Rules Splitter Tool

| Tool | Description | Parameters |
|------|-------------|------------|
| `rules-splitter` | Download and split MTG rules into sections | `url`: Custom rules URL (optional) |

## Development

### Project Structure

```
mtg-mcp/
├── Sources/
│   ├── mtg-mcp/           # MTG Deck Manager server
│   │   └── mtg_mcp.swift  # Main server with rules integration
│   ├── scryfall-mcp/      # Scryfall API server
│   │   └── scryfall_mcp.swift
│   ├── rules-splitter/    # Rules processing tool
│   │   └── main.swift     # Rule file splitter CLI
│   ├── MTGModels/         # Shared models
│   │   ├── Card.swift
│   │   ├── GameState.swift
│   │   ├── ManaCost.swift
│   │   └── Rarity.swift
│   └── MTGServices/       # Shared services
│       ├── DeckParser.swift
│       └── RulesService.swift  # NEW: Rules lookup service
├── Tests/
│   └── mtg-mcpTests/      # Comprehensive test suite
│       ├── CardModelTests.swift
│       ├── DeckParserTests.swift
│       ├── GameStateTests.swift
│       ├── IntegrationTests.swift
│       ├── TestDataLoader.swift
│       └── TestData/      # Sample deck files
├── rules/                 # Generated MTG rules (144 files)
│   ├── 100_general.md
│   ├── 601_casting_spells.md
│   └── ... (142 more rule files)
└── Package.swift
```

### Dependencies

- **MCP Swift SDK** (0.9.0+) - MCP protocol implementation
- **SwiftGzip** - Compression support for Scryfall API
- **ArgumentParser** - Command-line argument parsing

### Running Tests

```bash
# Run all tests
swift test

# Run specific test suite
swift test --filter CardModelTests

# Run tests with verbose output
swift test --verbose
```

### Code Style

The project follows Swift best practices:
- Swift actors for thread-safe game state management
- Sendable protocol conformance for concurrent access
- Comprehensive error handling with Result types
- Async/await patterns throughout
- Unit tests with >90% coverage

## Architecture

### Thread Safety
Game state is managed using Swift's `actor` system, ensuring thread-safe access to mutable state across concurrent MCP tool calls.

### Error Handling
Comprehensive error handling using Swift's `Result` type and custom error types for different failure scenarios.

### MCP Integration
Both servers implement the MCP protocol using the official Swift SDK, providing:
- Tool registration and discovery
- Request/response handling
- Transport abstraction (stdio, HTTP)
- Proper error propagation

## API Reference

### Card Model

```swift
public struct Card: Identifiable, Equatable, Hashable, Codable, Sendable {
    public let id: String
    public var name: String
    public var manaCostString: String
    public var kind: CardKind
    public var rarity: Rarity
    public var typeLine: String
    public var oracleText: String
    public var power: String?
    public var toughness: String?
    public var loyalty: String?
}
```

### Game State Actor

```swift
public actor GameState {
    public func loadDeck(_ deckData: DeckData) async
    public func drawCards(count: Int) async -> [Card]
    public func playCard(named cardName: String) async -> Card?
    public func mulligan(newHandSize: Int) async -> [Card]
    public func sideboardSwap(removeCard: String, addCard: String) async -> (removed: Card?, added: Card?)
    public func resetGame() async
    public func getDeckStats() async -> DeckStats
    public func getHandContents() async -> [String: Int]
}
```

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests for new functionality
5. Ensure all tests pass
6. Submit a pull request

## License

This project is provided as-is for educational and development purposes.

## Acknowledgments

- **MCP Protocol** - For the standardized AI integration protocol
- **Scryfall API** - For comprehensive MTG card data
- **swift-landlord** - For reference MTG models and game logic
- **MCP Swift SDK** - For the official Swift MCP implementation
