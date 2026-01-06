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

应用配置
- 更新 NixOS 系统配置（在仓库根目录运行）：

```bash
sudo nixos-rebuild switch --flake .#nixos
```

- 应用 home-manager 配置（替换为你的用户名条目，例如 `naraiu`）：

```bash
home-manager switch --flake .#naraiu
```

（或者使用 flakes 风格的构建/运行：`nix build .#homeConfigurations.naraiu.activationPackage && ./result/activate`）

备注
- 将功能的实现放在 `home/modules/` 可以让配置更易维护和复用。
- 若想在模块中暴露开关（option），请使用 `options` 并通过 `lib.mkIf` 或 `lib.mkEnableOption` 控制模块行为（示例见 `home/modules/polkit.nix`）。
