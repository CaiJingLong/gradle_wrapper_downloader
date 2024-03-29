# 一个命令行工具

初衷，Gradle 不知道从什么时候开始，将 gradle wrapper 迁移到了 github 上，但是国内访问 github 速度很慢，所以我写了这个工具，通过代理帮你下载 gradle wrapper。

如果你会自行配置代理且能找到正确的位置，那么你**不需要**这个工具。
或者，你的项目使用的是你自己搭设站点镜像的 Gradle wrapper，那么你可以直接修改项目的 url。
此项目适用于一些你无权修改 `gradle-wrapper.properties` 的项目，包括三方开源项目、公司项目等。

此工具原理，通过递归搜索你项目中的 `gradle-wrapper.properties` 文件，找到 `distributionUrl` 属性，然后下载 gradle 版本到对应的目录内。

这里的目录寻找逻辑是移植 gradle wrapper 官方寻找 Gradle Home 的逻辑，路径中那个乱码其实是 distributionUrl 属性对应的 md5 + base36。
所以如果你直接修改 distributionUrl 后哪怕是原始文件完全一样也无法覆盖，所以只能用镜像的方式来做。

## 安全性问题

下载后的 gradle zip 文件，会被放置在 `~/.gradle/wrapper/dists` 对应的版本目录下，这个目录是 gradle wrapper 默认的下载目录，如果你不放心，可以自行校验。

此工具仅做下载 zip，不做解压 zip 和创建 `.lck` `.ok` 文件，解压由 gradle wrapper 自行完成。

## 代理方案

- [x] 使用 [ghproxy][] 代理，这个代理是三方提供的，速度还可以，但是本人不保证它的永久可用，且不保证它的安全性，请根据日志路径自行校验 gradle zip 是否被篡改。
- [x] 使用环境变量 http_proxy 来指定代理，这种方式的下载速度取决于你的节点速度。
- [x] 使用 [腾讯云镜像][tencent]，这个镜像是腾讯提供的，自行校验安全性。

## 使用方法

### 安装

#### 使用 dart

用 pub global 安装或直接从 release 中下载二进制文件。

```bash
dart pub global activate gradle_wrapper
```

这里是否可以直接使用 gradle_wrapper 取决于你是否将 pub global 的 bin 目录加入到了 PATH 环境变量中。

#### Release 下载

从 release 中下载二进制文件，然后将其放入 PATH 环境变量中。

```sh
curl https://raw.githubusercontent.com/CaiJingLong/gradle_wrapper_downloader/main/tool/install-sh.sh | sh

# 国内有的地方访问困难，也可以使用 ghproxy
curl https://mirror.ghproxy.com/https://raw.githubusercontent.com/CaiJingLong/gradle_wrapper_downloader/main/tool/install-sh.sh | sh
```

### 查看帮助

可以查看命令的使用参数之类的东西

```bash
gradle_wrapper -h

# or

dart pub global run gradle_wrapper:gradle_wrapper -h
```

### 使用腾讯代理

比较推荐这个方式，虽然腾讯肯定有大厂的傲慢，但是节点速度来说很优质

```bash
gradle_wrapper t -d <your project path>

# or

dart pub global run gradle_wrapper:gradle_wrapper t -d <your project path>
```

### 用 ghproxy 下载

三方镜像，基本上能代理各种各样的 github 资源，这里利用的是它代理 github release 的能力

```bash
gradle_wrapper g -d <your project path>

# or

dart pub global run gradle_wrapper:gradle_wrapper g -d <your project path>
```


### 使用自己的代理

这个就是纯粹的 http 代理了，取决于你自己的节点速度

```bash
export http_proxy=http://localhost:7890

gradle_wrapper p -d <your project path>

dart pub global run gradle_wrapper:gradle_wrapper p -d <your project path>
```

## 其他问题

- 这是一个通用的 gradle 工具，不是仅适用于 flutter 项目，只要你使用 gradle wrapper 就可以用这东西。
- 请**不要**直接使用 flutter 项目根目录，而**要** android 目录，因为 iOS 会软链接所有 packages，导致找到很多不同的 `gradle-wrapper.properties` 文件，此工具会自动下载所有的。

[ghproxy]: https://mirror.ghproxy.com/
[tencent]: https://mirrors.cloud.tencent.com/gradle/
