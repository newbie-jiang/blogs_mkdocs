west boards 命令可查看支持的qumu有哪些

```
(.venv) hdj@hdj-virtual-machine:~/zephyrproject/zephyr$ west boards
```

![image-20250409152339012](https://newbie-typora.oss-cn-shenzhen.aliyuncs.com/zhongke/image-20250409152339012.png)



此处使用qemu_cortex_m3

构建 shell 示例

```
west build -b qemu_cortex_m3 samples/subsys/shell/shell_module -p
west build -b qemu_cortex_m3 samples/basic/minimal -p

```

运行

```
west build -t run
```

Tab键可查看当前的所有命令，tab键位 支持自动补全

![image-20250409152503046](https://newbie-typora.oss-cn-shenzhen.aliyuncs.com/zhongke/image-20250409152503046.png)





twister 自动化测试

```
west twister -T tests/subsys/shell -p qemu_cortex_m3 --enable-tests
```

