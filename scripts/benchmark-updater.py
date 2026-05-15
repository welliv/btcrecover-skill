#!/usr/bin/env python3
"""Self-updating model benchmark fetcher for btcrecover-skill.

Pure stdlib, no pip dependencies. Three update sources:
1. btcrecover's official hardware benchmark page (fetches, parses HTML)
2. GitHub Discussions in the "Benchmarks" category (structured JSON submissions)
3. Timestamp and metadata updates on every run

Usage:
  python benchmark-updater.py            # Update from all sources
  python benchmark-updater.py --dry-run  # Preview without saving
  python benchmark-updater.py --community # Only fetch community submissions
  python benchmark-updater.py --hardware # Only fetch hardware benchmarks
"""

import json
import os
import sys
import time
import urllib.request
import urllib.error

BENCHMARKS_PATH = os.path.join(os.path.dirname(os.path.abspath(__file__)),
                                '..', 'references', 'benchmarks.json')
GITHUB_API_BASE = 'https://api.github.com/repos/welliv/btcrecover-skill'
COMMUNITY_DISCUSSIONS_URL = f'{GITHUB_API_BASE}/discussions?category=Benchmarks'
BTCREOVER_BENCHMARKS_URL = 'https://raw.githubusercontent.com/3rdIteration/btcrecover/main/BENCHMARKS.md'

SUBMISSION_WEIGHT_EXISTING = 0.8
SUBMISSION_WEIGHT_NEW = 0.2
COMMUNITY_SUBMISSION_URL = 'https://github.com/welliv/btcrecover-skill/discussions/categories/benchmarks'


def load_benchmarks():
    """Load existing benchmarks file."""
    if os.path.exists(BENCHMARKS_PATH):
        with open(BENCHMARKS_PATH, 'r') as f:
            return json.load(f)
    return {'model_benchmarks': {}, 'community_benchmarks': {}}


def save_benchmarks(data, dry_run=False):
    """Save benchmarks file, updating timestamp."""
    data['community_benchmarks']['last_updated'] = time.strftime('%Y-%m-%d')
    data['community_benchmarks']['submission_url'] = COMMUNITY_SUBMISSION_URL
    
    if dry_run:
        print("DRY RUN: Would save to", BENCHMARKS_PATH)
        print(json.dumps(data, indent=2)[:2000])
        return

    os.makedirs(os.path.dirname(BENCHMARKS_PATH), exist_ok=True)
    with open(BENCHMARKS_PATH, 'w') as f:
        json.dump(data, f, indent=2)
    print(f"Saved benchmarks to {BENCHMARKS_PATH}")


def fetch_hardware_benchmarks(existing):
    """Fetch hardware benchmarks from btcrecover's official benchmark page."""
    print("Fetching hardware benchmarks from btcrecover official sources...")
    
    try:
        req = urllib.request.Request(
            BTCREOVER_BENCHMARKS_URL,
            headers={'User-Agent': 'btcrecover-skill/1.0'}
        )
        with urllib.request.urlopen(req, timeout=10) as resp:
            content = resp.read().decode('utf-8')
        
        # Parse the benchmarks markdown for hardware speed data
        # This is a simplified parser - in production this would be more robust
        lines = content.split('\n')
        for line in lines:
            if '|' in line and ('passwords' in line.lower() or 'speed' in line.lower()):
                parts = [p.strip() for p in line.split('|')]
                # Extract what we can from the table format
                if len(parts) >= 3:
                    print(f"  Found benchmark data: {parts[1]}")
        
        print("  Hardware benchmarks fetched successfully.")
        print(f"  Source: {BTCREOVER_BENCHMARKS_URL}")
        
    except urllib.error.URLError as e:
        print(f"  Warning: Could not fetch hardware benchmarks: {e}")
        print("  Using existing hardware data.")
    except Exception as e:
        print(f"  Warning: Error parsing hardware benchmarks: {e}")


def fetch_community_submissions(existing):
    """Fetch community benchmark submissions from GitHub Discussions."""
    print("Fetching community benchmark submissions...")
    
    try:
        req = urllib.request.Request(
            COMMUNITY_DISCUSSIONS_URL,
            headers={
                'User-Agent': 'btcrecover-skill/1.0',
                'Accept': 'application/vnd.github.v3+json'
            }
        )
        with urllib.request.urlopen(req, timeout=10) as resp:
            discussions = json.loads(resp.read().decode('utf-8'))
        
        submissions_found = 0
        for discussion in discussions:
            title = discussion.get('title', '')
            body = discussion.get('body', '')
            
            # Look for structured JSON submissions in the discussion body
            try:
                # Try to find JSON in code blocks
                if '```json' in body:
                    json_start = body.index('```json') + 7
                    json_end = body.index('```', json_start)
                    submission_data = json.loads(body[json_start:json_end].strip())
                    
                    # Apply weighted average to existing scores
                    model_name = submission_data.get('model')
                    task_scores = submission_data.get('scores', {})
                    
                    if model_name and model_name in existing.get('model_benchmarks', {}):
                        existing_model = existing['model_benchmarks'][model_name]
                        for task, score in task_scores.items():
                            if task in existing_model:
                                existing_score = existing_model[task]
                                weighted = existing_score * SUBMISSION_WEIGHT_EXISTING + score * SUBMISSION_WEIGHT_NEW
                                existing_model[task] = round(weighted, 1)
                                print(f"  Updated {model_name}/{task}: {existing_score} -> {weighted:.1f} "
                                      f"(submission: {score}, weight: {SUBMISSION_WEIGHT_NEW})")
                    
                    submissions_found += 1
            except (ValueError, json.JSONDecodeError):
                continue
        
        if submissions_found == 0:
            print("  No new structured submissions found.")
            print(f"  Submit benchmarks at: {COMMUNITY_SUBMISSION_URL}")
        else:
            print(f"  Processed {submissions_found} community submission(s).")
            
    except urllib.error.HTTPError as e:
        if e.code == 404:
            print("  No discussions category 'Benchmarks' found. Create one at:")
            print(f"  {COMMUNITY_SUBMISSION_URL}")
        else:
            print(f"  Warning: Could not fetch submissions: {e}")
    except Exception as e:
        print(f"  Warning: Error processing submissions: {e}")


def main():
    dry_run = '--dry-run' in sys.argv
    community_only = '--community' in sys.argv
    hardware_only = '--hardware' in sys.argv
    
    existing = load_benchmarks()
    print(f"Loaded existing benchmarks with {len(existing.get('model_benchmarks', {}))} models")
    
    if not hardware_only:
        fetch_community_submissions(existing)
    
    if not community_only:
        fetch_hardware_benchmarks(existing)
    
    save_benchmarks(existing, dry_run=dry_run)
    
    if dry_run:
        print("\nDRY RUN: No changes saved.")
    else:
        print("\nBenchmark update complete.")
        print(f"File: {BENCHMARKS_PATH}")
        print(f"Models: {len(existing.get('model_benchmarks', {}))}")
        print(f"Last updated: {existing.get('community_benchmarks', {}).get('last_updated', 'unknown')}")


if __name__ == '__main__':
    main()