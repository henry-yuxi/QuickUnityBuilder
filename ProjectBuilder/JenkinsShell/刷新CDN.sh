#!/bin/sh

#½ÓÊÕ²ÎÊý
JP_BUILD_TARGET=$Build_Target
JP_UNITY_SERVER=$Unity_Server;

echo "--> ¼ì²â´ò°üÆ½Ì¨²ÎÊý" 
SUPPORT_TARGETS=("Android" "iOS" "Pc")
if echo "${SUPPORT_TARGETS[@]}" | grep -w $JP_BUILD_TARGET &>/dev/null; then
  echo "--> µ±Ç°´ò°üÆ½Ì¨²ÎÊý: ${JP_BUILD_TARGET}" 
else
  echo "Error : ²»Ö§³ÖµÄ´ò°üÆ½Ì¨²ÎÊý : ${JP_BUILD_TARGET}"
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

echo "--> ¿ªÊ¼Ë¢ÐÂCDN" 
python ${PROJ_BUILDER_TOOL_PATH}/Qcloud_CDN_API/QcloudCdnTools_V2.py RefreshCdnDir -u AKIDCCzXq6L0f5GG1XNrlcP3ShgPs52koNIx -p ZtxlIfnfHdjY7QTFl4A2e2B4g27wf8LI --dirs 地址/${JP_UNITY_SERVER}/${REMOTE_TARGET_NAME}/
if [ $? = 0 ];then
  echo "--> CDNË¢ÐÂ³É¹¦ "
else
  echo "--> Error : CDNË¢ÐÂÊ§°Ü "
fi