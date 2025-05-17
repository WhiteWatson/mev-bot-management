#!/usr/bin/env bash
#
# stop.sh —— 依序停止 bot（server01 ~ server30）
# 可輸入：單一序號、區段序號、或混合
# 例：./stop.sh 1 4-6 9
# -------------------------------------------------------------

HOSTS_FILE="hosts.yml"
PRIVATE_KEY="~/.ssh/mev-bot-key"
PLAYBOOK="playbooks/stop.yml"
MAX_SERVER=30          # 伺服器總數；依實際情況調整

die() { echo "❌ $*"; exit 1; }

[[ $# -eq 0 ]] && die "用法：$0 <序號> [<序號或區段> …]"

# --- 將參數展開成 nums[] ---
nums=()
for arg in "$@"; do
  if [[ $arg =~ ^([0-9]+)-([0-9]+)$ ]]; then            # 區段
    s=${BASH_REMATCH[1]} e=${BASH_REMATCH[2]}
    ((s>=1 && e<=MAX_SERVER && s<=e)) || die "區段 $arg 超出 1-$MAX_SERVER"
    for ((i=s; i<=e; i++)); do nums+=("$i"); done
  elif [[ $arg =~ ^[0-9]+$ ]]; then                     # 單號
    ((arg>=1 && arg<=MAX_SERVER)) || die "序號 $arg 超出 1-$MAX_SERVER"
    nums+=("$arg")
  else
    die "參數格式錯誤：$arg"
  fi
done

# 去重並排序
IFS=$'\n' read -r -d '' -a nums < <(printf '%s\n' "${nums[@]}" | sort -n | uniq && printf '\0')

echo "▶️  即將依序停止 ${#nums[@]} 台伺服器…"

# --- 依序執行 ---
for n in "${nums[@]}"; do
  server=$(printf "server%02d" "$n")
  echo "=== 停止 ${server} ==="

  ansible-playbook -i "$HOSTS_FILE" \
                   --private-key "$PRIVATE_KEY" \
                   --limit="$server" \
                   "$PLAYBOOK"

  status=$?
  [[ $status -ne 0 ]] && echo "⚠️  ${server} 停止失敗 (exit $status)"
done

echo "✅ 指定伺服器全部停止完成"
