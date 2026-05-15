# Wallet Types

## Bitcoin Core

File: `wallet.dat`. Extract: `extract-bitcoin-hash.py`
```bash
python extract-bitcoin-hash.py wallet.dat > wallet.extract
```

GPU speed: up to 2.5M passwords/sec (RTX 4090).

## Electrum

File: `wallet` (no extension). Extract: `extract-electrum-hash.py`
```bash
python extract-electrum-hash.py wallet > wallet.extract
```

GPU speed: up to 5M passwords/sec. Use `--electrum1` or `--electrum2` for seed format.

## Blockchain.com

File: `wallet.aes.json`. Extract: `extract-blockchain-hash.py`
```bash
python extract-blockchain-hash.py wallet.aes.json > wallet.extract
```

GPU speed: ~50K passwords/sec (high iteration count).

## Trezor / Ledger (Hardware Wallets)

No file. Use BIP39 seed recovery. Common derivation paths: BIP44 (legacy), BIP49 (SegWit), BIP84 (native SegWit), BIP86 (Taproot).

## MetaMask

File: `vault.json` (browser extension data). Extract: `extract-metamask-hash.py`

## Exodus

Wallet file in Exodus data directory. Use seed recovery if easier.

## MultiBit Classic

File: `wallet.key` or `wallet.data`. Extract: `extract-multibit-hash.py`

## MultiBit HD

File: `mbhd.wallet.aes`. Extract: `extract-multibit-hd-hash.py`

## Armory

File: `armory_*.wallet`. Extract: `extract-armory-hash.py`

## Wasabi

File: `wallet.json`. Uses BIP84 (native SegWit) by default.

## Sparrow

File: `wallet.json` or `wallet.sqlite`. Supports BIP44/49/84/86.

## The sharedKey Bug

btcrecover has a known bug where it concatenates the encryption key and password in the wrong order during decryption. This caused the cprkrn 11-year failure. If a password "should" work but does not, this may be why.

## GPU Rental

| Provider | GPU | Cost/hr |
|----------|-----|---------|
| Vast.ai | RTX 4090 | $0.50 |
| Vast.ai | RTX 3090 | $0.30 |
| RunPod | RTX 4090 | $0.60 |

Estimate: `(search_space / gpu_speed) × hourly_rate`. Show cost before recommending.