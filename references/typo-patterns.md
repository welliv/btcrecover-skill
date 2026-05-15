# Error Patterns

## Password Typos

**Visual confusion:** O/0, l/1/I, S/5, B/8, g/9, Z/2, rn/m.

**Capitalisation:** All lower when should be mixed. First letter caps. Caps lock on. Shift held wrong.

**Keyboard proximity:** a→s/q/z, e→r/w/d, i→u/o/k, n→m/b/j, t→r/y/g, o→i/p/l.

**Leet speak:** a→@/4, e→3, i→1/!, o→0, s→$/5, t→7.

**Common suffixes:** 123, !, !!, 1!, years (2014–2020), @.

**Transposition:** "teh" for "the", "passowrd" for "password".

**Repeats:** "passsword", "helloo".

**Deletions:** "pasword" for "password".

## Seed Word Errors

BIP39 first 4 characters uniquely identify each word. Knowing the first 4 letters identifies the word.

**Lookalikes:**

| Word | Confused with |
|------|--------------|
| abandon | abacus |
| ability | ablaze |
| absent | absorb |
| abstract | abuse |
| accident | accent |
| account | accuse |

Also: wrong language wordlist, words in wrong order, extra or missing words.

## Passphrase Patterns

Passphrase is not a password. It extends the seed, creating a different wallet. Both can be used together.

Common: single word, short phrase, sentence, another seed, 25th word.

## Custom-Word Utility

You need to translate the user's guess into a tokenlist.

**Exact passphrase guess:**
If the user says "I think it was recoverytesting":
1. Add the exact string: `recoverytesting`
2. Generate truncations: `recoverytest`, `recoverytesti`, `recoverytestin`
3. Add common suffixes: `recoverytesting1`, `recoverytesting!`
4. Add the common `s` variant: `recoverytestings`

For a sentence-like phrase like "golivelifebeforelifetakeyou":
1. Add the exact string
2. Generate truncations at natural word boundaries
3. Add the `s` variant for verbs: `golivelifebeforelifetakesyou`
4. Add common misspellings and alternative past-tense forms: `golivelifebeforelifetookyou`

**Always include:** empty string (no passphrase) as a baseline check.

The tokenlist should be 4-15 entries for a focused passphrase recovery. Broader lists risk combinatorial explosion with typos enabled.

## Passwordlist vs Tokenlist

**Passwordlist** (`--passwordlist FILE`): One password per line, tried verbatim. No combination or permutation. Supports typos via `--typos-*` flags. Use for: known password guesses, RockYou wordlists, leaked password databases.

**Tokenlist** (`--tokenlist FILE`): Tokens per line that btcrecover permutes and combines into passwords. Each line is a "token" and btcrecover tries all combinations of 1, 2, 3, ... N tokens. Use for: partial password fragments, seed descrambling, BIP39 passphrase recovery.

When in doubt, use `--passwordlist` for exact passphrase guesses and `--tokenlist` only when you need combinatorial combinations from fragments. Passwordlists are easier to reason about for passphrase recovery.

## Tokenlist Format Reference

### Basic
- One token per line
- btcrecover tries all permutations of tokens to form passwords

### Comments
- `#` at column 0 = comment line (ignored)
- `#` with leading space = valid token (e.g. ` #hashtag`)

### Mutual Exclusion (OR tokens)
Tokens on the same line (space-separated): at most one is used in any single password attempt.
```
Cairo cairo London london
```
→ picks at most one of these four, never two.

### Required Tokens
`+` at line start (plus space): token MUST be included in every password attempt.
```
+ Beetlejuice beetlejuice Betelgeuse betelgeuse
```
→ exactly one of these four must appear in every attempt.

### Positional Anchors
`^N^token` — token only tried at position N (1-indexed).
```
^1^ocean            # must be first
^2^hidden           # must be second
^3^kidney           # must be third
```

### Beginning/End Anchors
`^token` — only at beginning of password.
`token$` — only at end of password.

### Middle Anchor
`^N,M^token` — token only tried in positions N through M, never first or last.
```
^3,^token           # position 3 or later, never last
^,3^token           # position 3 or earlier, never first or last
^,^token            # anywhere in middle (never first, never last)
```

### Relative Anchors
`^rN^token` — relative ordering among anchored tokens (lower r = earlier position).
```
^r1^ocean           # comes before r2
^r2^hidden          # comes after r1, before r3
^r3^kidney          # comes after r2
```

### Token Groups (Comma-Separated)
Words on the same line, comma-separated, must appear together in that order.
```
^dawn,renew,punch   # these 3 words appear together, in this order
arrest,question     # another group
```
Combines with `+` required and positional anchors.

### Inline CLI Options in Tokenlist
First line can start with `#--` followed by additional CLI arguments. This is how btcrecover auto-loads options when you double-click the tokenlist file. Safe from: `--passwordlist`, `--tokenlist`, `--performance`, `--utf8` (these are NOT permitted inline).

### Wildcards in Tokenlist/Passwordlist

| Wildcard | Expands to | Example |
|----------|-----------|---------|
| `%1,6d` | Digits 1-6 chars | `%1,4d` → 0, 1, ..., 9999 |
| `%a` | All letters (a-z, A-Z) | Single character |
| `%e` | Custom list (repeating) | Same value each occurrence |
| `%f` | Custom list (repeating, nested wildcards) | Can contain other wildcards |
| `%j` | Custom list (standard) | Different per occurrence |
| `%k` | Custom list (standard) | Different per occurrence |

Custom lists loaded via `--wildcard-custom-list-LETTER FILE`. Requires `--has-wildcards` flag.

**Password:**
| Flag | Effect | Performance |
|------|--------|-------------|
| `--tokenlist FILE` | Base words | Required |
| `--typos N` | Allow N typos | Exponential |
| `--typos-case` | Case toggling | 2x per word |
| `--typos-swap` | Adjacent swap | Linear |
| `--typos-repeat` | Repeat char | Linear |
| `--typos-delete` | Delete char | Linear |
| `--typos-replace` | Replace char | Linear |
| `--threads N` | CPU threads | Linear |

**Seed:**
| Flag | Effect |
|------|--------|
| `--mnemonic "..."` | Phrase with ? for unknowns |
| `--bip39` | BIP39 wordlist |
| `--electrum1/2` | Electrum format |
| `--slip39` | Shamir format |
| `--language LANG` | Non-English wordlist |
| `--path "..."` | Derivation paths |

**Performance:** `--typos 1` is ~100x slowdown per word. `--typos 2` is ~10,000x. Each unknown seed word adds 2048x. GPU is 10–100x faster than CPU.