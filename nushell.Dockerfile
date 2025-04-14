FROM docker.io/debian:latest
# install nu and codeserver
RUN apt-get update && apt-get install -y curl \
    && apt-get clean && rm -rf /var/lib/apt/lists/* \
    && curl -s https://api.github.com/repos/nushell/nushell/releases/latest \
    | grep "browser_download_url.*x86_64-unknown-linux-gnu.tar.gz" \
    | grep -oP '(?<="browser_download_url": ").*(?=")' \
    | xargs -n 1 curl -L \
    | tar -xz -C /usr/bin --strip-components=1 \
    && curl -fsSL https://code-server.dev/install.sh | sh
# configure code-server
WORKDIR /root/work
ENTRYPOINT  ["code-server", "--bind-addr", "0.0.0.0:8080", "--auth", "none", "--cert", "false", "--disable-telemetry"]
EXPOSE 8080
