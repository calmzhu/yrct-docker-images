#!/usr/bin/env bash
# 在阿里云 ECS 上一键部署 regsync mirror 服务
# 前置条件: 已有阿里云 ECS (建议 CentOS 7+ / Ubuntu 20.04+)，已配置 ECR 凭证
set -euo pipefail

REGCLIENT_VER="0.8.2"
INSTALL_DIR="/opt/regsync"
REPO_URL="https://github.com/regclient/regclient.git"
# 你的仓库地址，clone 后获取 mirrors.yaml
# 实际使用时改为你自己的仓库 URL 或直接 scp mirrors.yaml 上来

echo "=== 1. 安装 regclient (包含 regsync) ==="
if ! command -v regsync &>/dev/null; then
  ARCH=$(uname -m)
  case "$ARCH" in
    x86_64)  BIN_ARCH="amd64" ;;
    aarch64) BIN_ARCH="arm64" ;;
    *)       echo "Unsupported arch: $ARCH"; exit 1 ;;
  esac
  curl -fsSL "https://github.com/regclient/regclient/releases/download/v${REGCLIENT_VER}/regclient-linux-${BIN_ARCH}.tar.gz" \
    | sudo tar -xz -C /usr/local/bin regsync regctl
  echo "regsync installed: $(regsync version)"
fi

echo "=== 2. 创建工作目录 ==="
sudo mkdir -p "${INSTALL_DIR}"

echo "=== 3. 生成 regsync 配置 (需先有 mirrors.yaml) ==="
# 方式 A: 从仓库 clone (推荐，mirrors.yaml 变更时自动拉取)
# 方式 B: 直接用 scp 上传 mirrors.yaml + scripts/mirrors-to-regsync.sh
# 
# 这里展示方式 A:
if [[ ! -d "${INSTALL_DIR}/yrct-docker-images" ]]; then
  git clone https://github.com/YOUR_ORG/yrct-docker-images.git "${INSTALL_DIR}/yrct-docker-images"
fi

cat > "${INSTALL_DIR}/sync.sh" <<'SYNC_SCRIPT'
#!/usr/bin/env bash
set -euo pipefail
cd /opt/regsync/yrct-docker-images

# 拉取最新 mirrors.yaml
git pull origin main

# 生成 regsync 配置并运行
bash scripts/mirrors-to-regsync.sh mirrors.yaml > /tmp/regsync.yml
regsync once -c /tmp/regsync.yml
SYNC_SCRIPT
chmod +x "${INSTALL_DIR}/sync.sh"

echo "=== 4. 配置 systemd timer (每小时同步一次) ==="
sudo tee /etc/systemd/system/regsync-mirror.service <<'SERVICE'
[Unit]
Description=Registry Mirror Sync (regsync)
After=network-online.target
Wants=network-online.target

[Service]
Type=oneshot
ExecStart=/opt/regsync/sync.sh
EnvironmentFile=/opt/regsync/.env
StandardOutput=journal
StandardError=journal

[Install]
WantedBy=multi-user.target
SERVICE

sudo tee /etc/systemd/system/regsync-mirror.timer <<'TIMER'
[Unit]
Description=Hourly registry mirror sync
Requires=regsync-mirror.service

[Timer]
OnCalendar=hourly
RandomizedDelaySec=300
Persistent=true

[Install]
WantedBy=timers.target
TIMER

sudo systemctl daemon-reload
sudo systemctl enable --now regsync-mirror.timer

echo "=== 5. 手动触发一次测试 ==="
sudo systemctl start regsync-mirror.service
echo "查看日志: sudo journalctl -u regsync-mirror.service -f"
