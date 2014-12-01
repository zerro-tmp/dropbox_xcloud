#!/opt/app/dropbox/bin/bash
source /opt/app/dropbox/etc/config
echo "开始执行操作，请稍候..."
#usbPath=$(cat /tmp/usbdir |cut -d ' ' -f2)
usbPath=$(/usr/local/localshell/usbdir ROOTER)
#echo $usbPath
arr=(${LocalDir//,/ })   
#echo $usbPath${arr[0]}
if [ ${Mode} -eq 1 ];then
/opt/app/dropbox/bin/dropbox_uploader.sh -k download $RemmoteDir $usbPath${arr[0]}
else
for i in ${arr[@]}  
do  
/opt/app/dropbox/bin/dropbox_uploader.sh -k upload $usbPath$i  $RemmoteDir
done 
fi
echo "操作执行完毕！"