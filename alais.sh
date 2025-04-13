# 自動偵測你用的 shell 設定檔
if [ -n "$ZSH_VERSION" ]; then
    SHELL_RC="$HOME/.zshrc"
elif [ -n "$BASH_VERSION" ]; then
    SHELL_RC="$HOME/.bashrc"
else
    echo "無法判斷使用的 shell，請手動設定 ~/.bashrc 或 ~/.zshrc"
    exit 1
fi

# 定義 alias 內容
ALIAS_CONTENT=$(cat <<'EOF'

# ==== Kubernetes 快速 alias ====
# kubectl 快速鍵
alias k='kubectl'
alias kg='kubectl get'
alias kga='kubectl get all'
alias kd='kubectl describe'
alias kdel='kubectl delete'
alias ke='kubectl edit'
alias kl='kubectl logs'
alias kctx='kubectl config use-context'
alias kns='kubectl config set-context --current --namespace'

# 範例：快速取得各資源
alias kgp='kubectl get pods'
alias kgs='kubectl get svc'
alias kgn='kubectl get nodes'
alias kgd='kubectl get deployments'
alias kgi='kubectl get ingress'

# 範例：描述特定資源
alias kdp='kubectl describe pod'
alias kds='kubectl describe svc'
alias kdd='kubectl describe deployment'

# 範例：刪除資源
alias kdelp='kubectl delete pod'
alias kdeld='kubectl delete deployment'
alias kdels='kubectl delete svc'
# ==== End Kubernetes alias ====

EOF
)

# 加入 alias 到設定檔（若尚未存在）
if ! grep -q "Kubernetes 快速 alias" "$SHELL_RC"; then
    echo "$ALIAS_CONTENT" >> "$SHELL_RC"
    echo "✅ Alias 已新增到 $SHELL_RC"
else
    echo "⚠️ 你已經加過 alias 了，略過新增。"
fi

# 套用設定
source "$SHELL_RC"
echo "✅ 已套用 alias，現在可以開始使用如 'kgp'、'kgn' 等縮寫指令囉！"
