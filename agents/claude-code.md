# Claude Code Setup

## Installation

Claude Code (Anthropic) supports skills via the `skills` directory or direct loading.

### Method 1: Direct Load

1. Start Claude Code
2. Use the `/skill load` command:
   ```
   /skill load https://github.com/3rdIteration/btcrecover-skill/raw/main/SKILL.md
   ```
3. Claude Code will fetch and load the skill.

### Method 2: Manual Installation

1. Clone the repository:
   ```
   git clone https://github.com/3rdIteration/btcrecover-skill.git
   ```
2. Copy the `btcrecover-skill` directory to your Claude Code skills directory (usually `~/.claude/skills/`).
3. Restart Claude Code and the skill will be available.

## Usage

Once loaded, describe your wallet recovery situation in plain English:
> "I think I lost my Bitcoin wallet password. I remember it had something to do with my dog's name and my birth year."

The skill will guide you through the recovery process with step-by-step instructions.

## Configuration

No special configuration is required. The skill works out-of-the-box with Claude Code's default settings.

## Notes

- Claude Code provides excellent integration with Anthropic's models.
- For maximum privacy, consider using local models via other agents (like Hermes) if needed.
- The skill is designed to work seamlessly with Claude Code's skill system.