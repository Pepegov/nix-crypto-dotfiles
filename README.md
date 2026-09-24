# NixOS cryptocurrency VM

This repository defines a small, replaceable NixOS 26.05 guest for narrowly scoped cryptocurrency activity. It is not a vault for seeds or software private keys. The Trezor holds signing keys, and its own display is the authority for transaction approval.

## Architecture and threat model

```text
normal Linux host -> KVM/QEMU and libvirt -> encrypted NixOS guest -> Trezor Suite/Firefox -> Trezor
```

The guest compartmentalizes exchanges, wallet sites, and hardware-wallet software from the everyday host desktop, development tools, downloads, documents, messaging, and browser extensions. Firefox is the financial browser; the separately launched Brave Rabby profile is limited to the Rabby EVM wallet extension. Reproducible configuration also makes persistence less valuable: the guest can be rebuilt from this repository.

This does not turn a hostile host into a trusted one. Host root, the host kernel, libvirt, QEMU, and host firmware can inspect or alter an unlocked guest, its disk, networking, display, keyboard input, or USB passthrough. Treat the host and hypervisor as trusted while this VM is running. Verify destination address, amount, asset/network, and all other details on the physical Trezor display before approval.

## Repository layout

```text
nixos/hosts/crypto-vm/configuration.nix host-wide configuration and user
nixos/hosts/crypto-vm/disco.nix         declarative EFI, LUKS2, and ext4 layout
nixos/hosts/crypto-vm/hardware-configuration.nix KVM hardware baseline
nixos/modules/security.nix              local hardening and intentionally absent services
nixos/modules/networking.nix            NAT-friendly networking and Nix trust policy
nixos/modules/desktop.nix               XFCE Xorg desktop
nixos/modules/trezor.nix                Trezor-specific udev access
nixos/modules/browser.nix               dedicated Firefox policies
home-manager/crypto.nix                 user packages and declarative XFCE profile
SECURITY.md                       security boundary and limitations
HOST-CHECKLIST.md                 libvirt/virt-manager configuration checklist
```

XFCE is chosen because it is a conventional, maintained Xorg desktop with a smaller scope than GNOME. It is more dependable in a standard virt-manager graphics setup than an unusual minimalist compositor. The configuration removes its document/media viewers and screenshot utility, keeps the screen locker, and disables removable-media services.

## Initial VM creation and LUKS

Create a VM from a current NixOS 26.05 graphical installer ISO. Use a normal libvirt NAT network, a virtio disk, and an explicit virtual GPU. See [HOST-CHECKLIST.md](HOST-CHECKLIST.md) before booting it. Do not configure shared folders, virtiofs, 9p, clipboard sharing, drag-and-drop, USB auto-redirection, or the QEMU guest agent.

Use a single virtual disk at `/dev/vda`. The declarative layout in
`nixos/hosts/crypto-vm/disco.nix` creates a 1 GiB EFI system partition and a
LUKS2-encrypted ext4 root partition. Applying it erases the entire selected
disk. Confirm the installer sees the intended guest disk before proceeding.

```sh
lsblk
git clone https://YOUR-REPOSITORY-URL /tmp/crypto-vm
cd /tmp/crypto-vm
nix run --extra-experimental-features 'nix-command flakes' .#disko -- \
  --mode destroy,format,mount \
  --flake .#crypto-vm
```

Disko prompts twice for a strong LUKS passphrase. Never put it in Nix, a shell script, Git, an environment variable, initrd configuration, or a password manager. LUKS protects a powered-off disk copy and VM storage at rest. It does not protect the filesystem, memory, keyboard/display, or USB once the VM is unlocked, particularly from the host/hypervisor.

The disko command mounts the new filesystems at `/mnt`. Copy the repository into
the installed system and install it:

```sh
mkdir -p /mnt/etc/nixos/crypto-vm
cp -a /tmp/crypto-vm /mnt/etc/nixos/crypto-vm
cd /mnt/etc/nixos/crypto-vm
nixos-install --flake .#crypto-vm
nixos-enter --root /mnt -c 'passwd crypto'
reboot
```

`disco.nix` generates the root, `/boot`, and initrd LUKS declarations from stable
partition labels, so no disk UUID needs to be copied into the repository. Do not
apply the layout to an existing disk unless its contents may be erased.

## Rebuilding, updates, and rollbacks

From the repository in the running guest:

```sh
sudo nixos-rebuild switch --flake .#crypto-vm
```

### Home Manager profile

Home Manager is integrated into the `crypto-vm` NixOS configuration. Edit
`home-manager/crypto.nix` for packages and XFCE preferences of the `crypto`
user, then apply the change with the same system rebuild command:

```sh
sudo nixos-rebuild switch --flake .#crypto-vm
```

Do not run `home-manager switch` separately. On its first activation, Home
Manager saves an existing conflicting user configuration file with the
`.hm-backup` suffix. Log out and back in after changing XFCE panel, theme, or
keyboard-shortcut settings.

That command uses the existing `flake.lock`; it does not advance nixpkgs. The lock pins NixOS 26.05 to a specific commit. To deliberately update, review release notes and changes, then run:

```sh
nix flake update --flake .
nix flake check --no-build
sudo nixos-rebuild build --flake .#crypto-vm
sudo nixos-rebuild switch --flake .#crypto-vm
```

`nix flake update` changes the pinned revision in `flake.lock`; inspect it before switching. No automatic flake updates or automatic system upgrades are enabled. Cached binaries are accepted only from the official `cache.nixos.org` substituter signed by its configured public key. No third-party cache or signing key is trusted. The normal user may use Nix but is not a `trusted-user`; only root can make daemon-trust decisions.

List retained NixOS generations with:

```sh
sudo nix-env --list-generations --profile /nix/var/nix/profiles/system
```

Select an older generation in the bootloader at startup. After confirming it works, make it the default with:

```sh
sudo /nix/var/nix/profiles/system-<generation>-link/bin/switch-to-configuration switch
```

Rollback restores a system closure, not mutable browser profiles, exchange sessions, application databases, or files.

## Trezor USB passthrough and Suite

`trezor-suite` is installed from the pinned nixpkgs package. At this pin it is an upstream Trezor AppImage fetched with a fixed hash and wrapped by nixpkgs. That is a deliberate compatibility layer, not a dynamic download during activation, boot, or login. It increases the trusted desktop application surface and its version moves only when you update the pin. The package links its bridge executable from nixpkgs rather than using the bundled one.

The system installs only the maintained `trezor-udev-rules` from the selected nixpkgs. The `crypto` user belongs to its narrow `trezord` device-access group. `services.trezord` is intentionally disabled: it would create an always-running bridge daemon. Trezor Suite desktop starts/uses its own bridge only when necessary. Check it after launching Suite if desired:

```sh
ss -ltnp
```

No persistent bridge listener should exist before Suite is launched. Any Suite bridge listener must be loopback-only; close Suite when done. Trezor Suite's optional experimental MCP server must remain disabled.

Firefox is the single financial browser but is not the Trezor Web default. Firefox does not support WebUSB. Current Trezor Suite Web requires a Chromium-based browser for WebUSB, or Trezor Bridge for Firefox. Neither is installed as the normal path; desktop Suite is simpler and pinned.

Recommended workflow:

1. Boot the VM and enter the LUKS passphrase manually.
2. Log in as `crypto`.
3. Connect the Trezor physically.
4. In virt-manager, explicitly attach that exact Trezor USB device to this VM.
5. Verify the guest sees the expected device, then open Trezor Suite.
6. Perform only the intended operation.
7. Verify address, amount, asset/network, and device-visible details on the Trezor display.
8. Approve only on the Trezor after that verification.
9. Close Suite and browser sessions, detach the device in virt-manager, and physically disconnect it.
10. Shut down the VM when crypto activity is complete.

USB passthrough is selected by the host and does not remove the host/hypervisor from the trust model. USB mass-storage automounting is disabled and `usb-storage`/`uas` are blacklisted. This does not block Trezor HID or WebUSB communication, which are not USB-storage protocols.

Never enter a Trezor wallet backup/recovery seed into this VM, a browser, the clipboard, a password manager, a screenshot, shell history, Nix, or Git. Prefer recovery performed directly on the device when the model supports it. For firmware updates, start the update deliberately from current Trezor Suite, review the model and version, and confirm on-device. Ensure written recovery material is available and legible first; do not digitize it.

## Browser, wallets, backups, and daily practice

Firefox policy disables telemetry, studies, Pocket, Firefox account sync, form history, saved passwords, and extension installation. This is containment, not anonymity. No browser password or secret is managed declaratively. Do not use this guest for general browsing, email, Telegram, Discord, social media, development, unrelated downloads, documents, or entertainment.

The XFCE application menu also contains "Brave Rabby". It always starts with its own profile at `/home/crypto/.local/share/brave-rabby`; Firefox data and the normal Brave profile are not used. Enterprise policy installs the official Rabby Wallet Chrome Web Store extension and blocks all other extensions, sync, browser sign-in, autofill, saved passwords, private windows, and additional Brave profiles. Open `brave://policy` after the first launch to confirm that the policy loaded. Rabby extension updates are signed publisher updates retrieved through the Chrome Web Store update service, not Nix store artifacts.

Do not create, import, or restore a software-wallet seed in Rabby. Use the Trezor hardware-wallet connection path, verify every transaction on the Trezor display, and treat the Brave profile as potentially disposable state.

Additional wallets are deliberately absent. Add one only by editing `environment.systemPackages` in `nixos/hosts/crypto-vm/configuration.nix` after reviewing nixpkgs provenance, updates, Trezor support, private-key behavior, and required daemons. Prefer nixpkgs packages. Never add download-and-run activation scripts or imperatively installed binaries.

The VM is disposable. Back up this repository and its reviewed lock file, not seeds, private keys, recovery material, exchange credentials, API keys, 2FA codes, LUKS passphrases, or password-manager secrets. The Nix store is world-readable to local users and contains source/configuration text, closures, and build outputs. It is not secret storage.

Snapshots are not backups. They can capture cookies, logged-in sessions, wallet metadata, and, for memory snapshots, sensitive RAM. Prefer a powered-off storage-level snapshot if there is a specific operational reason. An encrypted powered-off disk copy retains LUKS at-rest protection; a running snapshot or unlocked state does not. Never store recovery material in a snapshot.

Read [SECURITY.md](SECURITY.md) for remaining trust assumptions and [HOST-CHECKLIST.md](HOST-CHECKLIST.md) for required host-side settings.
