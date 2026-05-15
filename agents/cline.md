# Cline Setup

## Installation

Cline (VS Code) supports skills via the `skills` directory or direct loading.

### Method 1: Direct Load

1. Start Cline
2. Use the skill loading command (if available) or manually load the SKILL.md file.
3. Cline will load the skill and make it available for use.

### Method 2: Manual Installation

1. Clone the repository:
   ```
   git clone https://github.com/3rdIteration/btcrecover-skill.git
   ```
2. Copy the `btcrecover-skill` directory to your Cline skills directory.
3. Restart Cline and the skill will be available.

## Usage

Once loaded, describe your wallet recovery situation in plain English:
> "I think I lost my Bitcoin wallet password. I remember it had something to do with my dog's name and my birth year."

The skill will guide you through the recovery process with step-by-step instructions.

## Configuration

No special configuration is required. The skill works out-of-the-box with Cline's default settings.

## Notes

- Cline provides excellent integration with VS Code and various LLM providers.
- For maximum privacy, consider using local models (Ollama) with Cline if supported.
- The skill is designed to work seamlessly with Cline's skill system.