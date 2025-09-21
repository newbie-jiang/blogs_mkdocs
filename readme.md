

# mkdocs on github pages 



## 前置：在本地创建 MkDocs + Material 站点

```
# 建议用虚拟环境，但不是必须
pip install --upgrade pip
pip install mkdocs mkdocs-material

mkdocs new interview-site
cd interview-site
```

编辑 `mkdocs.yml`（最小可用示例，已启用 material）：

```
site_name: 面试资料站
theme:
  name: material
  language: zh
nav:
  - 首页: index.md
```

本地预览：

```
mkdocs serve   # 浏览器打开 http://127.0.0.1:8000
```



# GitHub Actions 自动构建&部署（推荐）

1. 提交一个工作流文件 **.github/workflows/gh-pages.yml**：

```
name: Deploy MkDocs (Material) to GitHub Pages

on:
  push:
    branches: [ master ]
  workflow_dispatch:

permissions:
  contents: write
  pages: write
  id-token: write

jobs:
  build-deploy:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout
        uses: actions/checkout@v4

      - name: Setup Python
        uses: actions/setup-python@v5
        with:
          python-version: '3.x'

      - name: Install deps
        run: |
          python -m pip install --upgrade pip
          pip install mkdocs mkdocs-material
          # 若有插件：pip install mkdocs-minify-plugin mkdocs-git-revision-date-localized-plugin

      - name: Build
        run: mkdocs build --strict

      - name: Deploy
        uses: peaceiris/actions-gh-pages@v4
        with:
          github_token: ${{ secrets.GITHUB_TOKEN }}
          publish_dir: ./site
          # cname: your.domain.com  # 自定义域名就取消注释
```

1. 推到 GitHub：

```
git add .
git commit -m "add gh-pages workflow"
git push
```

1. 首次：GitHub → **Actions** 看工作流成功；
    然后到 **Settings → Pages**，选择 `gh-pages` / **(root)**（有时已自动设置）。

访问：`https://<你的用户名>.github.io/<仓库名>/`

------

## 可选增强

- **requirements.txt**（让 CI 与本地依赖一致）
   新建 `requirements.txt`：

  ```
  mkdocs
  mkdocs-material
  ```

  然后把工作流中的安装命令改为：

  ```
  pip install -r requirements.txt
  ```

- **项目页 vs 用户页**

  - 项目页（常用）：`https://<user>.github.io/<repo>/`（上面的流程就是这个）
  - 用户页：建仓库 `<user>.github.io`，同样部署到 `gh-pages` 根目录即可。

- **自定义域名**
   在 DNS 配置好 CNAME 解析到 `<user>.github.io`，工作流或 `gh-deploy` 写入 `cname:` 或 `--cname`。