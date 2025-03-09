# MEV Bot Management

## 简介

这是一个用于批量运维服务器的自动化脚本，主要用于 **快捷部署管理多台** Rust MEV Bot 的运行

- Rust MEV Bot 项目地址 https://github.com/SaoXuan/rust-mev-bot-shared

- [Discord 群聊，欢迎进来和大佬们一起搞钱](https://discord.gg/rCBZy4ZKZD)

## 使用说明

把本项目克隆到一台管理服务器上（或者自己本地），推荐放在/root/目录下

### 环境安装&脚本配置

1. 确保管理机已安装 Ansible、sshpass

   Ansible 用来执行编排脚本，sshpass 用来帮助管理机登录目标机器

```bash
# 安装Ansible和依赖
sudo apt update && sudo apt install -y ansible sshpass python3-jmespath

# 验证安装
ansible --version  # 应显示2.9+
```

2. 将 `hosts.yml.template` 文件重命名为 `hosts.yml` 并根据实际情况填写服务器信息以及**差异配置**（每台bot服务器不同的部分，比如 ip_addrs 字段）

   编写配置的时候注意格式、缩进，建议在 IDE 中编辑

3. 将加密后的私钥文件放置在 `playbooks/privatekey/` 目录下，并命名为 `PRIVATEKEY`

   如何获取 PRIVATEKEY：在任意一台机器上成功运行过 [rust-mev-bot-shared](https://github.com/SaoXuan/rust-mev-bot-shared) 项目后，你可以在bot根目录中找到一个名为`PRIVATEKEY`的文件，把他下载并保存到本项目的`playbooks/privatekey/`目录中

4. 将 `playbooks\templates\config.yaml.j2.template` 文件重命名为 `config.yaml.j2`，并完善 bot 的 **基本配置**（每台bot服务器相同的部分，比如 birdeye_api_key 字段）

   注意：这里的配置跟 [rust-mev-bot-shared](https://github.com/SaoXuan/rust-mev-bot-shared) 项目中的配置是一致的，只是对**差异配置**做了模板化，差异部分从 host.yml 文件中获取

5. 确保 `~/.ssh/mev-bot-key` 文件存在并包含正确的 SSH 私钥，并且保证管理机能直接使用 ssh 连接上你的所有 bot 机器，建议使用 sshpass 工具设置管理机免密登录

```sh
# 生成mev-bot-key ssh密钥
ssh-keygen -t rsa -b 4096 -C "mev-bot-management" -f ~/.ssh/mev-bot-key

sshpass -p 'bot1服务器ssh密码' ssh-copy-id -i ~/.ssh/mev-bot-key.pub -o StrictHostKeyChecking=no root@bot1服务器ip

sshpass -p 'bot2服务器ssh密码' ssh-copy-id -i ~/.ssh/mev-bot-key.pub -o StrictHostKeyChecking=no root@bot2服务器ip

# ... 这里需要用sshpass把所有的bot服务器配置一遍，保证管理机能获取所有bot服务器的ssh权限
```

### 使用 MEV Bot Management

以下命令需要在项目根目录中运行

#### 重新部署Bot

运行以下命令来部署 MEV Bot：
ansible-playbook 会根据编排自动下载安装 bot 机器人，并且在名为 auto-bot 的 screen 中运行机器人。

```sh
# 全量重新部署
ansible-playbook -i hosts.yml --private-key ~/.ssh/mev-bot-key playbooks/deploy.yml

# 指定某台机器(server01)重新部署
ansible-playbook -i hosts.yml --private-key ~/.ssh/mev-bot-key --limit "server01" playbooks/deploy.yml
```

![alt text](./docs/image.png)

#### 仅更新配置文件，不重启Bot

```sh
ansible-playbook -i hosts.yml --private-key ~/.ssh/mev-bot-key playbooks/update_config.yml
```

## 常见问题

1. 如何检查bot是否运行起来了？

   自行登录bot服务器，输入`screen -r auto-bot`进入会话查看bot具体运行情况

...
