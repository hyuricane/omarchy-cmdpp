# Source-to-Binary Provenance Declaration

This document establishes the verified source-to-binary provenance for the upstream [`cmdpp`](https://github.com/hyuricane/cmdpp) executable referenced and verified by `omarchy-cmdpp`.

---

## 1. Upstream Source Information

| Attribute | Value |
|---|---|
| **Upstream Repository** | [hyuricane/cmdpp](https://github.com/hyuricane/cmdpp) |
| **Release Tag** | [`v0.1.3`](https://github.com/hyuricane/cmdpp/releases/tag/v0.1.3) |
| **Exact Source Git Commit** | [`e4c274a0638b3d0d93631bc802e7ec7d135afe1e`](https://github.com/hyuricane/cmdpp/commit/e4c274a0638b3d0d93631bc802e7ec7d135afe1e) |
| **License** | [MIT](https://github.com/hyuricane/cmdpp/blob/master/LICENSE) |
| **Author / Maintainer** | Yuri Andri Gani ([@hyuricane](https://github.com/hyuricane)) |

---

## 2. Build Pipeline & Security Controls

All official binaries are built in an isolated GitHub-hosted runner via GitHub Actions, signed cryptographically using GitHub Artifact Attestations (Sigstore / SLSA Level 3 build provenance).

- **Build Workflow**: [`.github/workflows/release.yml`](https://github.com/hyuricane/cmdpp/blob/v0.1.3/.github/workflows/release.yml)
- **Workflow Run**: [`https://github.com/hyuricane/cmdpp/actions/runs/36313640451`](https://github.com/hyuricane/cmdpp/actions/runs/36313640451)
- **OIDC Signer**: `https://token.actions.githubusercontent.com`
- **Predicate Type**: `https://slsa.dev/provenance/v1`
- **Build Command**:
  ```bash
  CGO_ENABLED=0 GOOS=${GOOS} GOARCH=${GOARCH} go build \
    -trimpath \
    -ldflags "-s -w -X main.Version=v0.1.3" \
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
| **x86_64 / amd64** | `cmdpp_0.1.3_linux_amd64.tar.gz` | `48c91811ab5427b6b134729fdce6ee6f321a51aec05b470ec45327db2107ff03` |
| **aarch64 / arm64** | `cmdpp_0.1.3_linux_arm64.tar.gz` | `2823c59a9bd8bed8b670a3098efef9904e0a3e5a6268b287817e9c60177780a8` |

### Extracted Executable (`bin/cmdpp`)
Verified on every launch to guarantee runtime binary integrity:

| Architecture | Binary SHA-256 Checksum |
|---|---|
| **x86_64 / amd64** | `4f36a1b1494ae0e45af8aa5001b286e25daf57ce9c566966e8a22a362e0a7979` |
| **aarch64 / arm64** | `f8ed6013a5af18c7bfaa33281b6b4f6b6e64bb5c4878328ab902f8825f175f59` |

---

## 4. Independent Verification Instructions

### Using GitHub CLI (`gh`)
Anyone can verify that the downloaded release archive was produced by GitHub Actions from the exact source repository and tag:

```bash
gh attestation verify cmdpp_0.1.3_linux_amd64.tar.gz \
  --repo hyuricane/cmdpp \
  --signer-repo hyuricane/cmdpp
```

Expected output:
```text
Loaded digest sha256:48c91811ab5427b6b134729fdce6ee6f321a51aec05b470ec45327db2107ff03
Loaded 2 attestations from GitHub API

The following policy criteria will be enforced:
- Predicate type must match:................ https://slsa.dev/provenance/v1
- Source Repository URI must match:......... https://github.com/hyuricane/cmdpp
- OIDC Issuer must match:................... https://token.actions.githubusercontent.com

✓ Verification succeeded!
```

### Direct Public API Verification (No Auth Required)
The signed in-toto SLSA statement can also be fetched and inspected directly without authentication:

```bash
curl -s "https://api.github.com/repos/hyuricane/cmdpp/attestations/sha256:48c91811ab5427b6b134729fdce6ee6f321a51aec05b470ec45327db2107ff03" \
  | jq '.attestations[0].bundle.dsseEnvelope.payload | @base64d | fromjson'
```

---

## 5. Runtime Enforcement in `bin/cmdpp-wrapper`

The [`bin/cmdpp-wrapper`](bin/cmdpp-wrapper) script enforces this chain-of-trust automatically:
1. **User Consent**: Prompts the user before any download with the target version, URLs, and expected checksums.
2. **Archive Integrity**: Computes SHA-256 of the downloaded archive and checks against committed constants.
3. **Cryptographic Build Attestation**: Runs `gh attestation verify` (or verifies the public SLSA bundle) before unpacking.
4. **Binary Integrity**: Computes SHA-256 of the extracted executable on every execution, halting immediately if modified or corrupted.
