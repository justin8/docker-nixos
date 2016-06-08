FROM debian:8.4
RUN apt-get update && apt-get install -y curl sudo bzip2 xz-utils

ENV USER=root \
    VERSION=16.03
RUN groupadd -r nixbld && \
    usermod -a -G nixbld nobody
RUN curl https://nixos.org/nix/install | sh
RUN bash -c ". /root/.nix-profile/etc/profile.d/nix.sh && \
            nix-channel --add http://nixos.org/channels/nixos-$VERSION/ && \
            nix-channel --remove nixpkgs && \
            nix-channel --update"
ADD build.sh /build.sh

VOLUME /out
CMD /build.sh
