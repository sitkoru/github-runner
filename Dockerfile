FROM mcr.microsoft.com/dotnet/core/sdk:3.1

USER root

ENV GRPC_VERSION v1.30.x
ENV NODE_VERSION 14.x

RUN curl -fsSL https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add -

RUN apt-get update \
    && apt-get install -y build-essential autoconf libtool pkg-config wget git unzip libatomic1 libgflags-dev apt-utils apt-transport-https ca-certificates gnupg2 software-properties-common rsync openssh-client \
    && add-apt-repository "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" \
    && curl -sL https://deb.nodesource.com/setup_${NODE_VERSION} | bash - \
    && apt-get install -y --no-install-recommends libc6 libgcc1 libgssapi-krb5-2 libicu63 libssl1.1 libstdc++6 \
    google-chrome-stable fonts-ipafont-gothic fonts-wqy-zenhei fonts-thai-tlwg fonts-kacst fonts-freefont-ttf nodejs zlib1g \
    php-cli php-gd php-gmp php-pgsql php-mysql php-soap php-zip php-xsl php-opcache php-bcmath php-mysqli php-exif php-intl php-redis php-curl \
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
    && apt purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false software-properties-common \
    && curl -sL https://dl.min.io/client/mc/release/linux-amd64/mc -o /usr/local/bin/mc && chmod +x /usr/local/bin/mc

# Install Composer and plugins
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/bin -- --filename=composer
RUN composer global require "fxp/composer-asset-plugin:^1.4.2" --prefer-dist
RUN composer global require "hirak/prestissimo:^0.3" --prefer-dist
