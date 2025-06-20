# API Documentation

This document provides detailed information about the MCP tools and schemas used by the MTG MCP servers.

## Tool Schemas

### MTG Deck Manager Tools

#### load_deck
Load a deck list into the game state.

**Schema:**
```json
{
  "name": "load_deck",
  "description": "Load a deck list for game management",
  "inputSchema": {
    "type": "object",
    "properties": {
      "deck_text": {
        "type": "string",
        "description": "The deck list in supported format (with Deck/Sideboard/Commander headers or quantities only)"
      }
    },
    "required": ["deck_text"]
  }
}
```

**Example Usage:**
```json
{
  "name": "load_deck",
  "arguments": {
    "deck_text": "Deck\n4 Lightning Bolt\n4 Counterspell\n20 Island\n\nSideboard\n2 Negate\n1 Spell Pierce"
  }
}
```

**Response:**
```json
{
  "isError": false,
  "content": [
    {
      "type": "text",
      "text": "Deck loaded successfully. Main deck: 28 cards, Sideboard: 3 cards"
    }
  ]
}
```

#### draw_cards
Draw cards from the deck to hand.

**Schema:**
```json
{
  "name": "draw_cards", 
  "description": "Draw cards from deck to hand",
  "inputSchema": {
    "type": "object",
    "properties": {
      "count": {
        "type": "integer",
        "description": "Number of cards to draw",
        "minimum": 1,
        "maximum": 20
      }
    },
    "required": ["count"]
  }
}
```

**Example Usage:**
```json
{
  "name": "draw_cards",
  "arguments": {
    "count": 7
  }
}
```

**Response:**
```json
{
  "isError": false,
  "content": [
    {
      "type": "text", 
      "text": "Drew 7 cards: Lightning Bolt, Lightning Bolt, Counterspell, Island, Island, Island, Island"
    }
  ]
}
```

#### get_hand_contents
Get the current contents of the hand.

**Schema:**
```json
{
  "name": "get_hand_contents",
  "description": "Get current hand contents with card counts",
  "inputSchema": {
    "type": "object",
    "properties": {}
  }
}
```

**Response:**
```json
{
  "isError": false,
  "content": [
    {
      "type": "text",
      "text": "Hand contents:\n- Lightning Bolt: 2\n- Counterspell: 1\n- Island: 4"
    }
  ]
}
```

#### get_deck_stats
Get comprehensive deck statistics.

**Schema:**
```json
{
  "name": "get_deck_stats",
  "description": "Get current deck, hand, and sideboard statistics",
  "inputSchema": {
    "type": "object", 
    "properties": {}
  }
}
```

**Response:**
```json
{
  "isError": false,
  "content": [
    {
      "type": "text",
      "text": "Deck Statistics:\n- Cards in deck: 21\n- Cards in hand: 7\n- Sideboard cards: 3\n- Total cards: 31"
    }
  ]
}
```

#### play_card
Play a card from hand.

**Schema:**
```json
{
  "name": "play_card",
  "description": "Play a card from hand (removes from hand)",
  "inputSchema": {
    "type": "object",
    "properties": {
      "card_name": {
        "type": "string",
        "description": "Name of the card to play"
      }
    },
    "required": ["card_name"]
  }
}
```

**Example Usage:**
```json
{
  "name": "play_card",
  "arguments": {
    "card_name": "Lightning Bolt"
  }
}
```

**Response:**
```json
{
  "isError": false,
  "content": [
    {
      "type": "text",
      "text": "Played Lightning Bolt"
    }
  ]
}
```

#### mulligan
Perform a mulligan to a new hand size.

**Schema:**
```json
{
  "name": "mulligan",
  "description": "Mulligan current hand to new size (London mulligan rules)",
  "inputSchema": {
    "type": "object",
    "properties": {
      "new_hand_size": {
        "type": "integer",
        "description": "Size of new hand after mulligan",
        "minimum": 1,
        "maximum": 7
      }
    },
    "required": ["new_hand_size"]
  }
}
```

**Example Usage:**
```json
{
  "name": "mulligan",
  "arguments": {
    "new_hand_size": 6
  }
}
```

**Response:**
```json
{
  "isError": false,
  "content": [
    {
      "type": "text",
      "text": "Mulliganed to 6 cards: Lightning Bolt, Counterspell, Island, Island, Island, Mountain"
    }
  ]
}
```

#### sideboard_swap
Swap cards between main deck/hand and sideboard.

**Schema:**
```json
{
  "name": "sideboard_swap",
  "description": "Swap cards between deck/hand and sideboard",
  "inputSchema": {
    "type": "object",
    "properties": {
      "remove_card": {
        "type": "string",
        "description": "Name of card to remove from deck/hand"
      },
      "add_card": {
        "type": "string", 
        "description": "Name of card to add from sideboard"
      }
    },
    "required": ["remove_card", "add_card"]
  }
}
```

**Example Usage:**
```json
{
  "name": "sideboard_swap",
  "arguments": {
    "remove_card": "Counterspell",
    "add_card": "Negate"
  }
}
```

**Response:**
```json
{
  "isError": false,
  "content": [
    {
      "type": "text",
      "text": "Swapped Counterspell for Negate"
    }
  ]
}
```

#### reset_game  
Reset the game to initial state.

**Schema:**
```json
{
  "name": "reset_game",
  "description": "Reset game state to initial configuration",
  "inputSchema": {
    "type": "object",
    "properties": {}
  }
}
```

**Response:**
```json
{
  "isError": false,
  "content": [
    {
      "type": "text",
      "text": "Game reset. Deck shuffled and hand cleared."
    }
  ]
}
```

### Scryfall API Tools

#### search_cards
Search for cards using Scryfall query syntax.

**Schema:**
```json
{
  "name": "search_cards",
  "description": "Search for Magic cards using Scryfall query syntax",
  "inputSchema": {
    "type": "object",
    "properties": {
      "query": {
        "type": "string",
        "description": "Scryfall search query (e.g., 'c:red cmc<=3', 't:instant', 'o:draw')"
      },
      "page": {
        "type": "integer",
        "description": "Page number for paginated results (optional)",
        "minimum": 1,
        "default": 1
      }
    },
    "required": ["query"]
  }
}
```

**Example Usage:**
```json
{
  "name": "search_cards",
  "arguments": {
    "query": "c:red cmc<=3 t:instant",
    "page": 1
  }
}
```

**Response:**
```json
{
  "isError": false,
  "content": [
    {
      "type": "text",
      "text": "Found 25 cards matching 'c:red cmc<=3 t:instant':\n\n1. Lightning Bolt (LEA)\n   Cost: {R} | Type: Instant\n   Lightning Bolt deals 3 damage to any target.\n\n2. Shock (M21)\n   Cost: {R} | Type: Instant  \n   Shock deals 2 damage to any target.\n\n..."
    }
  ]
}
```

#### get_random_card
Get a random Magic card, optionally filtered.

**Schema:**
```json
{
  "name": "get_random_card",
  "description": "Get a random Magic card, optionally filtered by query",
  "inputSchema": {
    "type": "object",
    "properties": {
      "query": {
        "type": "string",
        "description": "Optional filter query (e.g., 'c:blue', 't:creature')"
      }
    }
  }
}
```

**Example Usage:**
```json
{
  "name": "get_random_card",
  "arguments": {
    "query": "t:creature c:green"
  }
}
```

**Response:**
```json
{
  "isError": false,
  "content": [
    {
      "type": "text",
      "text": "Random Card: Grizzly Bears (LEA)\nCost: {1}{G} | Type: Creature — Bear\nPower/Toughness: 2/2\nText: (No rules text)\nRarity: Common"
    }
  ]
}
```

#### lookup_card_exact
Find a card by exact name match.

**Schema:**
```json
{
  "name": "lookup_card_exact", 
  "description": "Find a card by exact name match",
  "inputSchema": {
    "type": "object",
    "properties": {
      "exact": {
        "type": "string",
        "description": "Exact card name to find"
      }
    },
    "required": ["exact"]
  }
}
```

**Example Usage:**
```json
{
  "name": "lookup_card_exact",
  "arguments": {
    "exact": "Lightning Bolt"
  }
}
```

**Response:**
```json
{
  "isError": false,
  "content": [
    {
      "type": "text",
      "text": "Lightning Bolt (LEA)\nCost: {R} | Type: Instant\nText: Lightning Bolt deals 3 damage to any target.\nRarity: Common\nLegalities: Legacy: Legal, Vintage: Legal, Commander: Legal"
    }
  ]
}
```

#### lookup_card_fuzzy
Find a card by fuzzy name match.

**Schema:**
```json
{
  "name": "lookup_card_fuzzy",
  "description": "Find a card by approximate name match",
  "inputSchema": {
    "type": "object", 
    "properties": {
      "fuzzy": {
        "type": "string",
        "description": "Approximate card name to find"
      }
    },
    "required": ["fuzzy"]
  }
}
```

**Example Usage:**
```json
{
  "name": "lookup_card_fuzzy",
  "arguments": {
    "fuzzy": "lighting bolt"
  }
}
```

**Response:**
```json
{
  "isError": false,
  "content": [
    {
      "type": "text",
      "text": "Found: Lightning Bolt (LEA)\nCost: {R} | Type: Instant\nText: Lightning Bolt deals 3 damage to any target.\nRarity: Common"
    }
  ]
}
```

## Error Responses

All tools may return error responses in the following format:

```json
{
  "isError": true,
  "content": [
    {
      "type": "text",
      "text": "Error description and details"
    }
  ]
}
```

Common error scenarios:
- **Invalid deck format**: Malformed deck list
- **Card not found**: Specified card doesn't exist in deck/hand/sideboard
- **Network error**: Scryfall API unavailable
- **Invalid query**: Malformed search query
- **Game state error**: Invalid operation for current state

## Query Syntax Reference

### Scryfall Search Syntax

The Scryfall API tools support rich query syntax:

#### Basic Searches
- `lightning` - Name contains "lightning"
- `t:instant` - Type contains "instant" 
- `c:red` - Color identity is red
- `cmc=3` - Converted mana cost equals 3
- `pow>=4` - Power 4 or greater

#### Advanced Queries
- `c:red cmc<=3` - Red cards with CMC 3 or less
- `t:creature c:gw` - Green-white creatures
- `o:"draw a card"` - Oracle text contains "draw a card"  
- `r:mythic` - Mythic rarity cards
- `f:commander` - Legal in Commander format

#### Operators
- `=` - Equals
- `!=` - Not equals  
- `<` - Less than
- `<=` - Less than or equal
- `>` - Greater than
- `>=` - Greater than or equal

#### Combining Queries
- Use spaces for AND: `c:red t:creature`
- Use `OR` for OR: `c:red OR c:blue`
- Use parentheses for grouping: `(c:red OR c:blue) cmc<=2`

For complete syntax reference, see: https://scryfall.com/docs/syntax

## Data Models

### Card Structure
```json
{
  "id": "string",
  "name": "string", 
  "manaCostString": "string",
  "kind": "CardKind",
  "rarity": "Rarity",
  "typeLine": "string",
  "oracleText": "string",  
  "power": "string?",
  "toughness": "string?",
  "loyalty": "string?"
}
```

### DeckStats Structure  
```json
{
  "cardsInDeck": "integer",
  "cardsInHand": "integer", 
  "sideboardCards": "integer",
  "totalCards": "integer"
}
```

### CardKind Enum
- `artifact`
- `creature` 
- `enchantment`
- `instant`
- `land`
- `planeswalker`
- `sorcery`
- `tribal`
- `unknown`

### Rarity Enum
- `common`
- `uncommon`
- `rare` 
- `mythic`
- `special`
- `unknown`