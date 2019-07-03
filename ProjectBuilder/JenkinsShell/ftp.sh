#!/bin/sh

#½ÓÊÕJenkins¿ÉÊÓ»¯²å¼þµÄ²ÎÊý
BUILD_TARGET=$Build_Target
UNITY_CHANNEL=$Unity_Channel;
UPLOAD_BUNDLES=$Upload_Bundles

if [[ $BUILD_TARGET = "Android" ]]; then
  PROJ_GIT_PATH="/Users/mac2144/Documents/ylclient_android_resbranch/ylclient"
  BUILD_TARGET_PATH="Android"
elif  [[ $BUILD_TARGET = "iOS" ]]; then
  PROJ_GIT_PATH="/Users/mac2144/Documents/ylclient_ios_resbranch/ylclient"
  BUILD_TARGET_PATH="IOS"
else 
  echo "Log Error : ´íÎóµÄ´ò°üÆ½Ì¨²ÎÊý : ${BUILD_TARGET}"
    exit 1
fi

if  [[ $UPLOAD_BUNDLES = "true" ]]; then

LOCAL_PATH=${PROJ_GIT_PATH}/AssetsBundle/${UNITY_CHANNEL}/${BUILD_TARGET_PATH}/Uploads
REMOTE_PATH=./${UNITY_CHANNEL}/${BUILD_TARGET_PATH}/

echo "--> Set LOCAL_PATH  : ${LOCAL_PATH}" 
echo "--> Set REMOTE_PATH : ${REMOTE_PATH}" 

if [ ! -d $LOCAL_PATH ];then
  echo "Log Error : ±¾µØÃ»ÓÐÐèÒªÉÏ´«µÄ×ÊÔ´Ä¿Â¼ : ${LOCAL_PATH}"
    exit 1
fi

lftp -u 用户名,密码 -p 端口号 地址 <<EOF
cd ${REMOTE_PATH}
lcd ${LOCAL_PATH}
ls
mirror -R ${LOCAL_PATH}
exit
EOF

if [ $? = 0 ];then
   echo "--> ÉÏ´«${BUILD_TARGET} Bundles³É¹¦ "
else
   echo "--> ÉÏ´«${BUILD_TARGET} BundlesÊ§°Ü "
fi

fi

