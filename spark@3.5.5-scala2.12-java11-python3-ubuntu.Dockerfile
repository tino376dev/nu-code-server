FROM docker.io/apache/spark:3.5.5-scala2.12-java11-python3-ubuntu
# configure environment
USER root
ENV PATH="/root/.cargo/bin:${PATH}"
ENV CARGO_HOME="/root/.cargo"
ENV RUSTUP_HOME="/root/.rustup"
# install rust, code-server, and some python packages
RUN apt-get update \
    && apt-get -y install curl wget gpg apt-transport-https \
    && wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg \
    && install -D -o root -g root -m 644 packages.microsoft.gpg /etc/apt/keyrings/packages.microsoft.gpg \
    && echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" | tee /etc/apt/sources.list.d/vscode.list > /dev/null \
    && rm -f packages.microsoft.gpg \
    && apt-get update \
    && apt-get -y install code-insiders \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    && curl https://sh.rustup.rs -sSf | sh -s -- -y \
    && curl -s https://api.github.com/repos/nushell/nushell/releases/latest \
    | grep "browser_download_url.*x86_64-unknown-linux-gnu.tar.gz" \
    | grep -oP '(?<="browser_download_url": ").*(?=")' \
    | xargs -n 1 curl -L \
    | tar -xz -C /usr/bin --strip-components=1 \
    && pip install delta-sharing findspark ipykernel
# embed the delta-sharing spark jar
RUN echo 'import findspark' > /root/session.py \
    && echo 'findspark.init()' >> /root/session.py \
    && echo 'from pyspark.sql import SparkSession' >> /root/session.py \
    && echo 'spark = SparkSession.builder.appName("resolve-delta-sharing-spark").config("spark.sql.extensions", "io.delta.sql.DeltaSparkSessionExtension").config("spark.sql.catalog.spark_catalog", "org.apache.spark.sql.delta.catalog.DeltaCatalog").config("spark.jars.packages", "io.delta:delta-sharing-spark_2.12:3.3.0").getOrCreate()' >> /root/session.py \
    && python3 /root/session.py \
    && rm /root/session.py
# configure code-server
ENTRYPOINT ["code-insiders", "serve-web", "--host", "0.0.0.0", "--port", "8080", "--accept-server-license-terms", "--without-connection-token"]
EXPOSE 8080
