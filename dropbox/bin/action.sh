#!/bin/sh
source /opt/app/dropbox/etc/config
echo $LocalDir
echo $RemmoteDir
echo $PROXY
echo $ActTime
echo $Mode
echo $Cron
Parameter_num=$#
if [ ${Parameter_num} -eq 6 ];then
LocalDir="$1"
RemmoteDir="$2"
PROXY="$3"
ActTime="$4"
Mode="$5"
Cron="$6"
sed -i "s#LocalDir=.*#LocalDir=${LocalDir}#"  /opt/app/dropbox/etc/config
sed -i "s#RemmoteDir=.*#RemmoteDir=${RemmoteDir}#"  /opt/app/dropbox/etc/config
sed -i "s#PROXY=.*#PROXY=${PROXY}#"  /opt/app/dropbox/etc/config
sed -i "s/ActTime=.*/ActTime=${ActTime}/g"  /opt/app/dropbox/etc/config
sed -i "s/Mode=.*/Mode=${Mode}/g"  /opt/app/dropbox/etc/config
sed -i "s/Cron=.*/Cron=${Cron}/g"  /opt/app/dropbox/etc/config
fi

sed -i '/dropbox/d' /etc/crontabs/root
sed -i '/dropbox/d' /etc/mjpg-streamer.conf

if [ ${Cron} -eq 1 ];then
  echo "0 $4 * * * /opt/app/dropbox/bin/run.sh" >> /etc/crontabs/root
tmpc=$(cat /etc/init.d/mjpg-streamer | grep 'crontab /etc/mjpg-streamer.conf')
if [ "$tmpc" != "" ]; then
	echo "0 $4 * * * /opt/app/dropbox/bin/run.sh" >> /etc/mjpg-streamer.conf
fi

fi
 
sync
/etc/init.d/cron restart &

echo "ok"