FROM alpine:3.19 AS pullrepo

# Install necessary tools
RUN apk add --no-cache curl tar

WORKDIR /app

ARG GITHUB_TOKEN
ARG GITHUB_OWNER
ARG GITHUB_REPO
ARG GITHUB_REPO_BRANCH

RUN curl -L \
  -H "Accept: application/vnd.github+json" \
  -H "Authorization: Bearer ${GITHUB_TOKEN}" \
  -H "X-GitHub-Api-Version: 2022-11-28" \
  https://api.github.com/repos/${GITHUB_OWNER}/${GITHUB_REPO}/tarball/${GITHUB_REPO_BRANCH} | tar xz

RUN mv $(ls -d ${GITHUB_OWNER}-${GITHUB_REPO}*) repo

# build stage
FROM ghcr.io/astral-sh/uv:python3.10-bookworm-slim AS builder

ARG SUB_PATH

WORKDIR /app

COPY --from=pullrepo /app/repo .

WORKDIR /app${SUB_PATH:+/$SUB_PATH}

#Install dependencies
RUN uv sync --no-dev

# Expose port 80
EXPOSE 80

CMD ["uv", "run", "services"]
