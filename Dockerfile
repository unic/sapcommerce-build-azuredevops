ARG buildimage_version
FROM lennartjuetteunic/sapcommerce-build-image:$buildimage_version

ENV MAVEN_VERSION=3.8.6
ENV MAVEN_SHA512=f790857f3b1f90ae8d16281f902c689e4f136ebe584aba45e4b1fa66c80cba826d3e0e52fdd04ed44b4c66f6d3fe3584a057c26dfcac544a60b301e6d0f91c26
# To make it easier for build and release pipelines to run apt-get,
# configure apt to not require confirmation (assume the -y argument by default)
ENV DEBIAN_FRONTEND=noninteractive
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

RUN echo "APT::Get::Assume-Yes \"true\";" > /etc/apt/apt.conf.d/90assumeyes

RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    jq \
    git \
    iputils-ping \
    libcurl4 \
    libicu66 \
    libunwind8 \
    netcat \
    libssl1.0 \
  && rm -rf /var/lib/apt/lists/*

RUN curl -LsS https://aka.ms/InstallAzureCLIDeb | bash \
  && rm -rf /var/lib/apt/lists/*

RUN curl https://dlcdn.apache.org/maven/maven-3/${MAVEN_VERSION}/binaries/apache-maven-${MAVEN_VERSION}-bin.tar.gz -o /tmp/maven.tar.gz \
  && echo "${MAVEN_SHA512}  /tmp/maven.tar.gz" | sha512sum -c - \
  && tar -zxf /tmp/maven.tar.gz -C /opt \
  && rm /tmp/maven.tar.gz \
  && ln -s /opt/apache-maven-*/bin/mvn /usr/local/bin/mvn

RUN curl -L https://github.com/SAP/SapMachine/releases/download/sapmachine-17.0.4.1/sapmachine-jdk-17.0.4.1_linux-x64_bin.tar.gz -o /tmp/sapmachine17.tar.gz \
  && tar -zxf /tmp/sapmachine17.tar.gz -C /opt \
  && rm /tmp/sapmachine17.tar.gz \
  && mv /opt/sapmachine-jdk-17* /opt/sapmachine-jdk-17

ENV JAVA_HOME_17_X64=/opt/sapmachine-jdk-17

# Can be 'linux-x64', 'linux-arm64', 'linux-arm', 'rhel.6-x64'.
ENV TARGETARCH=linux-x64

WORKDIR /azp

COPY ./start.sh .
RUN chmod +x start.sh

ENTRYPOINT ["./start.sh"]