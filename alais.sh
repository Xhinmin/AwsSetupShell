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
