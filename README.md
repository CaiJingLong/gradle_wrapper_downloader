# 一个命令行工具

初衷，Gradle 不知道从什么时候开始，将 gradle wrapper 迁移到了 github 上，但是国内访问 github 速度很慢，所以我写了这个工具，通过代理帮你下载 gradle wrapper。

如果你会自行配置代理且能找到正确的位置，那么你**不需要**这个工具。

此工具原理，通过搜索你项目中的 `gradle-wrapper.properties` 文件，找到 `distributionUrl`，然后下载对应的 gradle 版本到对应的目录内。

## 安全性问题

下载后的 gradle zip 文件，会被放置在 `~/.gradle/wrapper/dists` 对应的版本目录下，这个目录是 gradle wrapper 默认的下载目录，如果你不放心，可以自行校验。

此工具仅做下载 zip，不做解压 zip 和创建 `.lck` `.ok` 文件，解压由 gradle wrapper 自行完成。

## 代理方案

- [x] 使用 [ghproxy][] 代理，这个代理是三方提供的，速度还可以，但是本人不保证它的永久可用，且不保证它的安全性，请根据日志路径自行校验 gradle zip 是否被篡改。
- [x] 使用环境变量 http_proxy 来指定代理，这种方式的下载速度取决于你的节点速度。
- [x] 使用 [腾讯云镜像][tencent]，这个镜像是腾讯提供的，自行校验安全性。

## 使用方法

### 安装

用 pub global 安装或直接从 release 中下载二进制文件。

```bash
dart pub global activate gradle_wrapper
```

这里是否可以直接使用 gradle_wrapper 取决于你是否将 pub global 的 bin 目录加入到了 PATH 环境变量中。

### 查看帮助

可以查看命令的使用参数之类的东西

```bash
gradle_wrapper -h

# or

dart pub global run gradle_wrapper:gradle_wrapper -h
```

### 用 ghproxy 下载

```bash
gradle_wrapper g -d <your project path>

# or

dart pub global run gradle_wrapper:gradle_wrapper g -d <your project path>
```

### 使用自己的代理

```bash
export http_proxy=http://localhost:7890

gradle_wrapper p -d <your project path>

dart pub global run gradle_wrapper:gradle_wrapper p -d <your project path>
```

## 其他问题

- 请**不要**直接使用 flutter 项目根目录，而**要** android 目录，因为 iOS 会软链接所有 packages，导致找到很多不同的 `gradle-wrapper.properties` 文件，此工具会自动下载所有的。

[ghproxy]: https://mirror.ghproxy.com/
[tencent]: https://mirrors.cloud.tencent.com/gradle/
