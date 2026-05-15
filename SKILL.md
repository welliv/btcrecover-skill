# btcrecover-skill

The AI layer that makes Bitcoin wallet recovery accessible to everyone.

Built on btcrecover by 3rdIteration. Free and open source. Always.

## Progressive Disclosure

L1: Advertise - name and description only
L2: Load - main orchestrator (this file)
L3: Sub-skills - loaded per recovery type
L4: References and scripts - loaded on demand

## Recovery Process

1. Read safety rules (mandatory every session)
2. Check connectivity (3-layer: ping → DNS → TCP)
3. Determine recovery type (password, seed, forensics)
4. Load appropriate sub-skill
5. Follow guided steps with user approval for each command
6. Post-recovery safety protocol (sweep reminders)
7. Secure session destruction (nuke-session)

## Security

- Offline-first: safest path is default
- No dangerous commands without explicit user approval
- Session data destruction after use
- Anti-impersonation measures
- Liability protection via disclaimers

## Model Agnostic

Works with local models (Ollama) and cloud APIs (Claude, GPT, Gemini, etc.) via OpenRouter.

## Agent Agnostic

Supports Claude Code, Cursor, Cline, Codex, Hermes, and any agent supporting agentskills.io SKILL.md standard.

---
*Free. Open source. Always.*