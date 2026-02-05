FROM golang:1.25-bookworm

WORKDIR /app

# --------------------
# System dependencies
# --------------------
RUN apt-get update && apt-get install -y \
    curl \
    unzip \
    git \
    ca-certificates \
    python3-pip \
 && rm -rf /var/lib/apt/lists/*

# --------------------
# Install Semgrep (pinned, robust)
# --------------------
RUN python3 -m venv /opt/venv && \
    /opt/venv/bin/pip install --upgrade pip && \
    /opt/venv/bin/pip install semgrep

# Optional: add to PATH
ENV PATH="/opt/venv/bin:$PATH"

RUN semgrep --version
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
# Sanity checks
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
