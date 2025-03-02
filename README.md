# MEV Bot Management

## 简介

这是一个用于批量运维服务器的自动化脚本，主要用于部署和管理 Rust MEV Bot https://github.com/SaoXuan/rust-mev-bot-shared。

## 使用说明

把项目克隆到一台管理服务器上，推荐放在/root/目录下

### 准备工作

1. 确保已安装 Ansible。

```bash
# 安装Ansible和依赖
sudo apt update && sudo apt install -y ansible sshpass python3-jmespath

# 验证安装
ansible --version  # 应显示2.9+
```

2. 将 `hosts.yml.template` 文件重命名为 `hosts.yml` 并根据实际情况填写服务器信息。
3. 将加密后的私钥文件放置在 `playbooks/privatekey/` 目录下，并命名为 `PRIVATEKEY`。
4. 修改 playbooks\templates\config.yaml.j2 文件中的配置信息，完善 bot 基本配置。
5. 确保 `~/.ssh/mev-bot-key` 文件存在并包含正确的 SSH 私钥，并且保证管理机能直接使用 ssh 连接上你的所有 bot 机器，建议使用 sshpass 工具设置管理机免密登录。

```sh
ssh-keygen -t rsa -b 4096 -C "mev-bot-management" -f ~/.ssh/mev-bot-key

sshpass -p 'bot服务器ssh密码' ssh-copy-id -i ~/.ssh/mev-bot-key.pub -o StrictHostKeyChecking=no root@bot服务器ip
```

### 部署 MEV Bot

运行以下命令来部署 MEV Bot：
Ansible 会根据编排自动下载安装 bot 机器人，并且在名为 auto-bot 的 screen 中运行机器人。

```sh
ansible-playbook -i hosts.yml --private-key ~/.ssh/mev-bot-key playbooks/deploy.yml
```

![alt text](./docs/image.png)

- [Discord 群聊，欢迎进来和大佬们一起搞钱](https://discord.gg/rCBZy4ZKZD)
