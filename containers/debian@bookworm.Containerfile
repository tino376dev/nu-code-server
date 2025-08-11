FROM docker.io/library/debian:bookworm
RUN apt-get update \
    && apt-get -y install git wget gpg apt-transport-https \
    && wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg \
    && install -D -o root -g root -m 644 packages.microsoft.gpg /etc/apt/keyrings/packages.microsoft.gpg \
    && echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" | tee /etc/apt/sources.list.d/vscode.list > /dev/null \
    && rm -f packages.microsoft.gpg \
    && apt-get update \
    && apt-get -y install code-insiders \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*
ENTRYPOINT ["code-insiders", "serve-web", "--host", "0.0.0.0", "--port", "8080", "--accept-server-license-terms", "--without-connection-token"]
EXPOSE 8080
