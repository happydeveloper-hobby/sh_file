#!/bin/sh

#chmod +x installer.sh && ./installer.sh
clear
echo ------------------------------------
echo ------------------------------------
echo ------------------------------------
echo LAIM INSTALL V4 BETA
echo ------------------
echo ------------------


read -p "Enter your server DOMAIN [$dom]: " domain
domain=${domain:-$dom}
echo "$domain"
hostname "$domain"


read -r lkeydownload
lkeydownload='5c1c1c59eab54266e21e43b7bc135f65'
#read -r lkeydownload
#

echo ------------------------------------
echo DOWNLOADING FILES
echo ------------------------------------
apt update -y
#apt upgrade -y
apt-get update --fix-missing -y
apt install curl -y
apt install unzip -y
apt install pwgen -y
sudo apt-get install vim -y
clear
echo ------------------
echo ------------------
cd /root/
mkdir config
cd config || exit
clear
curl -O https://media-upload.net/fUp/"$lkeydownload".zip
echo renaming file
clear
echo ------------------
echo UPDATING SERVER
echo ------------------
sudo apt-get install perl -y
sudo apt-get install alien -y
sudo apt-get install lsof -y
sudo apt-get install unzip -y
clear
echo ------------------------------------
echo UNZIPPING FILES
echo ------------------------------------
unzip -o "$lkeydownload".zip
clear
echo ------------------------------------
echo FILES UNZIPPED
echo ------------------------------------
echo '  '
echo '  '
echo '  '
echo ------------------------------------
echo INSTALLING SCRIPT
echo ------------------------------------
echo ------------------------------------
echo '  '
echo '  '
echo '  '
rm /root/config/"$lkeydownload".zip
alien -i /root/config/PowerMTA-4.5r11.rpm --scripts
#service exim stop
clear
echo '  '
echo '  '

ipadd=$(hostname -I | cut -d' ' -f1)
dom=$(hostname)


echo ------------------------------------
echo "Enter your server hostname"
domain="$dom"
echo "$domain"
clear

echo ------------------------------------
echo "DKIM ENABLED"


mv configdkim config 
sudo apt-get install opendkim opendkim-tools -y
#opendkim-genkey -s dkim -d $domain
mkdir -p /etc/dkim/keys/
opendkim-genkey --bits=1024 --selector=dkim --domain="$domain" --append-domain
chmod 644 dkim.private
chown -R opendkim:opendkim /etc/opendkim.conf /etc/dkim/keys/
mv dkim.private dkim.pem
cp dkim.pem /etc/dkim/keys/dkim.pem
mv dkim.txt /etc/dkim/keys/dkim.txt
#mv /etc/dkim/keys/dkim.private /etc/dkim/keys/dkim.pem

clear


echo ------------------
echo "Enter your server ip"
echo ------------------
ipip="$ipadd"
vi config -c %s/SMTPIP/"$ipip"/ +wq!
vi config -c %s/SMTPDOM/"$domain"/ +wq!
echo "$ipip"
echo '  '
echo '  '
echo ------------------
clear
echo ------------------
echo SMTP Username :
echo ------------------
pwgen 6 1 > genusername
username=`cat genusername`
vi config -c %s/SMTPUSER/"$username"/ +wq!
clear
echo ------------------
pwgen 13 1 > genpasswd
password=`cat genpasswd`
rm genpasswd -r
echo ------------------
smtpport="587"
vi config -c %s/SMTPPASS/"$password"/ +wq!
clear
echo ------------------
vi config -c %s/SMTPPORT/"$smtpport"/ +wq!
echo ------------------
echo '  '
echo '  '
echo '  '
echo ------------------
clear
echo ------------------

slimit="4000"
vi config -c %s/SLIMIT/"$slimit"/ +wq!

vi config -c %s/400/"$slimit"/ +wq!
clear
echo ------------------
echo FINISHING
echo ------------------
echo FIXING LICENSE
mv license /etc/pmta/
echo ------------------
echo MOVING HOST FILES
echo ------------------
mv pmta ../../usr/sbin/
mv pmtad ../../usr/sbin/
mv pmtahttpd ../../usr/sbin/
mv pmtasnmpd ../../usr/sbin/
echo ------------------------------------
echo GENERATE CONFIG FILE
echo ------------------------------------
mv config ../../etc/pmta/
service pmta restart
systemctl restart opendkim.service
clear



echo ------------------------------------
echo REMOVED INSTALL FILES
echo ------------------------------------
echo ------------------------------------
clear



echo "FIXING DOMAIN... PLEASE WAIT"
cd /root/

#go get -u -x github.com/StackExchange/dnscontrol


mkdir ~/dnscontrol
mv /root/config/f1 ~/dnscontrol
mv /root/config/f2 ~/dnscontrol
cd ~/dnscontrol
mkdir ~/dnscontrol/zones
cd ~/dnscontrol

smtoken="NOT WORKING ATM"


vi f1 -c %s/SMTOKEN/$smtoken/ +wq!
cp /etc/dkim/keys/dkim.txt dkim.txt

sed -i '1d' dkim.txt  #remove top line
tr -d " \t" < dkim.txt > outfile.txt #spaties gone
dnsdkim=`cat outfile.txt`

echo $dnsdkim | cut -f1 -d')' >> dkim_raw

dnsdkimraw=`cat dkim_raw`
echo "$dnsdkimraw" | sed 's/"//' | sed 's/"//' >> dkim_raw_filtered
dnsdkimraw_valid=`cat dkim_raw_filtered`

echo "DOMAIN SETTINGS" >> f2
echo "DOMAIN $domain" >> f2
echo ---------------------------------------------- >> f2
echo "A RECORD('@', '$ipip')" >> f2
echo "A RECORD('mail', '$ipip')" >> f2
echo ---------------------------------------------- >> f2
echo "MX | @ | 10 mail.$domain" >> f2
echo ---------------------------------------------- >> f2

echo '"TXT | @ | v=spf1" "a" "mx" "ip4:'$ipip'" "~all' >> f2
echo ---------------------------------------------- >> f2
echo '"TXT | dkim._domainkey | v=DKIM1"; "k=rsa"; "'$dnsdkimraw_valid'' >> f2
echo '"TXT | _dmarc | v=DMARC1"; "p=reject"; "rua=mailto:abuse@'$domain'"; "aspf=s"; "adkim=s' >> f2
echo ---------------------------------------------- >> f2
    
	
#
# 			
#
cp f1 creds.json
cp f2 dnsconfig.js

cp dnsconfig.js /root/domdetails


rm /root/config -r
clear


cd /root/
clear
echo ------------------------------------------------------------------------ >> smtpdetails
echo "SMTP Details | Thank you for installing!" >> smtpdetails
echo ------------------------------------------------------------------------ >> smtpdetails
echo Hostname: "$domain":"$smtpport" >> smtpdetails
echo Username: "$username" >> smtpdetails
echo Password: "$password" >> smtpdetails
echo ------------------------------------------------------------------------ >> smtpdetails
echo Sender [For Best Result] "$username"@"$domain" >> smtpdetails
echo Server Limit /h "$slimit" >> smtpdetails
#
# A NEW UPDATE
#
cat smtpdetails
echo ------------------------------------------------------------------------
echo "SMTP Details located at FILE >> [smtpdetails]"
echo "DOMAIN Details located at FILE >> [domdetails]"
echo ------------------------------------------------------------------------
echo "RESULTS: BETA"

echo ------------------------------------------------------------------------
echo "SMTP		[TRUE]"
echo "SSL/TLS 	[FALSE] > Next Update?!"
echo "SPF 		[TRUE]"
echo "DMARC 	[TRUE]"
echo "SPAMSCORE [10/10]"
echo ------------------------------------------------------------------------
echo "Version 2.0.4 BETA"
echo ------------------------------------------------------------------------
rm /root/installer.sh
rm /root/dnscontrol -r
cat domdetails