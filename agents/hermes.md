# Hermes Agent Setup

## Installation

Hermes Agent (Nous Research) has built-in support for loading skills from GitHub or local directories.

### Method 1: Load from GitHub (Recommended)

1. Start Hermes Agent
2. Use the skill loading command:
   ```
   skill load gh:3rdIteration/btcrecover-skill
   ```
3. The skill will be automatically loaded and ready to use.

### Method 2: Local Installation

1. Clone the repository:
   ```
   git clone https://github.com/3rdIteration/btcrecover-skill.git
   ```
2. Start Hermes Agent from within the cloned directory (or add the directory to your skill path).
3. Load the skill:
   ```
   skill load btcrecover-skill
   ```

## Usage

Once loaded, describe your wallet recovery situation in plain English:
> "I think I lost my Bitcoin wallet password. I remember it had something to do with my dog's name and my birth year."

The skill will guide you through the recovery process with step-by-step instructions.

## Configuration

No special configuration is required. The skill works out-of-the-box with Hermes Agent's default settings.

## Notes

- Hermes Agent provides excellent local model support via Ollama integration.
- For maximum privacy, use local models (Ollama) with Hermes Agent.
- The skill is designed to work seamlessly with Hermes Agent's progressive disclosure system.