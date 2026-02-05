FROM golang:1.25-bookworm

WORKDIR /app

# System dependencies
RUN apt-get update && apt-get install -y \
    curl \
    unzip \
    git \
    ca-certificates \
 && rm -rf /var/lib/apt/lists/*

# --------------------
# Install Semgrep (pinned, arch-aware)
# --------------------
ENV SEMGREP_VERSION=1.78.0

RUN ARCH="$(uname -m)" && \
    if [ "$ARCH" = "x86_64" ]; then \
      SEMGREP_ARCH=amd64; \
    elif [ "$ARCH" = "aarch64" ] || [ "$ARCH" = "arm64" ]; then \
      SEMGREP_ARCH=arm64; \
    else \
      echo "Unsupported architecture: $ARCH" && exit 1; \
    fi && \
    curl -fL \
      https://github.com/returntocorp/semgrep/releases/download/v${SEMGREP_VERSION}/semgrep_linux_${SEMGREP_ARCH} \
      -o /usr/local/bin/semgrep && \
    chmod +x /usr/local/bin/semgrep

# --------------------
# Install CodeQL
# --------------------
ENV CODEQL_VERSION=2.17.5

RUN curl -fL \
    https://github.com/github/codeql-cli-binaries/releases/download/v${CODEQL_VERSION}/codeql-linux64.zip \
    -o codeql.zip \
 && unzip codeql.zip \
 && mv codeql /opt/codeql \
 && ln -s /opt/codeql/codeql /usr/local/bin/codeql \
 && rm codeql.zip

# --------------------
# Sanity checks (remove later if you want)
# --------------------
RUN semgrep --version && \
    codeql version && \
    go version

# --------------------
# Go dependencies
# --------------------
COPY go.mod go.sum ./
RUN go mod download

COPY . .

RUN go build -o action ./cmd/action

ENTRYPOINT ["/app/action"]
