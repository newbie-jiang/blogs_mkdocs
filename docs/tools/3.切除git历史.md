# 切除git历史

> **要彻底删除“最早的几次提交”，只保留最近的某次提交及之后的内容，历史的第一步变成你选定的那次提交。**

举例：

```
A -- B -- C -- D -- E (HEAD)
```

你想让仓库历史直接变成

```
       C -- D -- E (HEAD)
```

A、B 两次以及对应的所有文件彻底消失，**让C变成新的“历史起点”**。

------

## 这叫做**切除 Git 历史（剪裁历史）**

需要用 [`git filter-branch`](https://git-scm.com/docs/git-filter-branch)、[`git filter-repo`](https://github.com/newren/git-filter-repo) 或 BFG Repo-Cleaner 等**高级工具**来“丢弃所有历史，只保留从某个提交开始的新仓库”。

## 最简单做法（推荐方式：新仓库+filter-repo）



### 方案A：用 filter-repo 操作

#### 1. 找到想要作为新起点的 commit（如 C）

```
git log --oneline
# 记下你想保留的第一个 commit 哈希，比如 0123456
```

#### 2. 使用 filter-repo 裁剪历史

> 如果没装 filter-repo，先：`pip install git-filter-repo`

```
git filter-repo --force --refs 0123456..HEAD
```

> 这样就只保留从 0123456（**不包括**这个提交，如果要包括，加上 --include-refs）到当前的所有 commit，前面的历史全部删除。

#### 3. 强制推送覆盖远程

```
git push --force
```

------



### 方案B：手动导出当前内容并新建仓库

1. 新建一个空目录
2. 复制想保留的内容进去
3. 重新 git init，然后 add/commit/push





## 方案A具体命令举例

假如想让 `C`（假设哈希为 `abcdef1`）成为新历史的第一个提交：

```
pip install git-filter-repo  # 如未安装

# 只保留C及之后的提交（假设C是abcdef1）
git filter-repo --force --refs abcdef1..HEAD

# 强推
git push --force
```

**注意**：这种操作会**彻底改写整个仓库历史**，远程协作者pull会冲突，需要大家配合。



## 方案B：只保留当前最新一次的代码

如果你只是想“历史只留一条提交”，可以：

```
# 保存当前文件状态
git checkout HEAD .

# 清空所有历史，重新初始化
rm -rf .git
git init
git remote add origin https://github.com/yourname/yourrepo.git
git add .
git commit -m "新起点"
git push --force
```

这样历史就只剩你最新这一次。