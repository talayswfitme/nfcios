# PoscatNfc iOS 原生插件

本仓库使用 GitHub Actions 的 macOS 云主机编译 `PoscatNfc.framework`，不需要本机 Mac。

## 触发构建

将仓库文件推送到 GitHub 后，打开 **Actions → Build PoscatNfc framework → Run workflow**。构建完成后，在工作流页面底部 **Artifacts** 下载 `PoscatNfc-framework.zip`。

## 安装到 uni-app

解压后把 `PoscatNfc.framework` 整个目录放入：

```text
poscatuniapp/nativeplugins/PoscatNfc/ios/
```

然后确认 `package.json` 和 framework 位于同一个插件目录，回到 HBuilderX 保存 manifest，制作 iOS 自定义基座或云打包。

## 重要说明

GitHub Actions 只能编译 framework，不能替代 Apple 签名和 HBuilderX 打包。最终必须在 HBuilderX 中制作自定义基座，并安装到支持 NFC 的 iPhone 真机。
