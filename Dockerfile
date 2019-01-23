# This Dockerfile is for production. Ideally I'd like to put it in scripts/docker/production
# but right now Ellie is deployed to zeit.co's now.sh service. now.sh can only find Dockerfiles
# in the root of the project. Development dockerfiles are found in scripts/docker/development.
FROM elixir:1.7.2

ENV DEBIAN_FRONTEND=noninteractive

# Install build-time deps
RUN curl -sL https://deb.nodesource.com/setup_10.x | bash - \
    && curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - \
    && echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list \
    && apt-get update \
    && apt-get install --no-install-recommends -qy build-essential nodejs \
    && npm install -g npm

# Install postgres-client
RUN echo "deb http://apt.postgresql.org/pub/repos/apt/ stretch-pgdg main" >> /etc/apt/sources.list.d/pgdg.list \
&& wget -q https://www.postgresql.org/media/keys/ACCC4CF8.asc -O - | apt-key add - \
&& apt-get update \
&& apt-get -yq --no-install-recommends install inotify-tools postgresql-client-9.5

# Install libsysconfcpus
RUN git clone https://github.com/obmarg/libsysconfcpus.git /usr/local/src/libsysconfcpus \
    && cd /usr/local/src/libsysconfcpus \
    && ./configure \
    && make \
    && make install \
    && cd / \
    && sysconfcpus --version

# Install Elixir tools
RUN mix local.hex --force \
    && mix local.rebar --force \
    && mix archive.install https://github.com/phoenixframework/archives/raw/master/phoenix_new.ez --force

# make the app rootfs
RUN mkdir -p /tmp/elm_bin/0.18.0 && mkdir -p /tmp/elm_bin/0.19.0 \
    && wget -q https://github.com/alco/goon/releases/download/v1.1.1/goon_linux_386.tar.gz -O /tmp/goon.tar.gz \
    && tar -xvC /tmp/elm_bin -f /tmp/goon.tar.gz \
    && chmod +x /tmp/elm_bin/goon \
    && rm /tmp/goon.tar.gz \
    && wget -q https://github.com/elm-lang/elm-platform/releases/download/0.18.0-exp/elm-platform-linux-64bit.tar.gz -O /tmp/platform-0.18.0.tar.gz \
    && tar -xvC /tmp/elm_bin/0.18.0 -f /tmp/platform-0.18.0.tar.gz \
    && rm /tmp/platform-0.18.0.tar.gz \
    && wget -q https://github.com/avh4/elm-format/releases/download/0.7.0-exp/elm-format-0.18-0.7.0-exp-linux-x64.tgz -O /tmp/format-0.18.0.tar.gz \
    && tar -xvC /tmp/elm_bin/0.18.0 -f /tmp/format-0.18.0.tar.gz \
    && rm /tmp/format-0.18.0.tar.gz \
    && chmod +x /tmp/elm_bin/0.18.0/* \
    && wget -q https://github.com/elm/compiler/releases/download/0.19.0/binaries-for-linux.tar.gz -O /tmp/platform-0.19.0.tar.gz \
    && tar -xvC /tmp/elm_bin/0.19.0 -f /tmp/platform-0.19.0.tar.gz \
    && rm /tmp/platform-0.19.0.tar.gz \
    && chmod +x /tmp/elm_bin/0.19.0/* \
    && wget -q https://github.com/avh4/elm-format/releases/download/0.8.0-rc3/elm-format-0.19-0.8.0-rc3-linux-x64.tgz -O /tmp/format-0.19.0.tar.gz \
    && tar -xvC /tmp/elm_bin/0.19.0 -f /tmp/format-0.19.0.tar.gz \
    && rm /tmp/format-0.19.0.tar.gz \
    && chmod +x /tmp/elm_bin/0.19.0/* \
    
    && git clone https://github.com/minlearn/ellie-corrected /app \
    && mkdir -p /app/priv/bin \
    && cp -r /tmp/elm_bin/* /app/priv/bin \
    && mkdir -p /app/priv/elm_home \
    
    && cp /app/run.sh /usr/local/bin \
    && chmod +x /usr/local/bin/run.sh \

    && cd /app \
    && mix deps.get \
    && mix compile \
    && mix do loadpaths, absinthe.schema.json /app/priv/graphql/schema.json \

    && cd /app/assets \
    && npm install \
    && npm run graphql \
    && npm run build
    
ENV MIX_ENV=prod \
    NODE_ENV=production \
    PORT=4000 \
    ELM_HOME=/app/priv/elm_home \
    SECRET_KEY_BASE="+ODF8PyQMpBDb5mxA117MqkLne/bGi0PZoTl5uIHAzck2hDAJ8uGJPzark0Aolyi"

# Run the server
WORKDIR /app
EXPOSE 4000
ENTRYPOINT ["run.sh"]

