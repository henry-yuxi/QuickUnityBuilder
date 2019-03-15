#!/bin/sh

#接收参数
JP_BUILD_TARGET=$Build_Target
JP_UNITY_SERVER=$Unity_Server;

echo "--> 检测打包平台参数" 
SUPPORT_TARGETS=("Android" "iOS" "Pc")
if echo "${SUPPORT_TARGETS[@]}" | grep -w $JP_BUILD_TARGET &>/dev/null; then
  echo "--> 当前打包平台参数: ${JP_BUILD_TARGET}" 
else
  echo "Error : 不支持的打包平台参数 : ${JP_BUILD_TARGET}"
  exit 1
fi

if [[ $JP_BUILD_TARGET = "Android" ]]; then
  REMOTE_TARGET_NAME="ANDROID"
elif [[ $JP_BUILD_TARGET = "iOS" ]]; then
  REMOTE_TARGET_NAME="IOS"  
elif [[ $JP_BUILD_TARGET = "Pc" ]]; then
  REMOTE_TARGET_NAME="PC" 
fi

PROJ_GIT_PATH="/Users/mac2144/Documents/YLProjects/yl_official_android/ylqtclient"
PROJ_BUILDER_ROOT_PATH="${PROJ_GIT_PATH}/ProjectBuilder"
PROJ_BUILDER_TOOL_PATH="${PROJ_BUILDER_ROOT_PATH}/PackTools"

echo "--> 开始刷新CDN" 
python ${PROJ_BUILDER_TOOL_PATH}/Qcloud_CDN_API/QcloudCdnTools_V2.py RefreshCdnDir -u AKIDCCzXq6L0f5GG1XNrlcP3ShgPs52koNIx -p ZtxlIfnfHdjY7QTFl4A2e2B4g27wf8LI --dirs http://res.ylqt.2144gy.com/${JP_UNITY_SERVER}/${REMOTE_TARGET_NAME}/
if [ $? = 0 ];then
  echo "--> CDN刷新成功 "
else
  echo "--> Error : CDN刷新失败 "
fi