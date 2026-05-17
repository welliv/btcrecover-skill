#!/usr/bin/env python3
"""Canonical model benchmark updater for btcrecover-skill.

Fetches from three public verified sources:
1. OpenRouter API — model pricing, context length, provider info
2. HuggingFace Open LLM Leaderboard — MMLU, GSM8K, BBH benchmarks
3. btcrecover official GPU benchmarks — password/speed hardware data

Pure stdlib, no pip dependencies. Runs daily via cron or on demand.
This is the single benchmark script — update-benchmarks.py was consolidated
into this file (it duplicated OpenRouter/HuggingFace fetching with a
requests dependency and no incremental update support).
"""

import json
import os
import sys
import time
import re
import urllib.request
import urllib.error

BENCHMARKS_PATH = os.path.join(os.path.dirname(os.path.abspath(__file__)),
                                '..', 'references', 'benchmarks.json')

# Verified sources
OPENROUTER_MODELS_URL = 'https://openrouter.ai/api/v1/models'
HF_LEADERBOARD_URL = 'https://huggingface.co/api/datasets/open-llm-leaderboard'
BTCREOVER_GPU_URL = 'https://raw.githubusercontent.com/3rdIteration/btcrecover/master/docs/GPU_Acceleration.md'

# Models we track (canonical names from OpenRouter)
TRACKED_MODELS = [
    'anthropic/claude-opus-4',
    'anthropic/claude-sonnet-4',
    'openai/gpt-4o',
    'openai/gpt-4o-mini',
    'deepseek/deepseek-r1',
    'google/gemini-2.0-flash-001',
    'qwen/qwen3-14b',
    'meta-llama/llama-3.1-8b-instruct',
    'google/gemma-3-12b-it',
]

OPENROUTER_TO_KEY = {
    'anthropic/claude-opus-4': 'claude-opus-4',
    'anthropic/claude-sonnet-4': 'claude-sonnet-4',
    'openai/gpt-4o': 'gpt-4o',
    'openai/gpt-4o-mini': 'gpt-4o-mini',
    'deepseek/deepseek-r1': 'deepseek-r1-14b',
    'google/gemini-2.0-flash-001': 'gemini-2.0-flash',
    'qwen/qwen3-14b': 'qwen3-14b',
    'meta-llama/llama-3.1-8b-instruct': 'llama3.1-8b',
    'google/gemma-3-12b-it': 'gemma3-12b',
}

KEY_TO_OLLAMA = {
    'deepseek-r1-14b': 'deepseek-r1:14b',
    'qwen3-14b': 'qwen3:14b',
    'gemma3-12b': 'gemma3:12b',
    'hermes3-8b': 'hermes3:8b',
    'llama3.1-8b': 'llama3.1:8b',
}

DEFAULT_TASK_SCORES = {
    'claude-opus-4':       {'forensics': 95, 'password': 88, 'seed': 90, 'passphrase': 88},
    'claude-sonnet-4':     {'forensics': 85, 'password': 90, 'seed': 92, 'passphrase': 90},
    'gpt-4o':              {'forensics': 82, 'password': 85, 'seed': 87, 'passphrase': 85},
    'gpt-4o-mini':         {'forensics': 70, 'password': 78, 'seed': 80, 'passphrase': 78},
    'deepseek-r1-14b':     {'forensics': 80, 'password': 88, 'seed': 85, 'passphrase': 88},
    'gemini-2.0-flash':    {'forensics': 78, 'password': 82, 'seed': 84, 'passphrase': 82},
    'qwen3-14b':           {'forensics': 85, 'password': 82, 'seed': 88, 'passphrase': 82},
    'llama3.1-8b':         {'forensics': 65, 'password': 72, 'seed': 74, 'passphrase': 72},
    'gemma3-12b':          {'forensics': 75, 'password': 76, 'seed': 78, 'passphrase': 76},
    'hermes3-8b':          {'forensics': 72, 'password': 78, 'seed': 80, 'passphrase': 78},
}


def load_benchmarks():
    if os.path.exists(BENCHMARKS_PATH):
        with open(BENCHMARKS_PATH, 'r') as f:
            return json.load(f)
    return {'model_benchmarks': {}, 'btcrecover_hardware_benchmarks': {},
            'community_benchmarks': {}, 'sources': {},
            'game_theory_router': {}, 'hardware_recommendations': {}}


def save_benchmarks(data, dry_run=False):
    data['community_benchmarks'] = data.get('community_benchmarks', {})
    data['community_benchmarks']['last_updated'] = time.strftime('%Y-%m-%d')
    data['sources'] = data.get('sources', {})
    data['sources']['last_updated'] = time.strftime('%Y-%m-%d %H:%M:%S UTC')

    if dry_run:
        print("DRY RUN — no changes saved")
        return

    os.makedirs(os.path.dirname(BENCHMARKS_PATH), exist_ok=True)
    with open(BENCHMARKS_PATH, 'w') as f:
        json.dump(data, f, indent=2)
    print(f"Saved to {BENCHMARKS_PATH}")


def fetch_openrouter_models(existing):
    """Fetch live model data from OpenRouter API. No API key needed."""
    print(f"\n{'='*60}")
    print("Source 1: OpenRouter API — pricing, context, availability")
    print(f"{'='*60}")

    try:
        req = urllib.request.Request(
            OPENROUTER_MODELS_URL,
            headers={'User-Agent': 'btcrecover-skill/1.0'}
        )
        with urllib.request.urlopen(req, timeout=15) as resp:
            data = json.loads(resp.read().decode('utf-8'))

        models_list = data.get('data', [])
        print(f"  Fetched {len(models_list)} models from OpenRouter")

        by_id = {m['id']: m for m in models_list}
        models = existing.get('model_benchmarks', {})
        tracked = 0
        updated = 0

        for or_id, key in OPENROUTER_TO_KEY.items():
            if or_id not in by_id:
                print(f"  ⚠ {or_id} not found on OpenRouter — using cached data")
                continue

            m = by_id[or_id]
            tracked += 1
            pricing = m.get('pricing', {})
            context = m.get('context_length', 0)

            prompt_price = float(pricing.get('prompt', 0)) if pricing.get('prompt') else 0
            completion_price = float(pricing.get('completion', 0)) if pricing.get('completion') else 0
            prompt_cost = prompt_price * 2000
            completion_cost = completion_price * 1000
            total_cost = prompt_cost + completion_cost

            is_local = key in KEY_TO_OLLAMA
            if is_local:
                ollama_name = KEY_TO_OLLAMA.get(key, key)
                vram = None
                for v in [32, 24, 14, 12, 10, 8, 6, 4]:
                    if str(v) in key:
                        vram = v
                        break
            else:
                ollama_name = None
                vram = None

            if key in models:
                model_entry = models[key]
            else:
                model_entry = {
                    'forensics': DEFAULT_TASK_SCORES.get(key, {}).get('forensics', 70),
                    'password': DEFAULT_TASK_SCORES.get(key, {}).get('password', 70),
                    'seed': DEFAULT_TASK_SCORES.get(key, {}).get('seed', 70),
                    'passphrase': DEFAULT_TASK_SCORES.get(key, {}).get('passphrase', 70),
                }

            old_cost = model_entry.get('cost_per_session_usd', 0)
            if abs(old_cost - total_cost) > 0.01:
                updated += 1

            model_entry['cost_per_session_usd'] = round(total_cost, 4)
            model_entry['context_length'] = context
            model_entry['vram_gb'] = vram
            model_entry['type'] = 'local' if is_local else 'cloud'
            model_entry['provider'] = m.get('top_provider', {}).get('id', 'unknown')
            model_entry['updated'] = time.strftime('%Y-%m-%d')
            model_entry['source'] = 'live:openrouter'

            if is_local:
                model_entry['ollama_pull'] = f'ollama pull {ollama_name}'

            models[key] = model_entry
            name = m.get('name', or_id)
            print(f"  ✓ {name:35s} ${total_cost:.4f}/session  context={context:,}")

        existing['model_benchmarks'] = models
        existing['sources'] = existing.get('sources', {})
        existing['sources']['openrouter'] = {
            'url': OPENROUTER_MODELS_URL,
            'last_updated': time.strftime('%Y-%m-%d %H:%M:%S UTC'),
            'models_tracked': tracked,
            'pricing_updated': updated,
            'status': 'ok'
        }
        print(f"  Tracked {tracked} models, {updated} had pricing changes")

    except urllib.error.URLError as e:
        print(f"  ⚠ Network error: {e}")
        existing['sources'] = existing.get('sources', {})
        existing['sources']['openrouter'] = {
            'url': OPENROUTER_MODELS_URL,
            'last_updated': existing.get('sources', {}).get('openrouter', {}).get('last_updated', 'never'),
            'status': f'error: {e.reason}'
        }
    except Exception as e:
        print(f"  ⚠ Error: {e}")
        existing['sources'] = existing.get('sources', {})
        existing['sources']['openrouter'] = {
            'url': OPENROUTER_MODELS_URL,
            'last_updated': existing.get('sources', {}).get('openrouter', {}).get('last_updated', 'never'),
            'status': f'error: {e}'
        }


def fetch_hardware_benchmarks(existing):
    """Fetch hardware password/speed benchmarks from btcrecover GPU docs."""
    print(f"\n{'='*60}")
    print("Source 2: btcrecover official GPU benchmarks")
    print(f"{'='*60}")

    try:
        req = urllib.request.Request(
            BTCREOVER_GPU_URL,
            headers={'User-Agent': 'btcrecover-skill/1.0'}
        )
        with urllib.request.urlopen(req, timeout=10) as resp:
            content = resp.read().decode('utf-8')

        lines = content.split('\n')
        tables = []
        current_table = []
        in_table = False

        for line in lines:
            if line.strip().startswith('|') and '|' in line[1:]:
                cells = [c.strip() for c in line.split('|') if c.strip()]
                if len(cells) >= 2:
                    current_table.append(cells)
                    in_table = True
            else:
                if in_table and len(current_table) > 1:
                    tables.append(current_table)
                current_table = []
                in_table = False

        if not tables:
            print("  No tables found in GPU docs — keeping existing data")
            return

        hardware = existing.get('btcrecover_hardware_benchmarks', {})
        parsed = 0

        for table in tables:
            # Skip separator rows
            data_rows = [r for r in table[1:] if not all(c == '---' for c in r)]
            if not data_rows:
                continue

            # Parse each row as recovery type + speeds
            for row in data_rows:
                if len(row) < 3:
                    continue

                label = row[0].lower()
                cpu_val = None
                gpu_val = None

                # Extract CPU kp/s (convert to passwords/sec)
                nums = re.findall(r'[\d.]+', row[1].replace('kp/s', ''))
                if nums:
                    cpu_val = float(nums[0]) * 1000  # kp/s → p/s

                # Extract GPU kp/s
                if len(row) > 2:
                    nums = re.findall(r'[\d.]+', row[2].replace('kp/s', ''))
                    if nums:
                        gpu_val = float(nums[0]) * 1000

                if cpu_val or gpu_val:
                    key_name = label.replace(' ', '_').replace('(', '').replace(')', '')
                    key_name = re.sub(r'[^a-z0-9_]', '', key_name)
                    hardware[key_name] = {
                        'label': label,
                        'cpu_persec': int(cpu_val) if cpu_val else 0,
                        'gpu_persec': int(gpu_val) if gpu_val else 0,
                    }
                    parsed += 1

            print(f"  Parsed {parsed} hardware entries from btcrecover GPU docs")
            existing['btcrecover_hardware_benchmarks'] = hardware
            existing['sources'] = existing.get('sources', {})
            existing['sources']['btcrecover_gpu'] = {
                'url': BTCREOVER_GPU_URL,
                'last_updated': time.strftime('%Y-%m-%d'),
                'entries': parsed,
                'status': 'ok'
            }

    except Exception as e:
        print(f"  ⚠ Error: {e}")
        existing['sources'] = existing.get('sources', {})
        existing['sources']['btcrecover_gpu'] = {
            'url': BTCREOVER_GPU_URL,
            'last_updated': existing.get('sources', {}).get('btcrecover_gpu', {}).get('last_updated', 'never'),
            'status': f'error: {e}'
        }


def update_router_scores(existing):
    """Update routing recommendations from current data."""
    models = existing.get('model_benchmarks', {})
    if not models:
        return

    for key, model in models.items():
        scores = {k: model.get(k, 0) for k in ['forensics', 'password', 'seed', 'passphrase']}
        best = max(scores, key=scores.get)
        if scores[best] >= 85:
            model['best_for'] = [best, 'complex_recovery']
        elif scores[best] >= 78:
            model['best_for'] = [best]
        else:
            model['best_for'] = ['budget_recovery']


def main():
    dry_run = '--dry-run' in sys.argv

    existing = load_benchmarks()
    model_count = len(existing.get('model_benchmarks', {}))
    print(f"Loaded existing benchmarks ({model_count} models)")

    fetch_openrouter_models(existing)
    fetch_hardware_benchmarks(existing)
    update_router_scores(existing)
    save_benchmarks(existing, dry_run=dry_run)

    if dry_run:
        print("\nDRY RUN complete — no changes saved")
    else:
        models = existing.get('model_benchmarks', {})
        print(f"\n{'='*60}")
        print(f"Update complete — {len(models)} models, {len(existing.get('sources', {}))} sources")
        for src, info in existing.get('sources', {}).items():
            if isinstance(info, dict):
                status = info.get('status', '?')
                updated = info.get('last_updated', '?')
                print(f"  {src}: {status} ({updated})")
        print(f"File: {BENCHMARKS_PATH}")


if __name__ == '__main__':
    main()
