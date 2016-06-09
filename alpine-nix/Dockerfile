FROM alpine

ENV USER=root
RUN echo 'nixbld:x:998:nobody' >> /etc/group
RUN apk add -U curl sudo bash bzip2
RUN curl https://nixos.org/nix/install|sh

# Temporary path while we set up everything else
ENV NIX_PATH=nixpkgs=/root/.nix-defexpr/channels/nixpkgs:nixpkgs=/root/.nix-defexpr/channels/nixpkgs \
    PATH=/root/.nix-profile/bin:/root/.nix-profile/sbin:/root/.nix-profile/bin:/root/.nix-profile/sbin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin \
    SSL_CERT_FILE=/etc/ssl/certs/ca-certificates.crt

RUN nix-channel --update
RUN nix-env -iA nixpkgs.cacert nixpkgs.bash nixpkgs.coreutils
RUN ln -sf /root/.nix-profile/etc/ssl/certs/ca-bundle.crt /etc/ssl/certs/ca-certificates.crt

RUN /root/.nix-profile/bin/bash -c " \
    rm -rf /bin /sbin /usr/bin /usr/sbin /lib /usr && \
    ln -sf /root/.nix-profile/bin /bin && \
    ln -sf /root/.nix-profile/bin /sbin && \
    ln -sf /root/.nix-profile /usr && \
    ln -sf /root/.nix-profile/lib /lib && \
    chmod 755 /root"
