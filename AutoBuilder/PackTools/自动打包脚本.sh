#!/bin/sh

#插件配置的参数:
#Build_Target              Unity构建平台选项
#Build_Method            Unity的构建方法
#Bundles_Version        Unity构建的AB版本
#Unity_Channel           Unity构建渠道选项
#Development_Build 
#Git_Operate               分支处理选项    Clean 清理当前分支 Stash 缓存当前分支
#Git_Branch                 Git分支选项

#Fir_Token                   第三方托管平台Fir账号选项
#Upload_Bundles        是否上传资源包
#Upload_Fir                 是否上传第三方托管平台
#Upload_Bugly            是否上传符号表
#Write_Macro              需要写入的宏
#Publish_Mode            IOS发布模式选项

echo "--> Get Jenkins Params"

#接收参数
BUILD_TARGET=$Build_Target
BUILD_METHOD=$Build_Method
GIT_OPERATE=$Git_Operate
GIT_BRANCH=$Git_Branch
UNITY_CHANNEL=$Unity_Channel;
BUNDLES_VERSION=$Bundles_Version;
DEVELOPMENT_BUILD=$Development_Build;
FIR_TOKEN=$Fir_Token
UPLOAD_FIR=$Upload_Fir
UPLOAD_BUGLY=$Upload_Bugly
UPLOAD_BUNDLES=$Upload_Bundles

#参数非空判断
if [[ ! $BUILD_TARGET || ! $BUILD_METHOD || ! $GIT_OPERATE || ! $GIT_BRANCH || ! $UNITY_CHANNEL || ! $BUNDLES_VERSION || ! $DEVELOPMENT_BUILD ]]; then
  echo "--> Error : Jenkins插件配置的参数有误, 至少有一项为空, 请检查"
    exit 1
fi

echo "--> Set Params"

#设置项目参数
UNITY_PATH="/Applications/Unity/Unity.app/Contents/MacOS/Unity"
BUILD_TIME="`date +%Y%m%d_%H%M`"

if [[ $BUILD_TARGET = "Android" ]]; then
  REMOTE_BUILD_TARGET_NAME="ANDROID"
  PACK_NAME="Android Apk: ";
  PROJ_GIT_PATH="/Users/mac2144/Documents/ylclient_android/ylclient"
  PROJ_PATH="${PROJ_GIT_PATH}/YL"
  BUILD_FILE_NAME="Unity_Android_${UNITY_CHANNEL}_${BUILD_TIME}.apk"
  BUILD_PATH="${PROJ_GIT_PATH}/AutoBuilder/Android/"
  BUILD_LOG_PATH="${PROJ_GIT_PATH}/AutoBuilder/Android/build.log"
  if [[ $BUILD_METHOD = "BuildBundles" ]]; then
    UNITY3D_BUILD_METHOD="JenkinsBuilder.JenkinsBuildAndroidBundles"
  elif  [[ $BUILD_METHOD = "BuildPackage" ]]; then
    UNITY3D_BUILD_METHOD="JenkinsBuilder.JenkinsBuildAndroid"
  else
    UNITY3D_BUILD_METHOD="JenkinsBuilder.JenkinsOnekeyBuildAndroid"
  fi
elif  [[ $BUILD_TARGET = "iOS" ]]; then
  REMOTE_BUILD_TARGET_NAME="IOS"
  PACK_NAME="Xcode Project: ";
  PROJ_GIT_PATH="/Users/mac2144/Documents/ylclient_ios/ylclient"
  PROJ_PATH="${PROJ_GIT_PATH}/YL"
  BUILD_FILE_NAME="Unity_iPhone_${UNITY_CHANNEL}"
  BUILD_PATH="${PROJ_GIT_PATH}/AutoBuilder/IOS"
  BUILD_LOG_PATH="${PROJ_GIT_PATH}/AutoBuilder/IOS/build.log"
  if [[ $BUILD_METHOD = "BuildBundles" ]]; then
    UNITY3D_BUILD_METHOD="JenkinsBuilder.JenkinsBuildIOSBundles"
  elif  [[ $BUILD_METHOD = "BuildPackage" ]]; then
    UNITY3D_BUILD_METHOD="JenkinsBuilder.JenkinsBuildIOS"
  else
    UNITY3D_BUILD_METHOD="JenkinsBuilder.JenkinsOnekeyBuildIOS"
  fi
else 
  echo "Log Error : 错误的打包平台参数 : ${BUILD_TARGET}"
    exit 1
fi

BUILD_TOOL_PATH="${PROJ_GIT_PATH}/AutoBuilder/PackTools"

echo "--> Set BUILD_TOOL_PATH : ${BUILD_TOOL_PATH}" 
echo "--> Set PROJ_GIT_PATH : ${PROJ_GIT_PATH}" 
echo "--> Set PROJ_PATH : ${PROJ_PATH}" 
echo "--> Set BUILD_FILE_NAME : ${BUILD_FILE_NAME}" 
echo "--> Set BUILD_PATH : ${BUILD_PATH}" 
echo "--> Set BUILD_LOG_PATH : ${BUILD_LOG_PATH}" 
echo "--> Set UNITY3D_BUILD_METHOD : ${UNITY3D_BUILD_METHOD}" 

echo "--> 切换目录到 ${PROJ_GIT_PATH}"
cd ${PROJ_GIT_PATH}

if [[ $GIT_OPERATE = "Stash" ]]; then
  echo "--> 缓存当前分支"
  git fetch
  git stash save "自动打包 本地缓存 _${BUILD_TIME}"
elif  [[ $GIT_OPERATE = "Clean" ]]; then
echo "--> 清理当前分支"
  git fetch
  git reset --hard
  git clean -df
  if [ $? -ne 0 ];then
    echo "--> Error : Clean ${PROJ_GIT_PATH}"
    exit 1
  fi
else 
  echo "--> Error : GIT_OPERATE Param : ${GIT_OPERATE}"
    exit 1
fi

echo "--> 切换目录到分支 ${GIT_BRANCH}"
git checkout -B ${GIT_BRANCH} --track origin/${GIT_BRANCH}
git pull

if [ $? -ne 0 ];then
    echo "--> Error : Checkout ${GIT_BRANCH}"
    exit 1
fi

#如果日志文件已存在 删除日志文件
if [[ -f $BUILD_LOG_PATH ]]; then
  rm -f $BUILD_LOG_PATH
fi

#UNITY3D_REFRESH_METHOD="JenkinsBuilder.Refresh"
#echo 刷新Unity工程
#$UNITY_PATH -quit -batchmode -nographics -projectPath $PROJ_PATH -executeMethod ${UNITY3D_REFRESH_METHOD} 

echo "--> 执行Unity的打包方法"
$UNITY_PATH -quit -batchmode -nographics -projectPath $PROJ_PATH -executeMethod ${UNITY3D_BUILD_METHOD}  Bundles_Version-$BUNDLES_VERSION Unity_Channel-$UNITY_CHANNEL Development_Build-$DEVELOPMENT_BUILD Build_Path-$BUILD_PATH Build_FileName-$BUILD_FILE_NAME -logFile $BUILD_LOG_PATH


if [[ $BUILD_METHOD = "BuildPackage" || $BUILD_METHOD = "BuildBundlesAndPackage" ]]; then
if  [[ $BUILD_TARGET = "Android" ]]; then
	if [ -f "$BUILD_PATH/$BUILD_FILE_NAME" ] ; then
      echo "--> ${PACK_NAME}${BUILD_FILE_NAME} 生成成功 "
    else
      echo "--> ${PACK_NAME}${BUILD_FILE_NAME} 生成失败, Error building Player because scripts had compiler errors "
	  echo `cat ${BUILD_LOG_PATH}`
        exit 1
    fi
elif  [[ $BUILD_TARGET = "iOS" ]]; then
	if [ -d "$BUILD_PATH/$BUILD_FILE_NAME" ] ; then
      echo "--> ${PACK_NAME}${BUILD_FILE_NAME} 生成成功 "
    else
      echo "--> ${PACK_NAME}${BUILD_FILE_NAME} 生成失败, Error building Player because scripts had compiler errors "
	  echo `cat ${BUILD_LOG_PATH}`
        exit 1
    fi
else 
  echo "--> Error : 错误的打包平台参数 : ${BUILD_TARGET}"
    exit 1
fi
fi

#Xcode打包处理
if  [[ $BUILD_TARGET = "iOS" ]]; then
  if [[ $BUILD_METHOD = "BuildPackage" || $BUILD_METHOD = "BuildBundlesAndPackage" ]]; then
	
	#Xcode路径相关参数
    CONFIGURATION=Release
    SCHEME="Unity-iPhone"
    IPA_OUTPUT_PATH="${BUILD_PATH}/IPA_Output"
    XCODE_PROJ_PATH="${BUILD_PATH}/${BUILD_FILE_NAME}/${SCHEME}.xcodeproj"
    ARCHIVE_PATH="${IPA_OUTPUT_PATH}/${BUILD_FILE_NAME}/${SCHEME}.xcarchive"
    EXPORT_PATH="${IPA_OUTPUT_PATH}/${BUILD_FILE_NAME}"

    if [ ! -d $IPA_OUTPUT_PATH ];then
      mkdir $IPA_OUTPUT_PATH
    fi

	#Xcode打包必需参数
	CODE_SIGN_IDENTITY="iPhone Distribution: Shanghai Blademaster Network Technology Co., Ltd."
    PROVISIONING_PROFILE_NAME="ylqt_inhouse"
    EXPORT_OPTION_PLIST=${BUILD_TOOL_PATH}/ExportOptions/exportOptionsPlist.plist
    BUNDLE_IDENTIFIER=com.baiyao.ylqt
	#(K8EN9Z764W)
	# 对于ssh连上mac的终端,签名的时候会提示：User interaction is not allowed.
    # 所以要先对证书解锁 直接在终端执行可以不必要
    #UNLOCK=`security show-keychain-info ~/Library/Keychains/login.keychain 2>&1|grep no-timeout`
    #if [ -z "$UNLOCK" ]; then
        # -p 后面跟的是密码,各机器可能不一样,要修改
        #security unlock-keychain -p 123u123u ~/Library/Keychains/login.keychain
        # 修改unlock-keychain过期时间,最好大于一次打包时间
        #security set-keychain-settings -t 3600000 -l ~/Library/Keychains/login.keychain
    #fi
	
	echo "--> Delete Auto Manage Signing"
	python ${BUILD_TOOL_PATH}/ExportOptions/DeleteAutoManageSigning.py ${BUILD_PATH}/${BUILD_FILE_NAME}/

	echo '--> 正在清理工程'
	xcodebuild clean -project ${XCODE_PROJ_PATH} -scheme ${SCHEME} -configuration ${CONFIGURATION} \
	>>${BUILD_LOG_PATH}

	echo '--> 工程清理完成-->>>--正在编译工程:'${CONFIGURATION}
	xcodebuild archive -project ${XCODE_PROJ_PATH} \
	-scheme ${SCHEME} -configuration ${CONFIGURATION} -archivePath ${ARCHIVE_PATH} \
	CODE_SIGN_IDENTITY="${CODE_SIGN_IDENTITY}" PROVISIONING_PROFILE_SPECIFIER="${PROVISIONING_PROFILE_NAME}" \
	>>${BUILD_LOG_PATH}
	if [ -d "$ARCHIVE_PATH" ] ; then
      echo '--> 项目编译成功'
    else
      echo '--> 项目编译失败'
        exit 1
    fi

	echo '--> 项目编译完成-->>>--开始IPA打包'
	xcodebuild -exportArchive -archivePath ${ARCHIVE_PATH} -configuration ${CONFIGURATION} \
	-exportPath ${EXPORT_PATH} -exportOptionsPlist "$EXPORT_OPTION_PLIST" \
	>>${BUILD_LOG_PATH}
	
	if [ -e "$EXPORT_PATH" ] ; then
      echo '--> 项目构建成功'
	  open $EXPORT_PATH  # 打包后打开ipa所在文件夹  
    else
      echo '--> 项目构建失败'
        exit 1
    fi
  fi
fi

#公司Fir账号的Token  2c5a5ecc1df1a247ce2ce9616dcbb4f6
#个人Fir账号的Token  95c0c894b9ee035d1cc67761272822fb
#处理上传流程

if  [[ $FIR_TOKEN = "piaoyuzc@qq.com" ]]; then
  if [[ $BUILD_TARGET = "Android" ]]; then
    FIR_TOKEN_ID="2c5a5ecc1df1a247ce2ce9616dcbb4f6"
	FIR_SHORT_NAME="ylqtswa"
  else
    FIR_TOKEN_ID="2c5a5ecc1df1a247ce2ce9616dcbb4f6"
	FIR_SHORT_NAME="ylqtswi"
  fi
else
  if [[ $BUILD_TARGET = "Android" ]]; then
    FIR_TOKEN_ID="95c0c894b9ee035d1cc67761272822fb"
	FIR_SHORT_NAME="ylqta"
  else
    FIR_TOKEN_ID="95c0c894b9ee035d1cc67761272822fb"
	FIR_SHORT_NAME="ylqti"
  fi
fi

echo "--> Set FIR_TOKEN : ${FIR_TOKEN}" 
echo "--> Set FIR_TOKEN_ID : ${FIR_TOKEN_ID}" 
echo "--> Set FIR_SHORT_NAME : ${FIR_SHORT_NAME}" 

#应用上传Fir第三方托管
if  [[ $UPLOAD_FIR = "true" ]]; then
echo '--> 发布应用到 fir.im平台'
  if [[ $BUILD_TARGET = "Android" ]]; then
    UPLOAD_APP_PATH=${BUILD_PATH}/${BUILD_FILE_NAME}
  else
	UPLOAD_APP_PATH=${IPA_OUTPUT_PATH}/${BUILD_FILE_NAME}/${SCHEME}.ipa
  fi

  echo "--> Set UPLOAD_APP_PATH : ${UPLOAD_APP_PATH}" 

    # 需要先在本地安装 fir 插件,安装fir插件命令: gem install fir-cli
    fir login -T ${FIR_TOKEN_ID}  # fir.im token
    fir publish  ${UPLOAD_APP_PATH} --short=${FIR_SHORT_NAME}

    if [ $? = 0 ];then
      echo "--> 提交fir.im成功 "
    else
      echo "--> 提交fir.im失败 "
	  exit 1
    fi
fi

if  [[ $UPLOAD_BUGLY = "true" ]]; then
BUGLY_ID="3a46b040bc"
BUGLY_KEY="2501780d-1a32-48c4-80f7-457a1a76df04"
echo '--> 上传Bugly符号表'
  COMMAND_PATH="${BUILD_TOOL_PATH}/buglySymboliOS"
  SETTINGS_PATH="${BUILD_TOOL_PATH}/buglySymboliOS/settings.txt"
  DSYM_NAME="${ARCHIVE_PATH}/dSYMs/ylqt.app.dSYM"
  sh ${COMMAND_PATH}/buglySymboliOS.sh -i ${DSYM_NAME} -u true -d true -id ${BUGLY_ID} -key ${BUGLY_KEY}
    if [ $? = 0 ];then
      echo "--> 上传符号表成功 "
    else
      echo "--> 上传符号表失败 "
    fi
fi

if  [[ $UPLOAD_BUNDLES = "true" ]]; then
echo "--> 上传 ${BUILD_TARGET} Bundles"

LOCAL_PATH=${PROJ_GIT_PATH}/AssetsBundle/${UNITY_CHANNEL}/${REMOTE_BUILD_TARGET_NAME}/Uploads/${REMOTE_BUILD_TARGET_NAME}
REMOTE_PATH=/${UNITY_CHANNEL}/

echo "--> Set LOCAL_PATH  : ${LOCAL_PATH}" 
echo "--> Set REMOTE_PATH : ${REMOTE_PATH}" 

if [ ! -d $LOCAL_PATH ];then
  echo "Log Error : 本地没有需要上传的资源目录 : ${LOCAL_PATH}"
    exit 1
fi

lftp -u hulinchao,hulinchao@123 -p 2122 192.168.10.181 <<EOF
set ftp:list-empty-ok yes
cd /
mkdir -p ${REMOTE_PATH}
cd ${REMOTE_PATH}
lcd ${LOCAL_PATH}
mirror -R ${LOCAL_PATH}
exit
EOF

if [ $? = 0 ];then
   echo "--> 上传${BUILD_TARGET} Bundles成功 "
   
   echo "--> 开始刷新CDN" 

   python $BUILD_TOOL_PATH/Qcloud_CDN_API/QcloudCdnTools_V2.py RefreshCdnDir -u AKIDCCzXq6L0f5GG1XNrlcP3ShgPs52koNIx -p ZtxlIfnfHdjY7QTFl4A2e2B4g27wf8LI --dirs http://res.ylqt.2144gy.com/${UNITY_CHANNEL}/${REMOTE_BUILD_TARGET_NAME}/

   if [ $? = 0 ];then
     echo "--> CDN刷新成功 "
   else
     echo "--> CDN刷新失败 "
   fi

else
   echo "--> 上传${BUILD_TARGET} Bundles失败 "
fi

fi