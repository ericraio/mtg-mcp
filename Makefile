# MTG MCP Server Makefile

.PHONY: build build-release clean test logs logs-mtg logs-scryfall logs-edhrec logs-all logs-follow install install-local deploy help

# Build commands
build:
	swift build

build-release:
	swift build -c release

clean:
	swift package clean

# Test commands
test:
	swift test

test-verbose:
	swift test --verbose

# Installation commands
install-local: build-release
	@echo "📦 Installing MTG MCP binaries to ~/.local/bin/"
	@mkdir -p ~/.local/bin
	@cp .build/release/mtg-mcp ~/.local/bin/
	@cp .build/release/scryfall-mcp ~/.local/bin/
	@cp .build/release/edhrec-mcp ~/.local/bin/
	@cp .build/release/mtg ~/.local/bin/
	@echo "✅ Installed to ~/.local/bin/"

install-user: build-release
	@echo "📦 Installing MTG MCP binaries to ~/bin/"
	@mkdir -p ~/bin
	@cp .build/release/mtg-mcp ~/bin/
	@cp .build/release/scryfall-mcp ~/bin/
	@cp .build/release/edhrec-mcp ~/bin/
	@cp .build/release/mtg ~/bin/
	@echo "✅ Installed to ~/bin/"

install-system: build-release
	@echo "📦 Installing MTG MCP binaries to /usr/local/bin/ (requires sudo)"
	sudo cp .build/release/mtg-mcp /usr/local/bin/
	sudo cp .build/release/scryfall-mcp /usr/local/bin/
	sudo cp .build/release/edhrec-mcp /usr/local/bin/
	sudo cp .build/release/mtg /usr/local/bin/
	@echo "✅ Installed to /usr/local/bin/"

# Default install target
install: install-local

# Claude Desktop configuration helpers
config-update: install-local
	@echo "⚙️  Updating Claude Desktop configuration..."
	@cat > ~/Library/Application\ Support/Claude/claude_desktop_config.json << 'EOF'
	{
	  "mcpServers": {
	    "mtg-deck-manager": {
	      "command": "$(HOME)/.local/bin/mtg-mcp",
	      "args": ["--transport", "stdio"]
	    },
	    "scryfall-api": {
	      "command": "$(HOME)/.local/bin/scryfall-mcp",
	      "args": ["--transport", "stdio"]
	    },
	    "edhrec-analyzer": {
	      "command": "$(HOME)/.local/bin/edhrec-mcp",
	      "args": ["--transport", "stdio"]
	    }
	  }
	}
	EOF
	@echo "✅ Claude Desktop config updated"

config-show:
	@echo "⚙️  Current Claude Desktop configuration:"
	@cat ~/Library/Application\ Support/Claude/claude_desktop_config.json | jq . 2>/dev/null || cat ~/Library/Application\ Support/Claude/claude_desktop_config.json

config-validate:
	@echo "✅ Validating Claude Desktop configuration:"
	@jq empty ~/Library/Application\ Support/Claude/claude_desktop_config.json && echo "✓ Valid JSON" || echo "❌ Invalid JSON"

config-path:
	@echo "📁 Claude Desktop config path:"
	@echo "~/Library/Application Support/Claude/claude_desktop_config.json"

# Logging commands
logs:
	@echo "📋 Recent MTG MCP Server logs (last 10 minutes):"
	@log show --predicate 'subsystem == "com.mtg-mcp"' --info --debug --last 10m

logs-mtg:
	@echo "🎯 MTG Deck Manager Server logs (last 10 minutes):"
	@log show --predicate 'subsystem == "com.mtg-mcp" AND category == "MTGDeckManagerServer"' --info --last 10m

logs-rules:
	@echo "📖 Rules Service logs (last 10 minutes):"
	@log show --predicate 'subsystem == "com.mtg-mcp" AND category == "RulesService"' --info --last 10m

logs-scryfall:
	@echo "🔍 Scryfall API Server logs (last 10 minutes):"
	@log show --predicate 'subsystem == "com.mtg-mcp" AND category == "ScryfallService"' --info --last 10m

logs-edhrec:
	@echo "📊 EDHREC Analysis Server logs (last 10 minutes):"
	@log show --predicate 'subsystem == "com.mtg-mcp" AND category == "EDHRecService"' --info --last 10m

logs-all:
	@echo "📊 All MTG MCP logs (last 30 minutes):"
	@log show --predicate 'subsystem == "com.mtg-mcp"' --info --debug --last 30m

logs-follow:
	@echo "👀 Following MTG MCP logs (press Ctrl+C to stop):"
	@log stream --predicate 'subsystem == "com.mtg-mcp"' --info --debug

logs-claude:
	@echo "🤖 Claude Desktop logs mentioning MTG (last 10 minutes):"
	@log show --predicate 'process == "Claude" AND eventMessage CONTAINS[c] "mtg"' --info --last 10m

# Debugging commands
logs-debug:
	@echo "🐛 Debug level logs (last 5 minutes):"
	@log show --predicate 'subsystem == "com.mtg-mcp"' --debug --last 5m

logs-errors:
	@echo "❌ Error logs (last 1 hour):"
	@log show --predicate 'subsystem == "com.mtg-mcp" AND messageType == error' --last 1h

logs-warnings:
	@echo "⚠️  Warning logs (last 30 minutes):"
	@log show --predicate 'subsystem == "com.mtg-mcp" AND messageType >= warning' --last 30m

logs-recent:
	@echo "🕐 Most recent logs (last 5 minutes):"
	@log show --predicate 'subsystem == "com.mtg-mcp"' --info --debug --last 5m

# Development helpers
dev-logs:
	@echo "🛠️  Development logs (console output from last 5 minutes):"
	@log show --predicate 'process CONTAINS[c] "swift" AND eventMessage CONTAINS[c] "mtg"' --last 5m

# Server testing
test-mtg:
	@echo "🧪 Testing MTG server executable:"
	@if [ -f ~/.local/bin/mtg-mcp ]; then \
		~/.local/bin/mtg-mcp --help; \
	elif [ -f .build/release/mtg-mcp ]; then \
		./.build/release/mtg-mcp --help; \
	else \
		echo "❌ mtg-mcp executable not found. Run 'make install' first."; \
	fi

test-scryfall:
	@echo "🧪 Testing Scryfall server executable:"
	@if [ -f ~/.local/bin/scryfall-mcp ]; then \
		~/.local/bin/scryfall-mcp --help; \
	elif [ -f .build/release/scryfall-mcp ]; then \
		./.build/release/scryfall-mcp --help; \
	else \
		echo "❌ scryfall-mcp executable not found. Run 'make install' first."; \
	fi

test-edhrec:
	@echo "🧪 Testing EDHREC server executable:"
	@if [ -f ~/.local/bin/edhrec-mcp ]; then \
		~/.local/bin/edhrec-mcp --help; \
	elif [ -f .build/release/edhrec-mcp ]; then \
		./.build/release/edhrec-mcp --help; \
	else \
		echo "❌ edhrec-mcp executable not found. Run 'make install' first."; \
	fi

test-rules:
	@echo "🧪 Testing rules splitter executable:"
	@if [ -f ~/.local/bin/mtg ]; then \
		~/.local/bin/mtg --help; \
	elif [ -f .build/release/mtg ]; then \
		./.build/release/mtg --help; \
	else \
		echo "❌ mtg executable not found. Run 'make install' first."; \
	fi

test-data-cli:
	@echo "🧪 Testing MTG data CLI executable:"
	@if [ -f ~/.local/bin/mtg ]; then \
		~/.local/bin/mtg --help; \
	elif [ -f .build/release/mtg ]; then \
		./.build/release/mtg --help; \
	else \
		echo "❌ mtg executable not found. Run 'make install' first."; \
	fi

test-connection:
	@echo "🔗 Testing MCP connection with timeout..."
	@echo '{"jsonrpc":"2.0","id":1,"method":"initialize","params":{"protocolVersion":"2024-11-05","capabilities":{},"clientInfo":{"name":"test","version":"1.0.0"}}}' | timeout 5s ~/.local/bin/mtg-mcp --transport stdio 2>/dev/null && echo "✅ MTG server responds" || echo "❌ MTG server connection failed"

# Log analysis
logs-stats:
	@echo "📈 Log statistics (last 1 hour):"
	@echo "Total entries: $$(log show --predicate 'subsystem == "com.mtg-mcp"' --last 1h | wc -l)"
	@echo "Error entries: $$(log show --predicate 'subsystem == "com.mtg-mcp" AND messageType == error' --last 1h | wc -l)"
	@echo "Warning entries: $$(log show --predicate 'subsystem == "com.mtg-mcp" AND messageType >= warning' --last 1h | wc -l)"
	@echo "Info entries: $$(log show --predicate 'subsystem == "com.mtg-mcp" AND messageType <= info' --last 1h | wc -l)"

# Deployment helpers
deploy: clean build-release install-local config-update
	@echo "🚀 Deployment complete!"
	@echo ""
	@echo "Next steps:"
	@echo "1. Restart Claude Desktop"
	@echo "2. Test connection with: make test-connection"
	@echo "3. Monitor logs with: make logs-follow"

deploy-system: clean build-release install-system
	@echo "🚀 System-wide deployment complete!"

# Data processing commands
process-cards:
	@echo "🃏 Processing MTG card data..."
	@if [ -f ~/.local/bin/mtg ]; then \
		~/.local/bin/mtg cards; \
	else \
		swift run mtg cards; \
	fi

process-rules:
	@echo "📖 Processing MTG rules data..."
	@if [ -f ~/.local/bin/mtg ]; then \
		~/.local/bin/mtg rules; \
	else \
		swift run mtg rules; \
	fi

process-all:
	@echo "🚀 Processing all MTG data..."
	@if [ -f ~/.local/bin/mtg ]; then \
		~/.local/bin/mtg all; \
	else \
		swift run mtg all; \
	fi

process-force:
	@echo "🔄 Force processing all MTG data..."
	@if [ -f ~/.local/bin/mtg ]; then \
		~/.local/bin/mtg all --force; \
	else \
		swift run mtg all --force; \
	fi

verify-data:
	@echo "🔍 Verifying MTG data integrity..."
	@if [ -f ~/.local/bin/mtg ]; then \
		~/.local/bin/mtg verify; \
	else \
		swift run mtg verify; \
	fi

# Cleanup commands
clean-logs:
	@echo "🧹 Note: macOS logs are managed by the system and cannot be manually cleared"
	@echo "    Use 'sudo log config --mode \"level:off\"' to disable logging (not recommended)"

clean-install:
	@echo "🧹 Removing installed binaries..."
	@rm -f ~/.local/bin/mtg-mcp ~/.local/bin/scryfall-mcp ~/.local/bin/edhrec-mcp ~/.local/bin/mtg
	@rm -f ~/bin/mtg-mcp ~/bin/scryfall-mcp ~/bin/edhrec-mcp ~/bin/mtg
	@echo "✅ Cleaned up installed binaries"

# Status check
status:
	@echo "📊 MTG MCP Server Status"
	@echo "========================"
	@echo ""
	@echo "🏗️  Build Status:"
	@if [ -f .build/release/mtg-mcp ]; then echo "  ✅ Release build exists"; else echo "  ❌ Release build missing (run 'make build-release')"; fi
	@echo ""
	@echo "📦 Installation Status:"
	@if [ -f ~/.local/bin/mtg-mcp ]; then echo "  ✅ ~/.local/bin/mtg-mcp installed"; else echo "  ❌ ~/.local/bin/mtg-mcp not found"; fi
	@if [ -f ~/.local/bin/scryfall-mcp ]; then echo "  ✅ ~/.local/bin/scryfall-mcp installed"; else echo "  ❌ ~/.local/bin/scryfall-mcp not found"; fi
	@if [ -f ~/.local/bin/edhrec-mcp ]; then echo "  ✅ ~/.local/bin/edhrec-mcp installed"; else echo "  ❌ ~/.local/bin/edhrec-mcp not found"; fi
	@if [ -f ~/.local/bin/mtg ]; then echo "  ✅ ~/.local/bin/mtg installed"; else echo "  ❌ ~/.local/bin/mtg not found"; fi
	@echo ""
	@echo "⚙️  Configuration Status:"
	@if [ -f ~/Library/Application\ Support/Claude/claude_desktop_config.json ]; then echo "  ✅ Claude Desktop config exists"; else echo "  ❌ Claude Desktop config missing"; fi
	@echo ""
	@echo "📋 Recent Activity:"
	@echo "  Last 5 minutes: $$(log show --predicate 'subsystem == "com.mtg-mcp"' --last 5m | wc -l) log entries"

# Help
help:
	@echo "🎮 MTG MCP Server Makefile Commands:"
	@echo ""
	@echo "📦 Build Commands:"
	@echo "  make build         - Build debug version"
	@echo "  make build-release - Build release version"
	@echo "  make clean         - Clean build artifacts"
	@echo ""
	@echo "🚀 Installation Commands:"
	@echo "  make install       - Install to ~/.local/bin (default)"
	@echo "  make install-local - Install to ~/.local/bin"
	@echo "  make install-user  - Install to ~/bin"
	@echo "  make install-system- Install to /usr/local/bin (requires sudo)"
	@echo ""
	@echo "⚙️  Configuration Commands:"
	@echo "  make config-update   - Update Claude Desktop config"
	@echo "  make config-show     - Show current Claude config"
	@echo "  make config-validate - Validate Claude config JSON"
	@echo ""
	@echo "🧪 Test Commands:"
	@echo "  make test          - Run all Swift tests"
	@echo "  make test-verbose  - Run tests with verbose output"
	@echo "  make test-mtg      - Test MTG server executable"
	@echo "  make test-scryfall - Test Scryfall server executable"
	@echo "  make test-edhrec   - Test EDHREC server executable"
	@echo "  make test-data-cli - Test MTG data CLI executable"
	@echo "  make test-connection - Test MCP server connection"
	@echo ""
	@echo "🗂️  Data Processing Commands:"
	@echo "  make process-cards - Process MTG card data from Scryfall"
	@echo "  make process-rules - Process MTG comprehensive rules"
	@echo "  make process-all   - Process both cards and rules"
	@echo "  make process-force - Force process all data (ignore cache)"
	@echo "  make verify-data   - Verify processed data integrity"
	@echo ""
	@echo "📋 Logging Commands:"
	@echo "  make logs          - Show recent logs (10 min)"
	@echo "  make logs-mtg      - Show MTG server logs"
	@echo "  make logs-rules    - Show rules service logs"
	@echo "  make logs-scryfall - Show Scryfall server logs"
	@echo "  make logs-edhrec   - Show EDHREC server logs"
	@echo "  make logs-all      - Show all logs (30 min)"
	@echo "  make logs-follow   - Follow logs in real-time"
	@echo "  make logs-recent   - Show most recent logs (5 min)"
	@echo "  make logs-claude   - Show Claude Desktop logs"
	@echo ""
	@echo "🐛 Debug Commands:"
	@echo "  make logs-debug    - Show debug level logs"
	@echo "  make logs-errors   - Show error logs only"
	@echo "  make logs-warnings - Show warning+ logs"
	@echo "  make logs-stats    - Show log statistics"
	@echo "  make dev-logs      - Show development logs"
	@echo ""
	@echo "🚀 Deployment Commands:"
	@echo "  make deploy        - Full deployment (build + install + config)"
	@echo "  make deploy-system - System-wide deployment"
	@echo "  make status        - Show overall system status"
	@echo ""
	@echo "🧹 Cleanup Commands:"
	@echo "  make clean-install - Remove installed binaries"
	@echo ""
	@echo "❓ Help:"
	@echo "  make help          - Show this help message"

# Default target
all: build-release

# Quick development cycle
dev: clean build test

# Production deployment pipeline
production: clean build-release test install-local
