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