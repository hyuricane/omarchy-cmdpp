# Source-to-Binary Provenance Declaration

This document establishes the verified source-to-binary provenance for the upstream [`cmdpp`](https://github.com/hyuricane/cmdpp) executable referenced and verified by `omarchy-cmdpp`.

---

## 1. Upstream Source Information

| Attribute | Value |
|---|---|
| **Upstream Repository** | [hyuricane/cmdpp](https://github.com/hyuricane/cmdpp) |
| **Release Tag** | [`v0.2.0`](https://github.com/hyuricane/cmdpp/releases/tag/v0.2.0) |
| **Exact Source Git Commit** | [`2097cd3dcd0ccbdd97cd78b5bc0e15a4c3fbfcea`](https://github.com/hyuricane/cmdpp/commit/2097cd3dcd0ccbdd97cd78b5bc0e15a4c3fbfcea) |
| **License** | [MIT](https://github.com/hyuricane/cmdpp/blob/master/LICENSE) |
| **Author / Maintainer** | Yuri Andri Gani ([@hyuricane](https://github.com/hyuricane)) |

---

## 2. Build Pipeline & Security Controls

All official binaries are built in an isolated GitHub-hosted runner via GitHub Actions, signed cryptographically using GitHub Artifact Attestations (Sigstore / SLSA Level 3 build provenance).

- **Build Workflow**: [`.github/workflows/release.yml`](https://github.com/hyuricane/cmdpp/blob/v0.2.0/.github/workflows/release.yml)
- **Workflow Run**: [`https://github.com/hyuricane/cmdpp/actions/runs/37904236248`](https://github.com/hyuricane/cmdpp/actions/runs/37904236248)
- **OIDC Signer**: `https://token.actions.githubusercontent.com`
- **Predicate Type**: `https://slsa.dev/provenance/v1`
- **Build Command**:
  ```bash
  CGO_ENABLED=0 GOOS=${GOOS} GOARCH=${GOARCH} go build \
    -trimpath \
    -ldflags "-s -w -X main.Version=v0.2.0" \
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
| **x86_64 / amd64** | `cmdpp_0.2.0_linux_amd64.tar.gz` | `85ae16533b081afa2d1a2c4662d40d8372542b789465c7e1efb7a8ac2937d07d` |
| **aarch64 / arm64** | `cmdpp_0.2.0_linux_arm64.tar.gz` | `bbb6a79b1ec462bb174b50b505158017c033ec08592b58830498cf5e778ef21c` |

### Extracted Executable (`bin/cmdpp`)
Verified on every launch to guarantee runtime binary integrity:

| Architecture | Binary SHA-256 Checksum |
|---|---|
| **x86_64 / amd64** | `84b45b7002d32de1ed6c053ea2c17f102e85dd8f9f412955611cc551efc120f0` |
| **aarch64 / arm64** | `0af66131b38bd77f477d7c0e7d201bb8e510d3bda02eba65ba93d24269c6d301` |

---

## 4. Independent Verification Instructions

### Using GitHub CLI (`gh`)
Anyone can verify that the downloaded release archive was produced by GitHub Actions from the exact source repository and tag:

```bash
gh attestation verify cmdpp_0.2.0_linux_amd64.tar.gz \
  --repo hyuricane/cmdpp \
  --signer-repo hyuricane/cmdpp
```

Expected output:
```text
Loaded digest sha256:85ae16533b081afa2d1a2c4662d40d8372542b789465c7e1efb7a8ac2937d07d
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
curl -s "https://api.github.com/repos/hyuricane/cmdpp/attestations/sha256:85ae16533b081afa2d1a2c4662d40d8372542b789465c7e1efb7a8ac2937d07d" \
  | jq '.attestations[0].bundle.dsseEnvelope.payload | @base64d | fromjson'
```

---

## 5. Runtime Enforcement in `bin/cmdpp-wrapper`

The [`bin/cmdpp-wrapper`](bin/cmdpp-wrapper) script enforces this chain-of-trust automatically:
1. **User Consent**: Prompts the user before any download with the target version, URLs, and expected checksums.
2. **Archive Integrity**: Computes SHA-256 of the downloaded archive and checks against committed constants.
3. **Cryptographic Build Attestation**: Runs `gh attestation verify` (or verifies the public SLSA bundle) before unpacking.
4. **Binary Integrity**: Computes SHA-256 of the extracted executable on every execution, halting immediately if modified or corrupted.
