# 多角色系统 (Multicharacter)

## 简介
这是一个为 FiveM 开发的多角色系统，允许玩家在同一个服务器上创建和管理多个角色。系统支持 ESX、QBCore 和 QBX 框架。

## 功能特点
- 支持多个角色创建和管理
- 可自定义每个玩家的最大角色数量
- 角色预览和选择界面
- 兼容 ESX、QBCore 和 QBX 框架

## 依赖项
- [es_extended](https://github.com/esx-framework/esx-legacy) 或 [qb-core](https://github.com/qbcore-framework/qb-core) 或 [qbx_core](https://github.com/Qbox-project/qbx_core)
- [ox_lib](https://github.com/overextended/ox_lib)
- [oxmysql](https://github.com/overextended/oxmysql)

## 安装方法
1. 前往此仓库的 [Releases](https://github.com/oliann97/multicharacter/releases) 页面
2. 下载最新版本的压缩包
3. 解压文件，将 `multicharacter` 文件夹放入您的服务器 `resources` 目录
4. 确保已安装所有依赖项
5. 在 `server.cfg` 中添加以下内容：
```
ensure multicharacter
```

## 配置说明
配置文件位于 `shared/config.lua`，可以根据需要进行修改：

### 主要配置选项
- `loadingModelsTimeout`: 加载模型的超时时间（毫秒）
- `DeleteCharacter`: 是否允许删除角色
- `defaultNumberOfCharacters`: 默认允许的角色数量
- `playersNumberOfCharacters`: 特定玩家的角色数量配置
- `starterItems`: 新角色的起始物品
- `characters.locations`: 角色选择界面的位置配置
- `defaultSpawn`: 默认出生点坐标

### 示例配置
```lua
return {
    loadingModelsTimeout = 10000,
    DeleteCharacter = false,
    playersNumberOfCharacters = { 
        ['license2:xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'] = 6,
    },
    starterItems = { 
        { name = 'phone', amount = 1 },
    },
    defaultNumberOfCharacters = 2,
    characters = {
        locations = { 
            {
                pedCoords = vec4(-284.2856, 562.4627, 172.9182, 19.9895),
                camCoords = vec4(-284.7856, 565.4627, 174.0182, 199.9895),
            }
        },
    },
    defaultSpawn = vec4(-540.58, -212.02, 37.65, 208.88),
}
```
