#!/bin/bash

TOMURL="https://dlcdn.apache.org/tomcat/tomcat-9/v9.0.71/bin/apache-tomcat-9.0.71.tar.gz"
yum install java-1.8.0-openjdk -y
yum install git maven wget -y
cd /tmp/
wget $TOMURL -O tomcatbin.tar.gz
EXTOUT=`tar xzvf tomcatbin.tar.gz`
TOMDIR=`echo $EXTOUT | cut -d '/' -f1`
useradd --shell /sbin/nologin tomcat
rsync -avzh /tmp/$TOMDIR/ /usr/local/tomcat9/
chown -R tomcat.tomcat /usr/local/tomcat9

rm -rf /etc/systemd/system/tomcat.service

cat <<EOT>> /etc/systemd/system/tomcat.service
[Unit]
Description=Tomcat
After=network.target

[Service]
User=tomcat
WorkingDirectory=/usr/local/tomcat9
Environment=JRE_HOME=/usr/lib/jvm/jre
Environment=JAVA_HOME=/usr/lib/jvm/jre
Environment=CATALINA_HOME=/usr/local/tomcat9
Environment=CATALINE_BASE=/usr/local/tomcat9
ExecStart=/usr/local/tomcat9/bin/catalina.sh run
ExecStop=/usr/local/tomcat9/bin/shutdown.sh
SyslogIdentifier=tomcat-%i

[Install]
WantedBy=multi-user.target
EOT

systemctl daemon-reload
systemctl start tomcat
systemctl enable tomcat

cd /tmp/
wget https://raw.githubusercontent.com/devopshydclub/vprofile-repo/master/tomcat-users.xml
wget https://raw.githubusercontent.com/devopshydclub/vprofile-repo/master/context.xml
cp tomcat-users.xml /usr/local/tomcat9/conf/tomcat-users.xml
cp context.xml /usr/local/tomcat9/webapps/manager/META-INF/
systemctl restart tomcat
echo "Done"
