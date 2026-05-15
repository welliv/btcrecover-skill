#!/usr/bin/env python3
"""
typosquat-monitor.py — btcrecover skill v1.0
=============================================
Weekly scan for fake, impersonating, or typosquatted versions of the
btcrecover skill on GitHub, skills.sh, and package registries.

Run automatically via cron (see session-manager.sh cron) or manually:
    python3 scripts/typosquat-monitor.py

Sends alerts by writing to ~/.btcrecover-skill/typosquat-alerts.log
and optionally to a GitHub issue if GITHUB_TOKEN is set.

Add to crontab for weekly monitoring:
    0 9 * * 1 python3 /path/to/btcrecover-skill/scripts/typosquat-monitor.py
"""

import json
import sys
import os
import urllib.request
import urllib.error
from datetime import datetime
from pathlib import Path

# --- Configuration ---
CANONICAL_GITHUB  = "[yourusername]/btcrecover-skill"
CANONICAL_NAME    = "btcrecover-skill"
SKILLS_SH_API     = "https://api.skills.sh/v1/search"
GITHUB_SEARCH_API = "https://api.github.com/search/repositories"
ALERT_LOG         = Path.home() / ".btcrecover-skill" / "typosquat-alerts.log"

# Known safe forks (approved or known-good)
SAFE_FORKS = [
    # Add approved forks here as the community grows
    # "[trustedcontributor]/btcrecover-skill"
]

# Typosquat variants to monitor — covers common mutation patterns
VARIANTS = [
    # Missing letters
    "btcrecover-skil",
    "btcrecover-ski",
    "btcrecover-skll",
    "tcrecover-skill",
    "bcrecover-skill",
    "btrecover-skill",
    "btceover-skill",

    # Extra letters
    "btcrecover-skills",
    "btcrecover-skillz",
    "btcrecover-skill1",
    "btcrecovery-skill",

    # Separators
    "btcrecover_skill",
    "btcrecoverskill",
    "btc-recover-skill",
    "btc-recovery-skill",

    # Common suffix additions
    "btcrecover-skill-ai",
    "btcrecover-skill-pro",
    "btcrecover-skill-gpu",
    "btcrecover-skill-v2",
    "btcrecover-skill-plus",
    "btcrecover-skill-2025",
    "btcrecover-skill-2026",
    "btcrecover-skill-free",
    "btcrecover-skill-fast",
    "btcrecover-skill-best",

    # Common prefix additions
    "ai-btcrecover-skill",
    "new-btcrecover-skill",
    "real-btcrecover-skill",
    "official-btcrecover-skill",

    # Common confusions
    "bitcoin-recovery-skill",
    "wallet-recovery-skill",
    "crypto-recovery-skill",
    "btc-wallet-recovery-skill",
]

# --- Colours ---
def green(s):  return f"\033[32m{s}\033[0m" if sys.stdout.isatty() else s
def yellow(s): return f"\033[33m{s}\033[0m" if sys.stdout.isatty() else s
def red(s):    return f"\033[31m{s}\033[0m" if sys.stdout.isatty() else s
def bold(s):   return f"\033[1m{s}\033[0m"  if sys.stdout.isatty() else s

def info(msg):  print(f"[monitor] {msg}")
def ok(msg):    print(f"{green('[monitor]')} ✓ {msg}")
def warn(msg):  print(f"{yellow('[monitor]')} ! {msg}")
def alert(msg): print(f"{red(bold('[ALERT]'))} {msg}")


def fetch(url: str, headers: dict = None, timeout: int = 10) -> dict | None:
    """Fetch a URL and return parsed JSON, or None on failure."""
    try:
        req = urllib.request.Request(
            url,
            headers={
                "User-Agent": f"btcrecover-skill-typosquat-monitor/1.0 ({CANONICAL_GITHUB})",
                **(headers or {})
            }
        )
        with urllib.request.urlopen(req, timeout=timeout) as resp:
            return json.loads(resp.read().decode("utf-8"))
    except (urllib.error.URLError, json.JSONDecodeError, Exception):
        return None


def search_github(query: str) -> list[dict]:
    """Search GitHub for repositories matching a query."""
    url = f"{GITHUB_SEARCH_API}?q={urllib.parse.quote(query)}&sort=updated&order=desc"
    headers = {}
    token = os.environ.get("GITHUB_TOKEN")
    if token:
        headers["Authorization"] = f"token {token}"

    result = fetch(url, headers=headers)
    if result and "items" in result:
        return result["items"]
    return []


def check_github_variants() -> list[dict]:
    """Search GitHub for typosquatted repository names."""
    findings = []

    info(f"Searching GitHub for {len(VARIANTS)} variant names...")

    for variant in VARIANTS:
        repos = search_github(f"repo:{variant} OR {variant} in:name")
        for repo in repos:
            full_name = repo.get("full_name", "")
            if full_name == CANONICAL_GITHUB:
                continue  # canonical repo — skip
            if full_name in SAFE_FORKS:
                continue  # approved fork — skip
            if CANONICAL_NAME in full_name.lower() or variant.lower() in full_name.lower():
                findings.append({
                    "source": "github",
                    "name": full_name,
                    "url": repo.get("html_url"),
                    "stars": repo.get("stargazers_count", 0),
                    "updated": repo.get("updated_at", ""),
                    "description": repo.get("description", "")[:100],
                })

    return findings


def check_skillssh_variants() -> list[dict]:
    """Search skills.sh for typosquatted skill names."""
    findings = []

    info("Searching skills.sh registry...")

    for variant in VARIANTS[:10]:  # Rate-limit skills.sh searches
        url = f"{SKILLS_SH_API}?q={urllib.parse.quote(variant)}"
        result = fetch(url)
        if result and "skills" in result:
            for skill in result["skills"]:
                skill_name = skill.get("name", "")
                skill_owner = skill.get("owner", "")
                full_ref = f"{skill_owner}/{skill_name}"
                if full_ref == CANONICAL_GITHUB:
                    continue
                if full_ref in SAFE_FORKS:
                    continue
                if CANONICAL_NAME in skill_name.lower():
                    findings.append({
                        "source": "skills.sh",
                        "name": full_ref,
                        "url": f"https://skills.sh/{full_ref}",
                        "description": skill.get("description", "")[:100],
                    })

    return findings


def log_findings(findings: list[dict]) -> None:
    """Write findings to the alert log."""
    ALERT_LOG.parent.mkdir(parents=True, exist_ok=True)

    with open(ALERT_LOG, "a") as f:
        f.write(f"\n{'='*60}\n")
        f.write(f"Scan: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}\n")
        if findings:
            f.write(f"FINDINGS: {len(findings)} suspicious package(s)\n")
            for finding in findings:
                f.write(f"\n  Source:  {finding['source']}\n")
                f.write(f"  Name:    {finding['name']}\n")
                f.write(f"  URL:     {finding.get('url', 'N/A')}\n")
                if "stars" in finding:
                    f.write(f"  Stars:   {finding['stars']}\n")
                f.write(f"  Desc:    {finding.get('description', 'N/A')}\n")
        else:
            f.write("CLEAN: No suspicious packages found\n")


def create_github_alert(findings: list[dict]) -> None:
    """Create a GitHub issue for significant findings (if GITHUB_TOKEN set)."""
    token = os.environ.get("GITHUB_TOKEN")
    if not token or not findings:
        return

    try:
        import urllib.parse
        body = "## Typosquat Monitor Alert\n\n"
        body += f"Scan time: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}\n\n"
        body += f"Found {len(findings)} suspicious package(s):\n\n"
        for f in findings:
            body += f"- [{f['name']}]({f.get('url', '#')}) on {f['source']}\n"
        body += "\nPlease investigate and take down if malicious."

        data = json.dumps({
            "title": f"[SECURITY] Typosquat alert — {len(findings)} suspicious package(s) found",
            "body": body,
            "labels": ["security", "typosquat"]
        }).encode()

        req = urllib.request.Request(
            f"https://api.github.com/repos/{CANONICAL_GITHUB}/issues",
            data=data,
            headers={
                "Authorization": f"token {token}",
                "Content-Type": "application/json",
                "User-Agent": "btcrecover-skill-monitor"
            }
        )
        with urllib.request.urlopen(req, timeout=10) as resp:
            issue = json.loads(resp.read())
            ok(f"GitHub issue created: {issue.get('html_url')}")
    except Exception as e:
        warn(f"Could not create GitHub issue: {e}")


def main():
    import urllib.parse  # needed for quote in search functions

    print()
    info(f"btcrecover skill typosquat monitor")
    info(f"Canonical package: {CANONICAL_GITHUB}")
    info(f"Monitoring {len(VARIANTS)} variant names")
    print()

    all_findings = []

    # GitHub search
    github_findings = check_github_variants()
    all_findings.extend(github_findings)

    # skills.sh search
    skillssh_findings = check_skillssh_variants()
    all_findings.extend(skillssh_findings)

    # Deduplicate by name
    seen = set()
    unique_findings = []
    for f in all_findings:
        if f["name"] not in seen:
            seen.add(f["name"])
            unique_findings.append(f)

    print()
    if unique_findings:
        alert(f"Found {len(unique_findings)} suspicious package(s):")
        print()
        for f in unique_findings:
            alert(f"  {f['source'].upper()}: {f['name']}")
            alert(f"  URL: {f.get('url', 'N/A')}")
            if "description" in f and f["description"]:
                alert(f"  Description: {f['description']}")
            print()

        warn("Action required:")
        warn("  1. Check each URL manually")
        warn("  2. If malicious: report to platform (GitHub DMCA, skills.sh report)")
        warn(f"  3. Add known-safe forks to SAFE_FORKS in this script")
        warn(f"  4. Alert log: {ALERT_LOG}")
    else:
        ok("No suspicious packages found — all clear")

    log_findings(unique_findings)

    if unique_findings:
        create_github_alert(unique_findings)
        sys.exit(1)
    else:
        sys.exit(0)


if __name__ == "__main__":
    main()
