#!/bin/bash

##startalk 脚本执行
## 脚本帮助文档
help_display(){
    echo "install_video.sh: script [options...] [location]"
    echo -h "       show help pages" 
    echo -i "       install server" 
    echo -u "       uninstall server"
    echo -s "       start the server"
    echo -p "       stop  the server"
    exit 0
}


## 安装脚本
install(){
   echo -e "\033[31m Startalk Server开始安装请稍后...！\033[0m"
   logPath="/startlak.install.log"
   touch $logPath
   resource="startalk_openresource_20200117.tar"
   md5Value="c897c4b19576cd1fe219d0ea08f3cdf3"
   cd /
   wget -c https://i.startalk.im/pubapi/soft/download/$resource

   if [ $? -ne 0 ]; then
   echo -e "\033[31m Download failed please check if the network is available！\033[0m"
   exit
   else
   echo -e "\033[31m File download succeeded！\033[0m"
   fi

   md5Down=`md5sum $resource | awk '{print $1}'`
   if [ "$md5Down" != "$md5Value" ]
   then
   echo -e "\033[31m The file download is broken, please execute the script again! !\033[0m"
   exit
   fi
   ##解压文件
   tar xf $resource
   chown -R startalk:startalk /startalk
   cd /startalk 

   ##保留之前备份数据
   if [  -d "data.uninstall" ]; then
   rm -rf data
   mv data.uninstall data
   fi

   ##修改yum源
   yum clean all
   yum update -y 
   yum install -y epel-release 
   cp -rf /etc/yum.repos.d /etc/yum.repos.d.bak 
   rm -f /etc/yum.repos.d/* 
   cp -f /startalk/yum/base.repo /etc/yum.repos.d/ 
   yum install -y telnet aspell bzip2 collectd-postgresql collectd-rrdtool collectd.x86_64 curl db4 expat.x86_64 gcc gcc-c++ gd gdbm git gmp ImageMagick java-1.8.0-openjdk java-1.8.0-openjdk libcollection libedit libffi libicu libpcap libtidy libwebp libxml2 libXpm libxslt libyaml.x86_64 mailcap ncurses ncurses npm openssl pcre perl perl-Business-ISBN perl-Business-ISBN-Data perl-Collectd perl-Compress-Raw-Bzip2 perl-Compress-Raw-Zlib perl-Config-General perl-Data-Dumper perl-Digest perl-Digest-MD5 perl-Encode-Locale perl-ExtUtils-Embed perl-ExtUtils-MakeMaker perl-GD perl-HTML-Parser perl-HTML-Tagset perl-HTTP-Date perl-HTTP-Message perl-IO-Compress perl-IO-HTML perl-JSON perl-LWP-MediaTypes perl-Regexp-Common perl-Thread-Queue perl-TimeDate perl-URI python readline recode redis rrdtool rrdtool-perl sqlite systemtap-sdt.x86_64 tk xz zlib rng-tools python36-psycopg2.x86_64 python34-psycopg2.x86_64 python-psycopg2.x86_64 python-pillow python34-pip screen >>  $logPath
   source /startalk/qtalk_search/venv/bin/activate
   pip3 install pip --upgrade
   pip3 install -r /startalk/qtalk_search/requirements.txt

   ##获取参数
   need_ssl="n"
   yourdomain="127.0.0.1"
   yourhost="im5.startalk.com"
   push_key="*****"

   echo -e "\033[31m 请输入部署机器IP或域名按回车确认: \033[0m"
   read ip
   while [[ ! -n "$ip" ]]
   do
   echo -e "\033[31m 机器IP或域名不能为空,请重新输入按回车确认: \033[0m" 
   read ip
   done
   yourdomain=$ip
   
   echo  -e "\033[31m 请输入公司域名按回车确认(不输入按默认值): \033[0m"
   read host
   if [  -n "$host" ]; then
   yourhost=$host
   fi
   
   echo -e "\033[31m 是否需要https协议,使用https协议需要您已有证书（y/n）: \033[0m"
   read need_ssl
   declare -l need_ssl=$need_ssl
   if [ x"$need_ssl" != "xy" ]; then
      need_ssl='n'
   fi

   echo  -e "\033[31m 请输入push key按回车确认,(没有购买直接按回车跳过): \033[0m"
   read push_key_temp
   if [  -n "$push_key_temp" ]; then
     push_key=$push_key_temp
   fi
   ## 执行init脚本
   sudo bash /startalk/tools/init.sh -s $need_ssl -d $yourdomain -h $yourhost -k $push_key
  
   ## 启动服务
   sudo bash /startalk/tools/start.sh
   
   sleep 5
   ## 执行check
   sudo bash /startalk/tools/check.sh
   
   if [ "x$need_ssl" != "xy" ]
   then
    lianjie="http://$yourdomain:8080"
   else
    lianjie="https://$yourdomain:8443"
   fi
 
   echo -e "\033[31m 部署完成，请下载客户端后配置导航地址即可登录! \033[0m"
   echo -e "\033[31m 导航地址：$lianjie/startalk_nav \033[0m" 
   echo -e "\033[31m 管理员帐号：admin / testpassword \033[0m"
   exit
 }


## 卸载服务
 uninstall(){
  sudo bash /startalk/tools/uninstall.sh
  echo -e "\033[31m 服务已卸载 \033[0m"
  exit
 }


## 启动服务
 startserver(){
  sudo bash /startalk/tools/start.sh
  echo -e "\033[31m 服务已启动 \033[0m"
  exit
 }

## 停止服务
  stopserver(){
  sudo bash /startalk/tools/stop.sh
  echo -e "\033[31m 服务已停止 \033[0m"
  exit
 }

 while getopts 'hiusp' c;
 do
 case $c in 
 h) help_display ;;
 i) install ;;
 u) uninstall ;;
 s) startserver ;;
 p) stopserver ;;
esac
done



