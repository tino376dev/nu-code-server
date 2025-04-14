FROM spark:3.5.5-scala2.12-java11-python3-ubuntu
# configure environment
USER root
ENV PATH="/root/.cargo/bin:${PATH}"
ENV CARGO_HOME="/root/.cargo"
ENV RUSTUP_HOME="/root/.rustup"
# install rust, code-server, and some python packages
RUN curl https://sh.rustup.rs -sSf | sh -s -- -y \
    &&curl -s https://api.github.com/repos/nushell/nushell/releases/latest \
    | grep "browser_download_url.*x86_64-unknown-linux-gnu.tar.gz" \
    | grep -oP '(?<="browser_download_url": ").*(?=")' \
    | xargs -n 1 curl -L \
    | tar -xz -C /usr/bin --strip-components=1 \
    && curl -fsSL https://code-server.dev/install.sh | sh \
    && pip install delta-sharing findspark ipykernel
# embed the delta-sharing spark jar
RUN echo 'import findspark' > /root/session.py \
    && echo 'findspark.init()' >> /root/session.py \
    && echo 'from pyspark.sql import SparkSession' >> /root/session.py \
    && echo 'spark = SparkSession.builder.appName("resolve-delta-sharing-spark").config("spark.sql.extensions", "io.delta.sql.DeltaSparkSessionExtension").config("spark.sql.catalog.spark_catalog", "org.apache.spark.sql.delta.catalog.DeltaCatalog").config("spark.jars.packages", "io.delta:delta-sharing-spark_2.12:3.3.0").getOrCreate()' >> /root/session.py \
    && python3 /root/session.py \
    && rm /root/session.py
# configure code-server
WORKDIR /root/work
ENTRYPOINT  ["code-server", "--bind-addr", "0.0.0.0:8080", "--auth", "none", "--cert", "false", "--disable-telemetry"]
EXPOSE 8080
