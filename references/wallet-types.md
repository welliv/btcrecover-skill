# Wallet Types + File Paths + Recovery Modes

## Two Recovery Tools

Use the right tool for the right problem:

| Tool | When | Example problem |
|------|------|-----------------|
| `btcrecover.py` | Wallet password, BIP38, brainwallet, warpwallet, raw private key | "I forgot my wallet password" |
| `seedrecover.py` | Seed-level issues | "I have 12 words but 2 might be wrong" |

## btcrecover.py Recovery Modes

| Mode | Flag | Example |
|------|------|---------|
| Wallet password | `--wallet wallet.dat` | Bitcoin Core, Electrum, MultiBit |
| BIP39 passphrase | `--bip39 --mnemonic "..." --addrs ...` | Seed + forgotten 25th word |
| BIP38 paper wallet | `--bip38-enc-privkey "6PnM..."` | Encrypted paper wallet |
| Brainwallet | `--brainwallet --addrs ...` | Password-hashed key |
| Warpwallet | `--warpwallet --warpwallet-salt "..."` | Passphrase + salt |
| SLIP39 | `--slip39 --mnemonic "..."` | Shamir backup shares |
| Raw private key | `--rawprivatekey --addrs ...` | Encrypted private key |
| Data extract | `--data-extract-string "BASE64..."` | Safe cloud recovery |

### Wallet Types (`--wallet-type` flag for btcrecover.py)

| Coin | `--wallet-type` value | Notes |
|------|----------------------|-------|
| Bitcoin (default) | (none needed) | BIP39, BIP84 native SegWit auto-detect |
| Bitcoin Cash | `bch` | Address starts with `bitcoincash:` or `q`/`p` |
| Litecoin | `litecoin` | Address starts with `L` or `ltc1` |
| Dogecoin | `dogecoin` | Address starts with `D` |
| Dash | `dash` | Address starts with `X` |
| Ethereum | `ethereum` | Address starts with `0x` |
| Ethereum Validator | `ethereumvalidator` | Uses pubkey as address |
| Cardano | `cardano` | Address starts with `addr1` or `stake1` |
| Ripple | `ripple` | Address starts with `r` |
| Stellar (XLM) | `xlm` | Address starts with `G` |
| Tron | `tron` | Address starts with `T` |
| Polkadot Substrate | `polkadotsubstrate` | May need `--substrate-path` |
| Stacks | `stacks` | Address starts with `SP` or `SM` |
| Zilliqa | `zilliqa` | Address starts with `zil1` |
| Vertcoin | `vertcoin` | Address starts with `V` |
| DigiByte | `digibyte` | Address starts with `D` |
| Groestlecoin | `groestlecoin` | Address starts with `F` |
| Monacoin | `monacoin` | Address starts with `M` |

## seedrecover.py Features

| Feature | Flag | Scenario |
|---------|------|----------|
| Missing words | `--mnemonic "word1 ? word3 ..."` | 1-4 unknown words in seed |
| Descrumbling | `--dsw --tokenlist words.txt` | All words known, order unknown |
| Word swaps | `--transform-wordswaps N` | Words in wrong positions |
| Big typos | `--big-typos N` | Missing or extra words (SLIP39) |
| Multi-device | `--worker 1,2/3` | Distribution across machines |
| Languages | `--language FR` | Non-English BIP39 wordlist |
| AddressDB | `--addressdb file.db` | Wallet-type agnostic recovery |

If the user has **both seed and known address** with a forgotten passphrase, use `btcrecover.py`, not `seedrecover.py`. The passphrase flag lives in the password recovery tool.

## Wallet File Paths

### Windows
| Wallet | Path |
|--------|------|
| Bitcoin Core | `%appdata%\Bitcoin\wallet.dat` |
| MultiBit HD | `%appdata%\MultiBitHD\mbhd.wallet.aes` |
| MultiBit Classic | `%appdata%\MultiBit\multibit-data\key-backup\*.key` |
| Electrum | `%appdata%\Electrum\wallets` |
| Blockchain.com | `wallet.aes.json` |
| Bither | `%appdata%\Bither\address.db` |
| mSIGNA | `.vault` in `%homedrive%%homepath%` |
| Metamask (Chrome) | `%localappdata%\Google\Chrome\User Data\Default\Local Extension Settings\nkbihfbeogaeaoehlefnkodbefgpgknn` |
| Coinomi | `%localappdata%\Coinomi\Coinomi\wallets` |
| Sparrow | `~/.sparrow/wallets/` |

### Linux
| Wallet | Path |
|--------|------|
| Bitcoin Core | `~/.bitcoin/wallet.dat` |
| Electrum | `~/.electrum/wallets/` |
| Sparrow | `~/.sparrow/wallets/` |
| Blockchain.com | Search for `wallet.aes.json` |

### macOS
| Wallet | Path |
|--------|------|
| Bitcoin Core | `~/Library/Application Support/Bitcoin/wallet.dat` |
| Electrum | `~/.electrum/wallets/` |
| Sparrow | `~/.sparrow/wallets/` |

## Extract Scripts

Found in `extract-scripts/` directory of btcrecover repo. Each extracts a hash or data blob that can safely be sent to cloud/rented GPU without exposing private keys:

```
extract-bitcoin-hash.py              extract-bitcoin-mkey.py
extract-electrum-hash.py             extract-electrum2-partmpk.py
extract-blockchain-hash.py           extract-blockchain-main-data.py
extract-blockchain-second-hash.py    extract-multibit-hash.py
extract-multibit-hd-data.py          extract-msigna-partmpk.py
extract-metamask-hash.py             extract-metamask-vaults.py
extract-bither-partkey.py            extract-dogechain-privkey.py
extract-coinomi-privkey.py           download-blockchain-wallet.py
```

## GPU Acceleration

| Mode | Compatible wallets | Flags |
|------|-------------------|-------|
| OpenCL | Blockchain.com | `--enable-opencl` |
| JTR kernel | Bitcoin Core, any `--wallet` extract | `--enable-gpu --global-ws 4096 --local-ws 256` |

**Important:** BIP39 seed + passphrase recovery is NOT GPU accelerated. CPU only.

### GPU Performance

| GPU | Blockchain.com (kP/s) | Bitcoin Core (kP/s) | Vast.ai cost |
|-----|----------------------|---------------------|-------------|
| CPU (8-core) | 1 | 0.07 | - |
| RTX 3060 | 10 | 6.75 | ~$0.15/hr |
| RTX 3090 | 30 | 50 | ~$0.30/hr |
| RTX 4090 | 50 | 100 | ~$0.50/hr |

## AddressDB

For wallet-type agnostic seed recovery — checks against a pre-built database of all addresses for a coin:

```bash
python seedrecover.py --addressdb addresses-BTC.db --wallet-type bip39
  --mnemonic "..." --addr-limit 2 --no-dupchecks
```

Build from blockchain data:
```bash
python create-address-db.py --dblength 30 --datadir ~/.bitcoin
```

Check existing DB:
```bash
python check-address-db.py --dbfilename addresses-DOGE.db
  --checkaddresses DAddress1 DAddress2
```

**Caveats:** Bitcoin DB ~16GB (DBLength 31). RAM ~2x DB size. Python 3 only.

## Security Notes

- Tokenlist/passwordlist files contain **plaintext** password info
- btcrecover does NOT overwrite sensitive data in RAM after use
- With `--no-dupchecks`, less data in RAM; without it, large amounts may be swapped to disk
- **Recommended:** run inside a VM on HDD, securely delete the VM after
- Only run on **copies** of wallet files — never originals
