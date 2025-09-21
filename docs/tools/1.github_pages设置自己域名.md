

## 1. **打开GitHub 仓库页面**

比如：`https://github.com/yourusername/yourrepo`

------

## 2. **进入 Settings → Pages 配置页**

- 进入仓库右上角 `Settings`
- 左侧菜单找到 `Pages`（有时在 "Code and automation" 下）

------

## 3. **找到 “Custom domain” 或 “自定义域名” 设置框**

- 在 `GitHub Pages` 配置区，**“Custom domain”** 输入框中填入想绑定的域名，比如 `blog.yourdomain.com`
- 输入后点击 `Save`

## 4. **在你的域名服务商后台配置 DNS 解析**

- 如果是**根域名（如 example.com）**，一般需要添加一条 `A` 记录，指向 GitHub 的 IP（推荐使用 CNAME，除非 CNAME 只支持二级域名）。

- **二级域名（如 blog.example.com）**，添加一条 CNAME 记录，指向你的 GitHub Pages 地址：

  | 记录类型 | 主机名（Name） | 值（Value/目标）       |
  | -------- | -------------- | ---------------------- |
  | CNAME    | blog           | yourusername.github.io |



比如

我在github设置为   blogs.hedejiang.top

在cloudflare 设置如下

![image-20250704233733524](https://newbie-typora.oss-cn-shenzhen.aliyuncs.com/TyporaJPG/image-20250704233733524.png)