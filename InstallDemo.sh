#/bin/bash
#FileName:ProjectInit.sh
rm -rf node_modules &&  rm -rf Pods && rm -rf Podfile.lock && npm install &&pod install --no-repo-update --verbose
echo -e "\033[37;31;5m初始化IMSDK-Demo成功后的项目列表为：  \033[39;49;0m"
ls -al -sh
