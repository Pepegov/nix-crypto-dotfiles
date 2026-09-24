# Security model

This configuration is designed for compartmentalization, not absolute security. It reduces exposure from the everyday host workload by creating a dedicated, minimal guest for crypto-related browsing and Trezor interactions. It keeps signing keys on the Trezor and makes the guest reproducible rather than precious.

## What it is designed to reduce

- Exposure to everyday host applications, development tools, downloads, documents, messaging applications, extensions, and unrelated websites.
- Guest attack surface through a minimal package set, no SSH, remote desktop, printing, Bluetooth, discovery, automounting, or server services.
- Persistence from ordinary user-space compromise by allowing a known configuration to be rebuilt.
- Accidental USB-storage mounting and accidental device passthrough through an explicit, narrow workflow.
- Theft of a powered-off virtual disk through LUKS encryption.

## Trust boundaries

The guest firewall and service configuration apply only inside the guest. Libvirt configuration, graphics channels, storage, USB assignment, VM memory, virtual hardware, and host networking are controlled by the host. Guest configuration cannot enforce host-side policy.

The Trezor is the primary signing boundary. Verify the recipient address, amount, asset/network, and other important transaction details on the Trezor display. A convincing guest screen is not enough.

## What it does not reliably protect against

- Compromised host root, host kernel, hypervisor, QEMU/libvirt, or host firmware.
- Malicious guest firmware or virtual hardware supplied by a hostile host.
- Physical attacks against a running or unlocked machine.
- A compromised Trezor or malicious Trezor firmware.
- A user approving a malicious transaction or ignoring the Trezor display.
- Supply-chain compromise of trusted software, nixpkgs, binary caches, or firmware.
- Phishing, malicious exchanges, malicious web services, or compromised financial websites.
- Loss of recovery material, user error, or poor operational discipline.

LUKS encrypts storage at rest. It does not hide the contents of an unlocked VM from the host/hypervisor. VM isolation is useful against ordinary cross-contamination, but is not a reliable security boundary against host root.

## Secrets rule

Never place seeds, private keys, recovery material, exchange credentials, API keys, 2FA recovery codes, LUKS passphrases, password-manager secrets, or authentication secrets in Nix, the Nix store, Git, flake inputs, declarative environment variables, or committed scripts. The repository can be public only if this rule is maintained.
