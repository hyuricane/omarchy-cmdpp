# Source-to-Binary Provenance Declaration

This document establishes the verified source-to-binary provenance for the upstream [`cmdpp`](https://github.com/hyuricane/cmdpp) executable referenced and verified by `omarchy-cmdpp`.

---

## 1. Upstream Source Information

| Attribute | Value |
|---|---|
| **Upstream Repository** | [hyuricane/cmdpp](https://github.com/hyuricane/cmdpp) |
| **Release Tag** | [`v0.2.2`](https://github.com/hyuricane/cmdpp/releases/tag/v0.2.2) |
| **Exact Source Git Commit** | [`e7cad42d453e45d4fd63d05ddbe5a42ddce1cfcd`](https://github.com/hyuricane/cmdpp/commit/e7cad42d453e45d4fd63d05ddbe5a42ddce1cfcd) |
| **License** | [MIT](https://github.com/hyuricane/cmdpp/blob/master/LICENSE) |
| **Author / Maintainer** | Yuri Andri Gani ([@hyuricane](https://github.com/hyuricane)) |

---

## 2. Build Pipeline & Security Controls

All official binaries are built in an isolated GitHub-hosted runner via GitHub Actions, signed cryptographically using GitHub Artifact Attestations (Sigstore / SLSA Level 3 build provenance).

- **Build Workflow**: [`.github/workflows/release.yml`](https://github.com/hyuricane/cmdpp/blob/v0.2.2/.github/workflows/release.yml)
- **Workflow Run**: [`https://github.com/hyuricane/cmdpp/actions/runs/38240318531`](https://github.com/hyuricane/cmdpp/actions/runs/38240318531)
- **OIDC Signer**: `https://token.actions.githubusercontent.com`
- **Predicate Type**: `https://slsa.dev/provenance/v1`
- **Build Command**:
  ```bash
  CGO_ENABLED=0 GOOS=${GOOS} GOARCH=${GOARCH} go build \
    -trimpath \
    -ldflags "-s -w -X main.Version=v0.2.2" \
    -o cmdpp \
    main.go
  ```
- **Reproducibility Flags**:
  - `-trimpath`: Strips host filesystem paths from binary symbols.
  - `SOURCE_DATE_EPOCH`: Normalized file timestamps set to the commit timestamp.
  - Tar normalization: `--sort=name --mtime="@${SOURCE_DATE_EPOCH}" --owner=0 --group=0 --numeric-owner`

---

## 3. Cryptographic Checksums & Digest Map

### Release Archives (`.tar.gz`)
The release archives contain the `cmdpp` executable, `README.md`, and `LICENSE`.

| Architecture | Archive Name | SHA-256 Checksum |
|---|---|---|
| **x86_64 / amd64** | `cmdpp_0.2.2_linux_amd64.tar.gz` | `d643b42a13be0dfdba6a92d40b4fb1b6987439c2a5863f00fa9c8daf40142a65` |
| **aarch64 / arm64** | `cmdpp_0.2.2_linux_arm64.tar.gz` | `2394f266df26b8c2eb5324a1f207804fa7365100f9310fc9e3ade5dbb9761c5d` |

### Extracted Executable (`bin/cmdpp`)
Verified on every launch to guarantee runtime binary integrity:

| Architecture | Binary SHA-256 Checksum |
|---|---|
| **x86_64 / amd64** | `66c66d71e41be44fba4ddbc7a56c066af690e80c3c8007139412aba6c28d4c54` |
| **aarch64 / arm64** | `5edfab6772a2c7fe644563bac37a8904d5d606ade8cb09396b8e665060318d69` |

---

## 4. Independent Verification Instructions

### Using GitHub CLI (`gh`)
Anyone can verify that the downloaded release archive was produced by GitHub Actions from the exact source repository and tag:

```bash
gh attestation verify cmdpp_0.2.2_linux_amd64.tar.gz \
  --repo hyuricane/cmdpp \
  --signer-repo hyuricane/cmdpp
```

Expected output:
```text
Loaded digest sha256:d643b42a13be0dfdba6a92d40b4fb1b6987439c2a5863f00fa9c8daf40142a65
Loaded 1 attestation from GitHub API

The following policy criteria will be enforced:
- Predicate type must match:................ https://slsa.dev/provenance/v1
- Source Repository URI must match:......... https://github.com/hyuricane/cmdpp
- OIDC Issuer must match:................... https://token.actions.githubusercontent.com

✓ Verification succeeded!
```

### Direct Public API Verification (No Auth Required)
The signed in-toto SLSA statement can also be fetched and inspected directly without authentication:

```bash
curl -s "https://api.github.com/repos/hyuricane/cmdpp/attestations/sha256:d643b42a13be0dfdba6a92d40b4fb1b6987439c2a5863f00fa9c8daf40142a65" \
  | jq '.attestations[0].bundle.dsseEnvelope.payload | @base64d | fromjson'
```

---

## 5. Runtime Enforcement in `bin/cmdpp-wrapper`

The [`bin/cmdpp-wrapper`](bin/cmdpp-wrapper) script enforces this chain-of-trust automatically:
1. **User Consent**: Prompts the user before any download with the target version, URLs, and expected checksums.
2. **Archive Integrity**: Computes SHA-256 of the downloaded archive and checks against committed constants.
3. **Cryptographic Build Attestation**: Runs `gh attestation verify` (or verifies the public SLSA bundle) before unpacking.
4. **Binary Integrity**: Computes SHA-256 of the extracted executable on every execution, halting immediately if modified or corrupted.
