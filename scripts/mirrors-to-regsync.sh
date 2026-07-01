#!/usr/bin/env bash
# mirrors.yaml -> regsync.yml
# Usage: ./mirrors-to-regsync.sh [mirrors.yaml] > regsync.yml
set -euo pipefail
INPUT="${1:-mirrors.yaml}"

TARGET_REGISTRY="${ALIYUN_ECR_URL:-registry.cn-shanghai.aliyuncs.com}"

cat <<HEADER
# Generated from ${INPUT} on $(date -u +%Y-%m-%dT%H:%M:%SZ)
version: 1
defaults:
  parallel: 8
  interval: 60m
creds:
  - registry: docker.io
    user: "${DOCKER_HUB_USERNAME:-}"
    pass: "${DOCKER_HUB_TOKEN:-}"
  - registry: "${TARGET_REGISTRY}"
    user: "${ALIYUN_ECR_USERNAME:-}"
    pass: "${ALIYUN_ECR_PASSWORD:-}"
sync:
HEADER

# Extract each mirror entry and generate sync rules for each tag
yq -o json -I 0 "${INPUT}" | jq -r '
  .[] |
  .source as $src |
  .dst    as $dst |
  .tags[] |
  "  - source: \($src):\(.name)\n    target: '"${TARGET_REGISTRY}"'/\($dst):\(.name)\n    type: image\n"
'
