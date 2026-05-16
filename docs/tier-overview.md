# btcrecover-skill Security Tiers

## Tier Comparison

| Tier              | Privacy      | Speed        | Best For                                   | AI Runs             |
|-------------------|--------------|--------------|--------------------------------------------|---------------------|
| 🔒 **Tier 1**     | Highest      | Good         | Large amounts, maximum security            | Fully local         |
| ⚡ **Tier 2**     | High         | Excellent    | **Most users** *(Recommended)*             | Cloud reasoning     |
| 🚨 **Tier 3**     | Low          | Fastest      | Only if you accept high risk               | Fully online        |

## What This Means

- **🔒 Tier 1** — Everything runs completely offline using a local AI model.
- **⚡ Tier 2** — Your wallet data stays local. Only the AI’s reasoning uses the cloud.
- **🚨 Tier 3** — Your data is processed online. Treat any recovered funds as potentially compromised. Sweep immediately.

**Recommended:** Tier 2 offers the best balance of strong privacy and effortless setup.

**Warning:** Tier 3 carries real risk. Only use it if you fully understand and accept the exposure.

## Scripts

- `scripts/tier1-check.sh` — Check Tier 1 readiness
- `scripts/connectivity-check.sh --enforce` — Main consent gate

## Documentation

- `docs/tier1-setup.md`
- `docs/tier2-setup.md`