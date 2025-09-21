发现在更新时候，github pages的自定义域名会失效

## 详细原因

- **GitHub Pages 绑定自定义域名时，会在仓库的发布目录（比如 gh-pages 分支或 publish_dir 目录）下自动生成一个 `CNAME` 文件。**
- 只要 `CNAME` 文件被删除、覆盖、没同步，或者你重新部署时没包含它，GitHub Pages 的自定义域名就会失效（变成空或者你的 .github.io 域名）。
- 使用 Actions 自动部署时，**如果你只部署 `blogs` 目录，而没有在 `blogs` 目录下包含 `CNAME` 文件**，每次新构建后，GitHub Pages 都会把域名设回默认。

## 解决办法

### 1. **确保每次部署时都包含 `CNAME` 文件在 publish_dir 目录下（如 blogs/）**

- **做法1：仓库根目录下有 `CNAME` 文件，自动被带入部署目录。**
- **做法2：在自动化脚本（如 2.process_html.py）里自动生成 `blogs/CNAME` 文件，内容就是你的域名，比如 `blogs.hedejiang.top`。**
- **做法3：在 Actions workflow 里专门加一步写入 CNAME 文件：**

```
- name: 写入 CNAME 文件
  run: echo 'blogs.hedejiang.top' > blogs/CNAME
```



完整yaml

```yaml
name: Build & Deploy GitHub Pages

on:
  push:
    branches: [ master ]
  workflow_dispatch:

jobs:
  build-and-deploy:
    runs-on: ubuntu-latest

    steps:
      - name: 检出仓库
        uses: actions/checkout@v4

      - name: 设置 Python 环境
        uses: actions/setup-python@v5
        with:
          python-version: '3.11'

      - name: 安装依赖
        run: |
          pip install markdown

      - name: 清理所有 html 文件
        run: python delete_html_files.py

      - name: 执行 Markdown 转 HTML
        run: python 1.md_2_html.py

      - name: 生成主页
        run: python 2.process_html.py

      - name: 写入 CNAME 文件
        run: echo 'blogs.hedejiang.top' > blogs/CNAME

      - name: 部署到 GitHub Pages
        uses: peaceiris/actions-gh-pages@v4
        with:
          github_token: ${{ secrets.GITHUB_TOKEN }}
          publish_dir: ./blogs
```

