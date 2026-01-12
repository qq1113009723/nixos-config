# NixOS + Home Manager 配置（模块化）

## 安装说明

### 1. 复制硬件配置文件

将系统生成的硬件配置文件复制到当前目录：

```bash
sudo cp /etc/nixos/hardware-configuration.nix ./hardware-configuration.nix
```

或者如果还没有 `/etc/nixos/hardware-configuration.nix`，可以生成一个：

```bash
sudo nixos-generate-config --dir .
```

这会生成 `hardware-configuration.nix` 和 `configuration.nix`，你只需要保留 `hardware-configuration.nix`。

### 2. 修改 flake.nix 中的配置

编辑 `flake.nix`，修改以下变量以匹配你的系统：

```nix
let
  lib = nixpkgs.lib;
  configDir = ./modules;
  hostname = "nixos";        # ← 修改为你的主机名
  username = "naraiu";      # ← 修改为你的用户名
  system = "x86_64-linux";  # ← 修改为你的系统架构（x86_64-linux, aarch64-linux 等）
  stateVersion = "25.11";   # ← 修改为你的 NixOS 版本
```

**常见系统架构：**
- `x86_64-linux` - 64 位 x86 架构（Intel/AMD）
- `aarch64-linux` - ARM 64 位架构（如树莓派 4、Apple Silicon）
- `i686-linux` - 32 位 x86 架构（已较少使用）

### 3. 修改 configuration.nix 中的用户配置

编辑 `configuration.nix`，修改用户配置：

```nix
users.users.naraiu = {  # ← 修改为你的用户名（与 flake.nix 中的 username 一致）
  isNormalUser = true;
  extraGroups = [ "wheel" "networkmanager" ];
  # 如果需要设置初始密码，取消下面的注释并设置密码哈希
  # hashedPassword = "...";
};
```

**设置用户密码：**

```bash
# 生成密码哈希
mkpasswd -m sha-512

# 将生成的哈希值填入 configuration.nix 的 hashedPassword 字段
```

### 4. 修改 home/default.nix 中的用户名

编辑 `home/default.nix`，确保用户名与 `flake.nix` 中的一致（通常不需要修改，因为会自动传递）。

### 5. 首次应用配置

完成以上配置后，首次应用配置：

```bash
# 应用系统配置
sudo nixos-rebuild switch --flake .#nixos

# 应用 home-manager 配置
home-manager switch --flake .#naraiu  # 替换 naraiu 为你的用户名
```

### 注意事项

- **硬件配置**：`hardware-configuration.nix` 包含磁盘分区、文件系统等硬件特定信息，必须与你的系统匹配。
- **系统架构**：确保 `system` 变量正确，否则某些包可能无法安装（例如 Spotify 在 aarch64 上不可用）。
- **用户名一致性**：确保 `flake.nix`、`configuration.nix` 和 `home/default.nix` 中的用户名一致。
- **首次安装**：如果是全新安装，建议先使用 `nixos-rebuild test` 测试配置，确认无误后再使用 `switch`。

---

本仓库采用与 NixOS modules 类似的模块化方式管理 `home-manager` 配置：将每个功能拆分为 `home/modules/` 下的独立 `.nix` 模块，由 `flake.nix` 在构建时自动收集并注入到 `homeConfigurations` 中。

主要文件说明
- `flake.nix`: Flake 输出，自动读取 `modules/`（系统配置）和 `home/modules/`（home-manager 配置）下的模块并注入到对应的 `nixosConfigurations` 与 `homeConfigurations`。
- `home/default.nix`: home-manager 的主配置（用于设置可被覆盖的 `userSettings` 选项，例如是否启用 polkit）。
- `home/modules/`: 存放各项 home-manager 模块（例如 `git.nix`、`packages.nix`、`polkit.nix` 等）。

启用 / 禁用项
- Polkit：在 `home/default.nix` 中通过 `userSettings.polkit.enable` 控制。将其改为 `false` 可禁用 polkit 服务，改为 `true` 则启用。

如何添加新模块
1. 在 `home/modules/` 下新建一个 `.nix` 文件，遵循 module 形式（导出一个 attribute set，或使用 `options`/`config` 定义可配置选项）。
2. 在 `flake.nix` 中已经实现自动收集，无需手动修改 `flake.nix`。

## 常用命令

### 应用配置

#### 系统配置

**立即应用配置并切换（推荐）**
```bash
sudo nixos-rebuild switch --flake .#nixos
```
- 立即构建并应用配置
- 配置生效后不会重启系统
- 如果当前配置有问题，系统仍可正常使用

**下次启动时应用配置**
```bash
sudo nixos-rebuild boot --flake .#nixos
```
- 构建配置并设置为下次启动时使用
- 当前会话不受影响
- 适合在不确定配置是否稳定时使用
- 如果配置有问题，可以在启动时选择之前的配置

**测试配置但不应用**
```bash
sudo nixos-rebuild test --flake .#nixos
```
- 构建配置但不设置为默认
- 测试配置是否正确，不会影响当前系统

**构建配置但不应用**
```bash
sudo nixos-rebuild build --flake .#nixos
```
- 只构建配置，不应用
- 用于检查配置是否有语法错误

#### Home Manager 配置

**应用 home-manager 配置**
```bash
home-manager switch --flake .#naraiu
```
- 立即应用用户配置（替换 `naraiu` 为你的用户名）
- 不需要 sudo

**或者使用 flakes 风格**
```bash
nix build .#homeConfigurations.naraiu.activationPackage && ./result/activate
```

### 直接安装包（不修改配置文件）

有时候你可能想快速安装一个包进行测试，而不想修改配置文件。NixOS 提供了几种方式：

#### 方法 1：使用 nix profile install（推荐，永久安装到用户环境）

这是新的推荐方式，将包安装到用户环境，重启后仍然可用：

```bash
# 安装普通包
nix profile install nixpkgs#vim
nix profile install nixpkgs#git
nix profile install nixpkgs#htop

# 安装需要 unfree 许可的包（如 JetBrains IDEA）
NIXPKGS_ALLOW_UNFREE=1 nix profile install nixpkgs#jetbrains.idea-ultimate
# 或者使用简写
nix profile install nixpkgs#jetbrains.idea-ultimate --impure

# 查看已安装的包
nix profile list

# 卸载包
nix profile remove <profile-index>  # 使用 profile list 查看索引号
```

**优点：**
- 包会持久化，重启后仍然可用
- 可以管理多个版本
- 不会影响配置文件

**缺点：**
- 不会自动同步到配置文件
- 如果重新安装系统，这些包会丢失

#### 方法 2：使用 nix-shell（临时环境）

临时进入包含指定包的环境，退出后包不可用：

```bash
# 进入包含 vim 的临时环境
nix-shell -p vim

# 进入包含多个包的临时环境
nix-shell -p vim git htop

# 对于需要 unfree 许可的包
NIXPKGS_ALLOW_UNFREE=1 nix-shell -p jetbrains.idea-ultimate

# 直接运行命令（不进入 shell）
nix-shell -p vim --run "vim --version"
```

**优点：**
- 快速测试包
- 不会污染系统环境
- 适合一次性使用

**缺点：**
- 退出 shell 后包不可用
- 每次都需要重新进入

#### 方法 3：使用 nix run（临时运行）

直接运行包，不安装：

```bash
# 临时运行包
nix run nixpkgs#vim -- --version

# 运行需要 unfree 许可的包
NIXPKGS_ALLOW_UNFREE=1 nix run nixpkgs#jetbrains.idea-ultimate

# 使用简写（如果包名唯一）
nix run nixpkgs#htop
```

**优点：**
- 最快的方式，无需安装
- 适合偶尔使用的工具

**缺点：**
- 每次都需要重新下载（除非已在缓存中）
- 不能作为常规命令使用

#### 方法 4：使用 nix-env（传统方式，已弃用但仍可用）

```bash
# 安装包
nix-env -iA nixpkgs.vim

# 安装需要 unfree 许可的包
NIXPKGS_ALLOW_UNFREE=1 nix-env -iA nixpkgs.jetbrains.idea-ultimate

# 列出已安装的包
nix-env -q

# 卸载包
nix-env -e vim
```

**注意：** `nix-env` 已被弃用，推荐使用 `nix profile install`。

#### 常见开发工具安装示例

**JetBrains IDEA（需要 unfree 许可）**
```bash
# 方法 1：使用 nix profile（推荐）
NIXPKGS_ALLOW_UNFREE=1 nix profile install nixpkgs#jetbrains.idea-ultimate

# 方法 2：临时运行
NIXPKGS_ALLOW_UNFREE=1 nix run nixpkgs#jetbrains.idea-ultimate
```

**VS Code**
```bash
nix profile install nixpkgs#vscode
```

**Docker**
```bash
nix profile install nixpkgs#docker
```

**Node.js 和 npm**
```bash
nix profile install nixpkgs#nodejs_20
nix profile install nixpkgs#npm
```

**Python 和 pip**
```bash
nix profile install nixpkgs#python312
nix profile install nixpkgs#python312Packages.pip
```

#### 搜索包

在安装前，你可能需要先搜索包名：

```bash
# 搜索包
nix search nixpkgs vim

# 搜索 JetBrains 相关包
nix search nixpkgs jetbrains

# 查看包信息
nix show-derivation nixpkgs#vim
```

#### 注意事项

- **Unfree 许可**：某些包（如 JetBrains IDE、Steam 等）需要设置 `NIXPKGS_ALLOW_UNFREE=1` 环境变量或使用 `--impure` 标志
- **持久化**：使用 `nix profile install` 安装的包会持久化，但不会自动同步到配置文件
- **推荐做法**：测试后如果确定需要，建议将包添加到配置文件中，以便版本控制和系统重建

### 更新命令

**更新所有 flake 输入**
```bash
nix flake update
```
- 更新 `flake.nix` 中定义的所有输入到最新版本
- 会更新 `flake.lock` 文件

**更新特定输入**
```bash
nix flake update <input-name>
```
- 例如：`nix flake update nixpkgs`
- 只更新指定的输入

**更新并重新锁定 flake.lock**
```bash
nix flake lock --update-input <input-name>
```
- 更新指定输入并重新生成 lock 文件

### 更新特定包

**更新来自 flake 输入的包（如 dms-shell、noctalia、quickshell 等）**

这些包来自 `flake.nix` 中定义的 flake 输入，更新步骤如下：

**步骤 1：更新对应的 flake 输入**
```bash
# 更新 dms-shell
nix flake update dms

# 更新 noctalia shell
nix flake update noctalia

# 更新 quickshell
nix flake update quickshell

# 更新 AGS shell
nix flake update ags

# 更新 home-manager
nix flake update home-manager
```

**步骤 2：重新应用配置以使用新版本**
```bash
# 如果包是系统级安装（在 modules/shells.nix 中）
sudo nixos-rebuild switch --flake .#nixos

# 如果包是用户级安装（在 home/modules/ 中）
home-manager switch --flake .#naraiu  # 替换为你的用户名
```

**更新 nixpkgs 中的包（如 vim、git、firefox 等）**

这些包来自 nixpkgs，更新方式：

**步骤 1：更新 nixpkgs 输入**
```bash
nix flake update nixpkgs
```

**步骤 2：重新应用配置**
```bash
sudo nixos-rebuild switch --flake .#nixos
home-manager switch --flake .#naraiu
```

**查看包的当前版本和来源**

```bash
# 查看 flake 输入的状态
nix flake show

# 查看特定输入的提交信息
nix flake metadata <input-name>
# 例如：nix flake metadata dms
```

**示例：更新 dms-shell**

```bash
# 1. 更新 dms flake 输入
nix flake update dms

# 2. 重新应用 home-manager 配置（dms-shell 通过 home-manager 管理）
home-manager switch --flake .#naraiu

# 或者如果 dms-shell 是系统级安装
sudo nixos-rebuild switch --flake .#nixos
```

### 清理命令

**清理未使用的包**
```bash
sudo nix-collect-garbage
```
- 删除不再被引用的包
- 释放磁盘空间

**深度清理（删除所有旧代）**
```bash
sudo nix-collect-garbage -d
```
- 删除所有旧的配置代（保留当前）
- 更激进，释放更多空间

**优化存储**
```bash
sudo nix-store --optimise
```
- 通过硬链接相同文件来优化存储
- 减少磁盘使用

**查看磁盘使用情况**
```bash
nix-store --query --references /run/current-system | wc -l
```
- 查看当前系统引用的包数量

### 查询命令

**查看 flake 输出**
```bash
nix flake show
```
- 显示当前 flake 的所有输出

**查看可用配置**
```bash
nix flake show . | grep nixosConfigurations
```

**搜索包**
```bash
nix search nixpkgs <package-name>
```

**查看包信息**
```bash
nix-env -qaP <package-name>
```

### 故障排除

**查看构建日志**
```bash
sudo nixos-rebuild switch --flake .#nixos --show-trace
```
- 显示详细的构建错误信息

**回滚到上一个配置**
```bash
sudo nixos-rebuild switch --rollback
```
- 回滚到上一个工作的配置

**列出所有配置代**
```bash
nix-env --list-generations --profile /nix/var/nix/profiles/system
```
- 查看所有系统配置的历史

**切换到指定配置代**
```bash
sudo /nix/var/nix/profiles/system-<generation-number>/bin/switch-to-configuration switch
```
- 切换到指定的配置代（从上面的列表获取编号）

备注
- 将功能的实现放在 `home/modules/` 可以让配置更易维护和复用。
- 若想在模块中暴露开关（option），请使用 `options` 并通过 `lib.mkIf` 或 `lib.mkEnableOption` 控制模块行为（示例见 `home/modules/polkit.nix`）。
