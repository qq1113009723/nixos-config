NixOS + Home Manager 配置（模块化）

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
