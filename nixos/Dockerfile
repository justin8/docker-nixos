FROM scratch
ADD rootfs.tar.xz /

#GIT_SSL_CAINFO is needed for 16.03 (patched in unstable)
ENV NIX_PATH=nixpkgs=/root/channels/nixpkgs \
    PATH=/nix/var/nix/profiles/default/bin \
    SSL_CERT_FILE=/nix/var/nix/profiles/default/etc/ssl/certs/ca-bundle.crt \
    GIT_SSL_CAINFO=/nix/var/nix/profiles/default/etc/ssl/certs/ca-bundle.crt \
    USER=root \
    HOME=/nix

RUN nix-channel --update