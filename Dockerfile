FROM tcardonne/github-runner:latest

USER root

ENV DOTNET_VERSION 3.1.300
ENV GRPC_VERSION v1.29.x
ENV NODE_VERSION 13.x

RUN curl -fsSL https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add - \
    && add-apt-repository "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" \
    && curl -sL https://deb.nodesource.com/setup_${NODE_VERSION} | bash -

RUN apt-get update \
    && apt-get install -y --no-install-recommends libc6 libgcc1 libgssapi-krb5-2 libicu63 libssl1.1 libstdc++6  build-essential autoconf automake libtool pkg-config git unzip \
    curl libatomic1 libgflags-dev apt-utils apt-transport-https ca-certificates gnupg2 software-properties-common rsync openssh-client \
    google-chrome-stable fonts-ipafont-gothic fonts-wqy-zenhei fonts-thai-tlwg fonts-kacst fonts-freefont-ttf nodejs zlib1g \
    && cd /tmp \
    && mkdir grpc \
    && git clone --recursive -b ${GRPC_VERSION} https://github.com/grpc/grpc \
    && cd grpc \
    && git submodule update --init \
    && make grpc_php_plugin \
    && cp bins/opt/grpc_php_plugin /usr/local/bin/grpc_php_client_plugin \
    && cp bins/opt/protobuf/protoc /usr/local/bin/protoc \
    && mkdir -p /opt/include/google/protobuf \
    && cp third_party/protobuf/src/google/protobuf/*.proto /opt/include/google/protobuf \
    && rm -rf /tmp/* \
    && apt purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false build-essential autoconf libtool pkg-config unzip \
    && curl -sL https://dl.min.io/client/mc/release/linux-amd64/mc -o /usr/local/bin/mc && chmod +x /usr/local/bin/mc

ENV \
    # Enable detection of running in a container
    DOTNET_RUNNING_IN_CONTAINER=true \
    # Enable correct mode for dotnet watch (only mode supported in a container)
    DOTNET_USE_POLLING_FILE_WATCHER=true \
    # Skip extraction of XML docs - generally not useful within an image/container - helps performance
    NUGET_XMLDOC_MODE=skip \
    # PowerShell telemetry for docker image usage
    POWERSHELL_DISTRIBUTION_CHANNEL=PSDocker-DotnetCoreSDK-Debian-10

# Install .NET Core SDK
RUN cd /tmp && curl -sL https://dotnet.microsoft.com/download/dotnet-core/scripts/v1/dotnet-install.sh -o dotnet-install.sh \
    && chmod +x dotnet-install.sh \
    && ./dotnet-install.sh --version $DOTNET_VERSION --install-dir /usr/share/dotnet \
    && ln -s /usr/share/dotnet/dotnet /usr/bin/dotnet