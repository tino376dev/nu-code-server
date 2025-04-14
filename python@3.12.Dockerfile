FROM python:3.12
# install nu, code-server, and some python packages
RUN curl -s https://api.github.com/repos/nushell/nushell/releases/latest \
    | grep "browser_download_url.*x86_64-unknown-linux-gnu.tar.gz" \
    | grep -oP '(?<="browser_download_url": ").*(?=")' \
    | xargs -n 1 curl -L \
    | tar -xz -C /usr/bin --strip-components=1 \
    && curl -fsSL https://code-server.dev/install.sh | sh \
    && pip install ipykernel
# configure code-server
WORKDIR /root/work
ENTRYPOINT  ["code-server", "--bind-addr", "0.0.0.0:8080", "--auth", "none", "--cert", "false", "--disable-telemetry"]
EXPOSE 8080
