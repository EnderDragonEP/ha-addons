ARCH=$(cat /etc/apk/arch)

# Download NATMap for the detected architecture
case $ARCH in
  x86) DL=i586;;
  x86_64) DL=x86_64;;
  armhf) DL=arm32hf;;
  armv7) DL=arm32v7;;
  aarch64) DL=arm64;;
  ppc64le) DL=powerpc64;;
  riscv64) DL=riscv64;;
  s390x) DL=s390x;;
esac
wget https://github.com/heiher/natmap/releases/latest/download/natmap-linux-$DL -O /files/natmap

# Re-check dependencies after updating the H@H client version
# jdeps --multi-release 21 /files/HentaiAtHome.jar >/tmp/DEPS 2>/dev/null
# DEPS=$(cat /tmp/DEPS | awk '{print$NF}' | grep -E '^(java|jdk)\.' | sort | uniq | tr '\n' ',')jdk.crypto.ec
DEPS=java.base,jdk.crypto.ec

# x86/armhf/armv7 do not support jlink; install openjdk8-jre-base in the release image
# ppc64le/s390x can use openjdk11; ppc64le Java fails under qemu and s390x reports
# "Ambiguous z/Architecture detection!" but builds still succeed
[[ $ARCH =~ 'x86_64|aarch64|ppc64le|s390x' ]] && \
apk add openjdk11 && \
jlink --no-header-files --no-man-pages --compress=2 --strip-debug --add-modules $DEPS --output /files/jre

# riscv64 does not support OpenJDK versions earlier than 21
[[ $ARCH =~ 'riscv64' ]] && \
apk add openjdk21 binutils && \
jlink --no-header-files --no-man-pages --compress=zip-9 --strip-debug --add-modules $DEPS --output /files/jre

exit 0
