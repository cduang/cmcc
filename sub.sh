yl(){
if [ $(command -v nginx | grep -c "nginx") -lt 1 -o $(command -v curl | grep -c "curl") -lt 1 -o $(command -v wget | grep -c "wget") -lt 1 ]
then yum update -y || apt update -y
yes | yum upgrade || yes | apt upgrade
yum update -y || apt update -y
yum install nginx curl wget -y || apt install nginx curl wget -y
fi
if [ $(command -v nginx | grep -c "nginx") -lt 1 -o $(command -v curl | grep -c "curl") -lt 1 -o $(command -v wget | grep -c "wget") -lt 1 ]
then yum install epel-release -y && yum install nginx curl wget -y
fi
if [ $(command -v nginx | grep -c "nginx") -lt 1 -o $(command -v curl | grep -c "curl") -lt 1 -o $(command -v wget | grep -c "wget") -lt 1 ]
then echo "自动检测依赖失败，请检查nginx curl wget是否已安装，如未请手动安装"
else echo "依赖安装成功"
fi
}
spip(){
spip=$(curl -s ifconfig.me)
[ -z "$spip" ] && spip
echo "获取服务器ip中 $spip"
}
nginxroot(){
if [ ! -f ~/lt809ml/nginxroot ]
then [ $(ps -A | grep nginx | wc -l) -eq 0 ] && nginx
if [ -d /www/server/nginx/html ]
then echo 1 > /www/server/nginx/html/test
[ $(curl -s http://127.0.0.1/test) -eq 1 ] && nginxroot="/www/server/nginx/html"
rm -rf /www/server/nginx/html/test
fi
if [ -d /var/www/html ]
then echo 1 > /var/www/html/test
[ $(curl -s http://127.0.0.1/test) -eq 1 ] && nginxroot="/var/www/html"
rm -rf /var/www/html/test
fi
if [ -d /usr/share/nginx/html ]
then echo 1 > /usr/share/nginx/html/test
[ $(curl -s http://127.0.0.1/test) -eq 1 ] && nginxroot="/usr/share/nginx/html"
rm -rf /usr/share/nginx/html/test
fi
[ -z "$nginxroot" ] && echo "nginx网页根目录获取失败，请检查nginx默认端口是否为80，如为80则是脚本不支持此系统，请联系作者" || echo "nginxroot为$nginxroot"
else nginxroot=$(cat ~/lt809ml/nginxroot)
fi
}
if [ $(command -v x-ui | grep -c "x-ui") -lt 1 ]
then echo 未安装x-ui请先安装x-ui，替换好809专用xray内核，新建ws节点，然后重新运行此脚本
else yl
nginxroot
spip
spport="443"
s=$(echo $(($(cat /usr/local/x-ui/bin/config.json | grep -o "port.*" | grep -n "443" | cut -c 1)-1)))
#id=$(cat /usr/local/x-ui/bin/config.json | grep -o '"id".*' | sed -n "$s"p | cut -d '"' -f4)
id=$(cat /usr/local/x-ui/bin/config.json | grep -o '"id".*'|awk -F "\"" '{print $4}')
fakeid=$(echo $RANDOM | md5sum | cut -c 1-22)
md5="3d99ff138e1f41e931e58617e7d128e2"
spkey=$(echo -n "if5ax/?fakeid=$fakeid&spid=31117&pid=31117&spip=$spip&spport=$spport$md5" | md5sum | cut -d " " -f1)
url=$(curl -s -X GET -H "Host:dir.wo186.tv:809" -H "User-Agent:Mozilla/5.0 (Linux; Android 11; M2012K11AC) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/96.0.4664.104 Mobile Safari/537.36" "http://dir.wo186.tv:809/if5ax/?fakeid=$fakeid&spid=31117&pid=31117&spip=$spip&spport=$spport&spkey=$spkey" | grep -o "url.*" | cut -d '"' -f3 | sed 's/\\//g')
host=$(echo $url | cut -d "/" -f3 | cut -d ":" -f1)
port=$(echo $host | cut -d ":" -f2)
path=$(echo $url | grep -o "/if5ax.*")
enpath=$(echo $path | sed 's/=/\\u003d/g' | sed 's/&/\\u0026/g')
config=$(echo -n "{\"add\":\"$host\",\"aid\":\"0\",\"host\":\"$host\",\"id\":\"$id\",\"net\":\"ws\",\"path\":\"$enpath\",\"port\":\"809\",\"ps\":\"联通809免流\",\"scy\":\"auto\",\"sni\":\"\",\"tls\":\"\",\"type\":\"\",\"v\":\"2\"}" | base64 -w 0)
echo -n "vmess://$config" | base64 -w 0 > $nginxroot/809
[ $(ps -A | grep "nginx" | wc -l) -lt 1 ] && nginx
[ ! -d ~/lt809ml ] && mkdir ~/lt809ml
[ ! -a ~/lt809ml/sub ] && wget -O ~/lt809ml/sub https://gitee.com/shoujiyanxishe/shjb/raw/main/lt809ml/sub
chmod +x ~/lt809ml/sub
if [ $(crontab -l | grep "lt809ml/sub" | wc -l) -lt 1 ]
then crontab -l > crontablist
echo "0 0-23/3 * * * /root/lt809ml/sub" >> crontablist
crontab crontablist
rm -rf crontablist
fi
fi
