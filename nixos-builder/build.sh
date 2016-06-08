#!/usr/bin/env bash
set -exuf
set pipefail
source ~/.nix-profile/etc/profile.d/nix.sh

nix_chroot() {
    mounts=(dev proc)

    for mount in "${mounts[@]}"
    do
        mkdir -p "$rootfs/$mount"
        sudo mount --bind "/$mount" "$rootfs/$mount"
    done

    sudo chroot "$rootfs" "$@"

    for mount in "${mounts[@]}"
    do sudo umount "$rootfs/$mount"
    done
}

out=/out
rootfs=$(readlink -f "$(dirname "$0")")/rootfs
channel=nixos-$VERSION
channels_dir=$rootfs/root/channels
nixexprs=$channels_dir/$channel
build="nix-build --no-out-link $nixexprs --attr"
store_dir=$rootfs/nix/store

# Prepare build environment
mkdir -p "$channels_dir" "$rootfs/etc/nix" "$rootfs/tmp" "$store_dir"
cp -H --recursive "$HOME/.nix-defexpr/channels/$channel" "$nixexprs"
echo 'build-users-group =' > "$rootfs/etc/nix/nix.conf"

cacert=$($build cacert)
nix=$($build nix.out)

wanted_packages=(
$cacert
$nix

# The closure for Nix includes these so we are repeating ourselves a
# bit to make it easier to install them further down.
$($build bash)
$($build coreutils)
)

all_packages=(
$(nix-store --query --requisites "${wanted_packages[@]}" | sort --unique)
)

for p in "${all_packages[@]}"; do
    cp --recursive "$p" "$store_dir"/
done

nix-store --export "${all_packages[@]}" | nix_chroot "$nix/bin/nix-store" --import

nix_chroot "$nix/bin/nix-env" --install "${wanted_packages[@]}"

# some bash scripts want /usr/bin/env
mkdir -p "$rootfs/usr/bin"
ln -sf /nix/var/nix/profiles/default/bin/env "$rootfs/usr/bin/"

# Docker and some scripts like nix-channel want /bin/sh
mkdir -p "$rootfs/bin"
ln -sf /nix/var/nix/profiles/default/bin/sh "$rootfs/bin/"

# Set up channels for correct version and set /nix to be the home
echo "http://nixos.org/channels/nixos-$VERSION nixos-$VERSION" > $rootfs/nix/.nix-channels

# Random applications want these
echo hosts: files dns > "$rootfs/etc/nsswitch.conf"
echo root:x:0:0:root:/root:/bin/sh > "$rootfs/etc/passwd"

# cleanup temporary channels
rm -rf $channels_dir

rm -f "$out/nixos/rootfs.tar.xz"
tar cJv \
    -C "$rootfs" \
    -f "$out/nixos/rootfs.tar.xz" \
    .
