#!/usr/bin/env python3
"""
btcrecover-skill: model_router.py

Simple, user-friendly model recommendation engine.
Focuses on clear, non-technical language for all users.
"""

import json
from pathlib import Path

BENCHMARKS_FILE = Path(__file__).parent.parent / "references" / "benchmarks.json"


def load_benchmarks():
    """Load benchmark data"""
    if BENCHMARKS_FILE.exists():
        with open(BENCHMARKS_FILE) as f:
            return json.load(f)
    return {"models": {}}


def get_recommendation(tier: int, recovery_type: str = "general", priority: str = "balance"):
    """
    Returns a simple, user-friendly model recommendation.
    """
    benchmarks = load_benchmarks()
    models = benchmarks.get("models", {})
    
    # Default friendly recommendations
    recommendations = {
        1: {  # Tier 1 - Offline
            "primary": "Llama 3.1 70B (local)",
            "reason": "Strong performance while staying fully offline.",
            "alternative": "Qwen2.5 32B (local) - slightly faster on modest hardware."
        },
        2: {  # Tier 2 - Recommended
            "primary": "Claude Sonnet 4",
            "reason": "Best balance of accuracy and speed for recovery tasks.",
            "alternative": "GPT-4o - very capable and often faster."
        }
    }
    
    rec = recommendations.get(tier, recommendations[2])
    
    # Customize slightly based on recovery type
    if recovery_type == "password" and tier == 2:
        rec["primary"] = "Claude 3.5 Sonnet"
        rec["reason"] = "Excellent at understanding password patterns and variations."
    
    if recovery_type == "seed" and tier == 2:
        rec["primary"] = "Claude 3.5 Sonnet"
        rec["reason"] = "Very good at structured seed phrase recovery tasks."
    
    return rec


def format_recommendation(tier: int, recovery_type: str = "general"):
    """Return nicely formatted, simple recommendation text"""
    rec = get_recommendation(tier, recovery_type)
    
    text = f"""
**Recommended Model**

We recommend **{rec['primary']}** for this recovery.

**Why this one?**
{rec['reason']}

**Alternative:**
{rec['alternative']}

Would you like to proceed with the recommended model?
"""
    return text.strip()


if __name__ == "__main__":
    # Demo
    print("=== Tier 2 Example ===")
    print(format_recommendation(2, "password"))
    print("\n=== Tier 1 Example ===")
    print(format_recommendation(1))
    print(format_recommendation(3))