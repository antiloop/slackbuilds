#!/bin/sh

SB_PATCHDIR=${CWD}/patches

# Set to test (some patches require others, so, is not 100%)
DRYRUN=${DRYRUN:-NO}

if [ "${DRYRUN}" = "YES" ] ; then
  DRYRUN_OPT="--dry-run"
fi

if [ "${VERBOSE}" = "YES" ] ; then
  VERBOSE_OPT="--verbose"
fi

if [ "${SVERBOSE}" = "YES" ] ; then
  set -o xtrace
fi

PATCHCOM="patch ${DRYRUN_OPT} -p1 -F1 -s ${VERBOSE_OPT}"

# Adds layer 7 iptables support
zcat ${SB_PATCHDIR}/kernel-2.6.25-layer7-2.19.patch.gz | ${PATCHCOM} || exit 1

# This patch adds a "make nonint_oldconfig" which is non-interactive and
# also gives a list of missing options at the end. Useful for automated
# builds (as used in the buildsystem).
zcat ${SB_PATCHDIR}/linux-2.6-build-nonintconfig.patch.gz | ${PATCHCOM} || exit 1

C=$(zcat ${SB_PATCHDIR}/linux-2.6-hotfixes.patch.gz | wc -l | awk '{print $1}')
if [ "$C" -gt 10 ]; then
  zcat ${SB_PATCHDIR}/linux-2.6-hotfixes.patch.gz | ${PATCHCOM} || exit 1
fi

# revert patches from upstream that conflict or that we get via other means
C=$(zcat ${SB_PATCHDIR}/linux-2.6-upstream-reverts.patch.gz | wc -l | awk '{print $1}')
if [ "$C" -gt 10 ]; then
  zcat ${SB_PATCHDIR}/linux-2.6-upstream-reverts.patch.gz | ${PATCHCOM} -R || exit 1
fi

# Roland's utrace ptrace replacement.
zcat ${SB_PATCHDIR}/linux-2.6-ptrace-cleanup.patch.gz | ${PATCHCOM} || exit 1
zcat ${SB_PATCHDIR}/linux-2.6-tracehook.patch.gz | ${PATCHCOM} || exit 1
zcat ${SB_PATCHDIR}/linux-2.6-utrace.patch.gz | ${PATCHCOM} || exit 1

# enable sysrq-c on all kernels, not only kexec
zcat ${SB_PATCHDIR}/linux-2.6-sysrq-c.patch.gz | ${PATCHCOM} || exit 1

# Architecture patches
# dump *PIC state at boot with apic=debug
zcat ${SB_PATCHDIR}/linux-2.6-x86-apic-dump-all-regs-v3.patch.gz | ${PATCHCOM} || exit 1
# x86 f00f bug not handled properly (#197455)
zcat ${SB_PATCHDIR}/linux-2.6-x86-64-fix-overlap-of-modules-and-fixmap-areas.patch.gz | ${PATCHCOM} || exit 1
zcat ${SB_PATCHDIR}/linux-2.6-x86-fdiv-bug-detection-fix.patch.gz | ${PATCHCOM} || exit 1
# another machine needing io_delay=0xed
zcat ${SB_PATCHDIR}/linux-2.6-x86-io-delay-add-hp-f700-quirk.patch.gz | ${PATCHCOM} || exit 1
# oprofile / hibernation fix
zcat ${SB_PATCHDIR}/linux-2.6-x86-fix-oprofile-and-hibernation-issues.patch.gz | ${PATCHCOM} || exit 1
zcat ${SB_PATCHDIR}/linux-2.6-x86-32-amd-c1e-force-timer-broadcast-late.patch.gz | ${PATCHCOM} || exit 1
zcat ${SB_PATCHDIR}/linux-2.6-x86-pat-proper-tracking-of-set_memory_uc.patch.gz | ${PATCHCOM} || exit 1
# hpet fixes from 2.6.27
zcat ${SB_PATCHDIR}/linux-2.6-x86-hpet-01-fix-moronic-32-64-bit-thinko.patch.gz | ${PATCHCOM} || exit 1
zcat ${SB_PATCHDIR}/linux-2.6-x86-hpet-02-read-back-compare-register.patch.gz | ${PATCHCOM} || exit 1
zcat ${SB_PATCHDIR}/linux-2.6-x86-hpet-03-make-minimum-reprogramming-delta-useful.patch.gz | ${PATCHCOM} || exit 1
zcat ${SB_PATCHDIR}/linux-2.6-x86-hpet-04-workaround-sb700-bios.patch.gz | ${PATCHCOM} || exit 1

#
# Exec shield
#
zcat ${SB_PATCHDIR}/linux-2.6-execshield.patch.gz | ${PATCHCOM} || exit 1

#
# bugfixes to drivers and filesystems
#

# USB
zcat ${SB_PATCHDIR}/linux-2.6-usb-ehci-hcd-respect-nousb.patch.gz | ${PATCHCOM} || exit 1

# ACPI
# obvious bug in processor driver
zcat ${SB_PATCHDIR}/linux-2.6-acpi-processor-use-signed-int.patch.gz | ${PATCHCOM} || exit 1
# fix cpuidle misbehavior
zcat ${SB_PATCHDIR}/linux-2.6-cpuidle-1-do-not-use-poll_idle-unless-user-asks-for-it.patch.gz | ${PATCHCOM} || exit 1
zcat ${SB_PATCHDIR}/linux-2.6-cpuidle-2-menu-governor-fix-wrong-usage-of-measured_us.patch.gz | ${PATCHCOM} || exit 1
zcat ${SB_PATCHDIR}/linux-2.6-cpuidle-3-make-ladder-governor-honor-latency-requirements.patch.gz | ${PATCHCOM} || exit 1

# Various low-impact patches to aid debugging.
zcat ${SB_PATCHDIR}/linux-2.6-debug-sizeof-structs.patch.gz | ${PATCHCOM} || exit 1
zcat ${SB_PATCHDIR}/linux-2.6-debug-nmi-timeout.patch.gz | ${PATCHCOM} || exit 1
zcat ${SB_PATCHDIR}/linux-2.6-debug-taint-vm.patch.gz | ${PATCHCOM} || exit 1
zcat ${SB_PATCHDIR}/linux-2.6-debug-spinlock-taint.patch.gz | ${PATCHCOM} || exit 1
#zcat ${SB_PATCHDIR}/linux-2.6-debug-no-quiet.patch.gz | ${PATCHCOM} || exit 1
# try to find out what is breaking acpi-cpufreq
zcat ${SB_PATCHDIR}/linux-2.6-debug-vm-would-have-oomkilled.patch.gz | ${PATCHCOM} || exit 1

#
# PCI
#
# disable message signaled interrupts
zcat ${SB_PATCHDIR}/linux-2.6-defaults-pci_no_msi.patch.gz | ${PATCHCOM} || exit 1

#
# SCSI Bits.
#
# fix cpqarray pci enable
zcat ${SB_PATCHDIR}/linux-2.6-scsi-cpqarray-set-master.patch.gz | ${PATCHCOM} || exit 1
# fix vmware emulated scsi controller
#zcat ${SB_PATCHDIR}/linux-2.6-scsi-mpt-vmware-fix.patch.gz | ${PATCHCOM} || exit 1

# ALSA
#

# block/bio
#
# don't discard barrier flags
zcat ${SB_PATCHDIR}/linux-2.6-block-submit_bh-discards-barrier-flag.patch.gz | ${PATCHCOM} || exit 1

# Filesystem patches.
# cifs
zcat ${SB_PATCHDIR}/linux-2.6-fs-cifs-turn-off-unicode-during-session-establishment.patch.gz | ${PATCHCOM} || exit 1
# Squashfs
zcat ${SB_PATCHDIR}/linux-2.6-squashfs.patch.gz | ${PATCHCOM} || exit 1

# Networking
# Disable easy to trigger printk's.
zcat ${SB_PATCHDIR}/linux-2.6-net-silence-noisy-printks.patch.gz | ${PATCHCOM} || exit 1

# Misc fixes
# The input layer spews crap no-one cares about.
zcat ${SB_PATCHDIR}/linux-2.6-input-kill-stupid-messages.patch.gz | ${PATCHCOM} || exit 1

# Allow to use 480600 baud on 16C950 UARTs
zcat ${SB_PATCHDIR}/linux-2.6-serial-460800.patch.gz | ${PATCHCOM} || exit 1
# Silence some useless messages that still get printed with 'quiet'
zcat ${SB_PATCHDIR}/linux-2.6-silence-noise.patch.gz | ${PATCHCOM} || exit 1

# Changes to upstream defaults.
# Use UTF-8 by default on VFAT.
zcat ${SB_PATCHDIR}/linux-2.6-defaults-fat-utf8.patch.gz | ${PATCHCOM} || exit 1

# libata
# fix it821x
zcat ${SB_PATCHDIR}/linux-2.6-libata-pata_it821x-driver-updates-and-reworking.patch.gz | ${PATCHCOM} || exit 1
# Make Eee disk faster.
zcat ${SB_PATCHDIR}/linux-2.6-sata-eeepc-faster.patch.gz | ${PATCHCOM} || exit 1
# don't use ahci for pata_marvell adapters
zcat ${SB_PATCHDIR}/linux-2.6-libata-pata_marvell-play-nice-with-ahci.patch.gz | ${PATCHCOM} || exit 1

#
# VM related fixes.
#

# wireless patches headed for 2.6.26
#zcat ${SB_PATCHDIR}/linux-2.6-wireless.patch.gz | ${PATCHCOM} || exit 1
# wireless patches headed for 2.6.27
zcat ${SB_PATCHDIR}/linux-2.6-wireless-pending.patch.gz | ${PATCHCOM} || exit 1

# Add misc wireless bits from upstream wireless tree
zcat ${SB_PATCHDIR}/linux-2.6-at76.patch.gz | ${PATCHCOM} || exit 1

# fixups to make current wireless patches build on this kernel
#zcat ${SB_PATCHDIR}/linux-2.6-wireless-fixups.patch.gz | ${PATCHCOM} || exit 1

C=$(zcat ${SB_PATCHDIR}/linux-2.6-wireless-stable-backports.patch.gz | wc -l | awk '{print $1}')
if [ "$C" -gt 10 ]; then
  zcat ${SB_PATCHDIR}/linux-2.6-wireless-stable-backports.patch.gz | ${PATCHCOM} || exit 1
fi

# fix for long-standing rt2500usb issues
zcat ${SB_PATCHDIR}/linux-2.6-rt2500usb-fix.patch.gz | ${PATCHCOM} || exit 1

# implement smarter atime updates support.
zcat ${SB_PATCHDIR}/linux-2.6-smarter-relatime.patch.gz | ${PATCHCOM} || exit 1

# NFS Client mounts hang when exported directory do not exist
zcat ${SB_PATCHDIR}/linux-2.6-nfs-client-mounts-hang.patch.gz | ${PATCHCOM} || exit 1

# build id related enhancements
zcat ${SB_PATCHDIR}/linux-2.6-default-mmf_dump_elf_headers.patch.gz | ${PATCHCOM} || exit 1

# http://www.lirc.org/
zcat ${SB_PATCHDIR}/linux-2.6-lirc.patch.gz | ${PATCHCOM} || exit 1

zcat ${SB_PATCHDIR}/linux-2.6-e1000-ich9.patch.gz | ${PATCHCOM} || exit 1

# atl2 driver for eeepc (and others)
zcat ${SB_PATCHDIR}/linux-2.6-netdev-atl2.patch.gz | ${PATCHCOM} || exit 1
zcat ${SB_PATCHDIR}/linux-2.6-netdev-atl1e.patch.gz | ${PATCHCOM} || exit 1

zcat ${SB_PATCHDIR}/linux-2.6-net-tulip-interrupt.patch.gz | ${PATCHCOM} || exit 1

zcat ${SB_PATCHDIR}/linux-2.6-netdev-e1000e-add-support-for-82567lm-4.patch.gz | ${PATCHCOM} || exit 1

# Nouveau DRM + drm fixes
zcat ${SB_PATCHDIR}/drm-fedora9-rollup.patch.gz | ${PATCHCOM} || exit 1

# linux1394 git patches
zcat ${SB_PATCHDIR}/linux-2.6-firewire-git-update.patch.gz | ${PATCHCOM} || exit 1
#C=$(zcat ${SB_PATCHDIR}/linux-2.6-firewire-git-pending.patch.gz | wc -l | awk '{print $1}')
#if [ "$C" -gt 10 ]; then
  #zcat ${SB_PATCHDIR}/linux-2.6-firewire-git-pending.patch.gz | ${PATCHCOM} || exit 1
#fi

# get rid of imacfb and make efifb work everywhere it was used
zcat ${SB_PATCHDIR}/linux-2.6-merge-efifb-imacfb.patch.gz | ${PATCHCOM} || exit 1
