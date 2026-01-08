# COSMIC 桌面环境模块化配置说明

## 概述

本文档说明如何在 NixOS 中使用 Flake 模块化配置 COSMIC 桌面环境。COSMIC 是基于 GNOME 的现代化桌面环境，由 System76 开发。

## 配置架构说明

### 1. Flake 输入（`flake.nix`）

在 `flake.nix` 中添加了 `nixos-cosmic` 输入：

```nix
nixos-cosmic = {
  url = "github:lilyinstarlight/nixos-cosmic";
  inputs.nixpkgs.follows = "nixpkgs";
};
```

**作用**：
- `nixos-cosmic` 是一个社区维护的 NixOS 模块集合，提供了 COSMIC 桌面环境的配置选项
- `inputs.nixpkgs.follows = "nixpkgs"` 确保使用相同的 nixpkgs 版本，避免依赖冲突

### 2. 模块注入（`flake.nix`）

在 `nixosSystem` 的 `modules` 列表中添加：

```nix
modules = [
  ./configuration.nix
  nixos-cosmic.nixosModules.default  # COSMIC 模块
] ++ generatedModules;
```

**作用**：
- `nixos-cosmic.nixosModules.default` 导入了 COSMIC 的所有配置选项
- 这样我们就可以在配置文件中使用 `services.desktopManager.cosmic.enable` 等选项

### 3. 模块化配置（`modules/cosmic.nix`）

创建了独立的 COSMIC 配置模块，遵循项目的模块化设计模式：

**模块结构**：
- **`options` 部分**：定义可配置选项
  - `systemSettings.cosmic.enable`：主开关
  - `systemSettings.cosmic.greeter.enable`：登录管理器开关
  - `systemSettings.cosmic.extraPackages`：额外包列表

- **`config` 部分**：实际配置实现
  - 使用 `lib.mkIf cfg.enable` 条件性地应用配置
  - 启用 X11/Wayland 服务器
  - 启用 COSMIC 桌面环境和登录管理器

**优势**：
- **模块化**：配置独立，易于维护和复用
- **可配置**：通过 `systemSettings` 统一管理开关
- **可扩展**：可以轻松添加更多选项（如主题、扩展等）

### 4. 主配置启用（`configuration.nix`）

在主配置文件中通过 `systemSettings` 启用：

```nix
systemSettings = {
  cosmic.enable = true;  # 启用 COSMIC
};
```

**为什么这样做**：
- 保持配置的一致性（与其他模块如 `firefox`、`vscode` 使用相同的模式）
- 集中管理所有功能的启用/禁用
- 易于理解和维护

## 配置流程详解

### 步骤 1：更新 Flake 输入

首次配置或更新依赖时，需要更新 Flake lock 文件：

```bash
nix flake update
```

或者只更新 COSMIC 输入：

```bash
nix flake update nixos-cosmic
```

### 步骤 2：应用配置

构建并应用配置：

```bash
sudo nixos-rebuild switch --flake .#nixos
```

### 步骤 3：重启或重新登录

配置应用后，需要：
- 重启系统，或
- 退出当前会话并重新登录

## 模块化设计的优势

### 1. **关注点分离**
- 每个模块只负责一个功能
- `cosmic.nix` 只包含 COSMIC 相关配置
- 主配置文件只负责启用/禁用功能

### 2. **易于维护**
- 修改 COSMIC 配置只需编辑 `modules/cosmic.nix`
- 不影响其他模块
- 配置变更清晰可见（通过 git diff）

### 3. **可复用性**
- 模块可以在不同主机配置间复用
- 可以轻松创建变体（如 `cosmic-minimal.nix`）

### 4. **自动发现**
- `flake.nix` 自动扫描 `modules/` 目录
- 新增模块自动被包含，无需手动修改 `flake.nix`

## 自定义配置示例

### 示例 1：禁用 COSMIC Greeter，使用 GDM

修改 `modules/cosmic.nix`：

```nix
config = lib.mkIf cfg.enable {
  services.xserver.enable = true;
  services.desktopManager.cosmic.enable = true;
  services.displayManager.cosmic-greeter.enable = false;
  services.displayManager.gdm.enable = true;  # 使用 GDM
  # ...
};
```

### 示例 2：添加额外的 COSMIC 相关包

在 `configuration.nix` 中：

```nix
systemSettings = {
  cosmic = {
    enable = true;
    extraPackages = with pkgs; [
      # 添加你需要的包
    ];
  };
};
```

### 示例 3：添加环境变量

在 `modules/cosmic.nix` 的 `config` 部分：

```nix
environment.variables = {
  XDG_CURRENT_DESKTOP = "COSMIC";
  # 其他环境变量
};
```

## 故障排除

### 问题 1：构建失败，提示找不到 `nixos-cosmic`

**解决**：
```bash
nix flake update
sudo nixos-rebuild switch --flake .#nixos
```

### 问题 2：登录后没有桌面环境

**检查**：
1. 确认 `systemSettings.cosmic.enable = true`
2. 检查 `modules/cosmic.nix` 是否正确加载
3. 查看日志：`journalctl -xe`

### 问题 3：想要回退到 GNOME

**方法**：
1. 在 `configuration.nix` 中设置 `systemSettings.cosmic.enable = false`
2. 取消注释 GNOME 配置
3. 重新构建

## 相关文件

- `flake.nix`：Flake 定义，包含输入和输出
- `configuration.nix`：主配置文件，启用各个模块
- `modules/cosmic.nix`：COSMIC 桌面环境的模块化配置
- `modules/`：所有系统级模块目录

## 参考资源

- [nixos-cosmic GitHub](https://github.com/lilyinstarlight/nixos-cosmic)
- [COSMIC 官网](https://cosmicde.org/)
- [NixOS 模块系统文档](https://nixos.org/manual/nixos/stable/#sec-writing-modules)

