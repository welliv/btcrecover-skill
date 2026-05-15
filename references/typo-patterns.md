# Password and Seed Word Error Pattern Library

## Section 1: Password Typos

### Visual Character Confusion
Characters that look similar and are commonly confused:
- O (letter) vs 0 (zero)
- l (lowercase L) vs 1 (one) vs I (uppercase i)
- S vs 5
- B vs 8
- g vs 9
- Z vs 2
- rn vs m (r+n looks like m)

### Capitalisation Errors
- All lowercase when it should be mixed case
- All uppercase when it should be mixed case
- First letter capitalised vs not
- CAPS LOCK on for entire password
- Shift key held wrong (e.g., "P@SSWORD" instead of "p@ssword")

### Keyboard Proximity Errors
Common adjacent-key mistakes:
- a → s, q, z
- e → r, w, d
- i → u, o, k
- n → m, b, j
- t → r, y, g
- o → i, p, l

### Leet Speak Substitutions
Common character replacements:
- a → @, 4
- e → 3
- i → 1, !
- o → 0
- s → $, 5
- t → 7
- l → 1
- b → 8
- g → 9
- z → 2

### Common Suffixes and Prefixes
Users often add these to "make a password stronger":
- 123, 1234, 12345
- !, !!, !!!
- 1!, 2014, 2015, 2016, 2017, 2018, 2019, 2020
- @, #, $, %
- 01, 02, 03 ... 99
- qwerty, abc, xyz

### Transposed Characters
Adjacent characters swapped:
- "teh" instead of "the"
- "adn" instead of "and"
- "passowrd" instead of "password"

### Repeated Characters
- "passsword" instead of "password"
- "helloo" instead of "hello"
- "111" instead of "1"

### Deleted Characters
- "pasword" instead of "password"
- "btcrecover" instead of "btcrecover"

### Inserted Characters
- "passw0rd" instead of "password"
- "bitcoiin" instead of "bitcoin"

---

## Section 2: Seed Word Mistakes

### BIP39 4-Character Uniqueness Rule
BIP39 words are chosen so that the first 4 characters uniquely identify each word. This means:
- If you know the first 4 letters, you know the word
- "abandon" = "aban" (unique)
- "ability" = "abil" (unique)
- Typo in the 4th character can change the word entirely

### Look-Alike Seed Words
Words that are visually or phonetically similar:

| Word | Common Confusion |
|------|-----------------|
| abandon | abacus |
| ability | ablaze |
| absent | absorb |
| abstract | abuse |
| accident | accent |
| account | accuse |
| achieve | acquire |
| acquire | address |
| address | advance |
| advance | advice |
| advice | affair |
| afraid | again |
| agent | agree |
| airport | alarm |
| alarm | album |
| album | alcohol |
| alien | alive |
| allow | alone |
| alone | along |
| already | also |
| always | amazing |
| amount | anchor |
| anchor | ancient |
| anger | angle |
| animal | ankle |
| annual | another |
| answer | antenna |
| antenna | antique |
| anxiety | any |
| apart | apology |
| appear | apple |
| approve | april |
| arch | area |
| argue | armed |
| armor | around |
| arrest | arrive |
| arrow | artist |
| artwork | aspect |
| assault | asset |
| assist | assume |
| asthma | athlete |
| atom | attack |
| attend | august |
| author | auto |
| autumn | average |
| avoid | awake |
| aware | awful |

### Non-English Wordlists
BIP39 supports multiple languages. Common mistakes:
- Using words from the wrong language wordlist
- Mixing languages (some words from English, some from Spanish)
- Not knowing which language was used

Supported languages:
- English
- Chinese (Simplified)
- Chinese (Traditional)
- French
- Italian
- Japanese
- Korean
- Spanish

### Seed Word Order Mistakes
- Words in wrong position
- Two words swapped
- Entire sequence reversed

### Extra or Missing Words
- 13-word seed (extra word, possibly a passphrase)
- 11-word seed (missing word)
- 25-word seed (extra word, possibly a passphrase)
- 23-word seed (missing word)

---

## Section 3: Passphrase Patterns

### Common Passphrase Mistakes
- Passphrase confused with password
- Passphrase written down separately from seed
- Passphrase uses same pattern as password
- Multiple passphrases tried, user forgot which one

### Passphrase vs Password
- **Password:** Encrypts the wallet file (needed to open the wallet)
- **Passphrase:** Extends the seed phrase (creates a different wallet)
- Both can be used together
- A wallet can have a password, a passphrase, both, or neither

### Common Passphrase Patterns
- Single word (like a password)
- Short phrase (2-4 words)
- Sentence or quote
- Another seed phrase
- "25th word" (single word added to 24-word seed)

---

## btcrecover Flag Reference

### Password Recovery Flags
| Flag | Description | Performance Impact |
|------|-------------|-------------------|
| `--tokenlist FILE` | Base words for password generation | Required |
| `--passwordlist FILE` | Additional passwords to try | Fast |
| `--typos N` | Allow N typos per word | Exponential |
| `--typos-case` | Case toggling | 2× per word |
| `--typos-swap` | Adjacent character swap | Linear |
| `--typos-repeat` | Repeated characters | Linear |
| `--typos-delete` | Deleted characters | Linear |
| `--typos-replace` | Character replacement | Linear |
| `--typos-insert` | Inserted characters | Linear |
| `--threads N` | Number of CPU threads | Linear speedup |
| `--checkpoint` | Save progress for resume | Minimal |
| `--savefile FILE` | Checkpoint file path | Minimal |

### Seed Recovery Flags
| Flag | Description | Performance Impact |
|------|-------------|-------------------|
| `--mnemonic "..."` | Mnemonic with ? for unknown words | Required |
| `--mnemonic-length N` | 12, 15, 18, 21, or 24 | Required |
| `--mnemonic-alternatives "..." | Alternative words for positions | Linear |
| `--wallet-file FILE` | Wallet file to verify against | Required |
| `--address-database FILE` | Known addresses to check | Fast |
| `--bip39` | Use BIP39 wordlist | Default |
| `--electrum1` | Use Electrum 1.x seed format | Alternative |
| `--electrum2` | Use Electrum 2.x seed format | Alternative |
| `--slip39` | Use SLIP39 (Shamir) format | Alternative |
| `--language LANG` | Wordlist language | Required if non-English |
| `--path "..."` | Derivation paths to try | Linear |

### Performance Impact Notes
- `--typos 1` with all mutation flags: ~100× slowdown per word
- `--typos 2`: ~10,000× slowdown per word (use with caution)
- Each additional unknown word in seed recovery: 2048× increase
- `--threads N`: Near-linear speedup up to CPU core count
- GPU acceleration: 10-100× faster than CPU for password recovery

---
*Reference for btcrecover-skill tokenlist generation and typo mutation selection*