# Host-side KVM/libvirt/virt-manager checklist

These choices are configured on the Linux host in libvirt or virt-manager. The guest cannot reliably enforce them. The classifications are for this compartmentalization threat model, where the host remains trusted while the VM runs.

| Item | Classification | Guidance |
| --- | --- | --- |
| libvirt NAT network | recommended | Keep the guest behind libvirt's default NAT instead of placing it directly on the LAN. The guest still needs outbound Internet access. |
| Bridged networking | potentially harmful / unnecessary attack surface | It exposes the guest directly to the LAN without a concrete need. |
| SPICE or virtio graphics display | recommended | A local display is necessary. Use it without clipboard or file-transfer channels. |
| Shared clipboard | potentially harmful / unnecessary attack surface | Disable bidirectional clipboard sharing. It turns sensitive addresses and secrets into host/guest data flow. |
| Drag-and-drop | potentially harmful / unnecessary attack surface | Disable it. Use no convenience transfer path. |
| Shared folders | potentially harmful / unnecessary attack surface | Do not configure host filesystem sharing. |
| virtiofs | potentially harmful / unnecessary attack surface | Do not expose host directories. |
| 9p filesystem sharing | potentially harmful / unnecessary attack surface | Do not expose host directories. |
| QEMU guest agent | unnecessary for this threat model | Do not install or enable it. Shutdown, IP reporting, and host integration are convenience features, not required for display or networking. |
| SPICE guest tools | potentially harmful / unnecessary attack surface | Do not install broad guest integration solely for clipboard, file sharing, or resolution convenience. Normal virtio/QXL graphics does not require clipboard sharing. |
| Explicit Trezor USB passthrough | recommended | Attach the individual Trezor only when needed and detach it immediately afterwards. Verify vendor/product/device in virt-manager. |
| USB auto-redirection | potentially harmful / unnecessary attack surface | Disable it. Never expose arbitrary USB devices automatically. |
| USB storage passthrough | potentially harmful / unnecessary attack surface | Do not attach storage to this guest. The guest additionally blacklists USB-storage drivers. |
| VM autostart | unnecessary for this threat model | Leave disabled. Start the guest intentionally for crypto activity. |
| Disk snapshots | optional defense-in-depth | Useful only for recovery experiments, not backups. Prefer a shut-down guest and treat snapshot files as sensitive. |
| Memory snapshots | potentially harmful / unnecessary attack surface | Avoid them. They can contain unlocked disk keys, browser sessions, wallet metadata, and secrets. |
| Host filesystem access | potentially harmful / unnecessary attack surface | There must be no host mount, share, virtiofs, or 9p path in the VM definition. |
| OVMF/UEFI | optional defense-in-depth | Modern firmware behavior and an EFI system partition are useful operationally. It does not establish trust against the host, which provides the firmware image and VM configuration. |
| Secure Boot | unnecessary for this threat model | It can verify a guest boot chain only against keys and firmware supplied by the host. It adds operational complexity without protecting against the stated hostile-host case. Consider it only if you have a separately managed guest key/firmware process. |
| virtual TPM | unnecessary for this threat model | A host-controlled vTPM does not protect secrets from that host. Do not bind automatic LUKS unlock to it. It can be reconsidered for a distinct measured-boot policy, not as host-compromise protection. |

Use an encrypted qcow2 or raw image only as a storage-management preference; the guest LUKS volume is the meaningful guest at-rest control. Avoid VM memory dump, suspend-to-disk, and host backup jobs that silently copy a running VM. A host administrator can still access guest storage and memory, so these are risk-reduction choices, not a new trust boundary.
