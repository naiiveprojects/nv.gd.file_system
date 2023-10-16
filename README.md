# <img src="./assetlib/icon.svg" width="32" height="32"> nv file system

➡️ [**for Godot Engine 3.x**](https://github.com/naiiveprojects/nv.gd.file_system/tree/3.x) | ✅ **for Godot Engine 4.x**

Allow Editor FileSystem to dock at the bottom panel, similar to the layout found in Unreal Engine / Unity.

## Screenshots

![editor_full](/assetlib/editor_full.png)

## Installation

### Using the Asset Library

- Open the Godot editor.
- Navigate to the **AssetLib** tab at the top of the editor and search for
  "NV File System".
- Install the
  [*NV File System*](https://godotengine.org/asset-library/asset/2228)
  plugin. Keep all files checked during installation.
- In the editor, open **Project > Project Settings**, go to **Plugins**
  and enable the **NV FIle System** plugin.

### Manual installation

Manual installation lets you use pre-release versions of this add-on by
following its `4.x` branch.

- Clone this Git repository:

```bash
git clone https://github.com/naiiveprojects/nv.gd.file_system/tree/4.x.git
```

Alternatively, you can
[download a ZIP archive](https://github.com/naiiveprojects/nv.gd.file_system/archive/refs/heads/4.x.zip)
if you do not have Git installed.

- Move the `addons/` folder to your project folder.
- In the editor, open **Project > Project Settings**, go to **Plugins**
  and enable the **NV File System** plugin.

## Usage

- switch between the standard location and the bottom dock by navigating to `Projects > Tools > File System > Switch File System Dock`
  - ![menu_item](/assetlib/menu_item.png)
- Alternatively, you can use the default shortcut `Alt + S` to toggle the dock location.
- to customize the shortcut, you can modify the script in `addons/nv.file_system/nv.file_system.gd`
  - ![menu_item](/assetlib/script_shortcut.png)

## License

Copyright © 2023 NAIIVE and contributors

Unless otherwise specified, files in this repository are licensed under the
MIT license. See [LICENSE](LICENSE) for more information.
