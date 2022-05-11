#FROM --platform=linux/ppc64le ibmcom/xlf-ce as builder
FROM ppc64le/ubuntu:bionic
ENV XLF_REPO_URL https://public.dhe.ibm.com/software/server/POWER/Linux/xl-compiler/eval/ppc64le
ENV XLF_REPO_KEY_SHA256SUM e0eba411ed1cbf48fdab9e03dfc159a280bd728e716dd408ef321e42ac3ae552
ENV XLF_VRM 16.1.1
#caching from host cache dir

LABEL org.opencontainers.image.description "ppc64le image  with xlf"

ARG DEBIAN_FRONTEND=noninteractive
ARG APT_KEY_DONT_WARN_ON_DANGEROUS_USAGE=1
ARG FC
ARG CACHE_HIT
SHELL ["/bin/bash","-c"]
RUN  apt-get update && apt-get install -y wget gpg && \
  wget -q "$XLF_REPO_URL/ubuntu/public.gpg" && \
  apt-get purge -y --auto-remove wget && \
  echo "$XLF_REPO_KEY_SHA256SUM public.gpg"| sha256sum -c - && \
  apt-key add public.gpg && \
  rm public.gpg && \
  echo "deb $XLF_REPO_URL/ubuntu/ xenial main" > /etc/apt/sources.list.d/ibm-xl-compiler.list && \
  apt-get update && apt-get install -y \
    "xlf.$XLF_VRM" \
    "xlf-license-community.$XLF_VRM" && \
    rm -f /tmp/in.txt  && \
    echo 1 > /tmp/in.txt && \
   /opt/ibm/xlf/$XLF_VRM/bin/xlf_configure </tmp/in.txt  && \
   xlf -qversion && \
   dpkg-query -Wf '${Installed-Size}\t${Package}\n' | sort -n | tail -n 100

ENV LICENSE=accept \
	   



#CMD ["/bin/bash"]

