#!/usr/bin/env bash
#
# 依參數 (單號或區段) 逐台重啟 bot，完成一台後暫停 5 秒
# 伺服器命名規則：server01 ~ server30
# -------------------------------------------------------------

HOSTS_FILE="hosts.yml"
PRIVATE_KEY="~/.ssh/mev-bot-key"
PLAYBOOK="playbooks/restartbot.yml"
MAX_SERVER=30          # 伺服器總數，用來驗證輸入

die() { echo "❌ $*"; exit 1; }

# --- 檢查參數 ---
[[ $# -eq 0 ]] && die "用法：$0 <序號> [<序號或區段> …]  例：$0 3 7-10"

# --- 將所有參數展開成數字陣列 nums[] ---
nums=()
for arg in "$@"; do
  if [[ $arg =~ ^([0-9]+)-([0-9]+)$ ]]; then            # 區段
    start=${BASH_REMATCH[1]}
    end=${BASH_REMATCH[2]}
    ((start >= 1 && end <= MAX_SERVER && start <= end)) \
      || die "區段 $arg 超出 1-$MAX_SERVER"
    for ((i=start; i<=end; i++)); do nums+=("$i"); done
  elif [[ $arg =~ ^[0-9]+$ ]]; then                     # 單號
    ((arg >= 1 && arg <= MAX_SERVER)) \
      || die "序號 $arg 超出 1-$MAX_SERVER"
    nums+=("$arg")
  else
    die "參數格式錯誤：$arg"
  fi
done

# 移除重複並排序
IFS=$'\n' read -r -d '' -a nums < <(printf '%s\n' "${nums[@]}" | sort -n | uniq && printf '\0')

# --- 主迴圈 ---
for n in "${nums[@]}"; do
  server=$(printf "server%02d" "$n")
  echo "=== 正在重啟 ${server} ==="

  ansible-playbook -i "$HOSTS_FILE" \
                   --private-key "$PRIVATE_KEY" \
                   --limit="$server" \
                   "$PLAYBOOK"

  if [[ $? -ne 0 ]]; then
    echo "⚠️  ${server} 執行失敗，請檢查上方訊息"
  fi

  # 若不是最後一台，等待 5 秒
  [[ ${n} != ${nums[-1]} ]] && { echo "等待 5 秒…"; sleep 5; }
done

echo "✅ 指定伺服器全部重啟完成"
