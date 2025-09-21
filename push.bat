@echo off
chcp 65001 >nul

git add .
git commit -m "update"
git push -u origin master

pause
