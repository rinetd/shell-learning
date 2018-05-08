#!/bin/bash
sudo unzip lybb.war -d notes
sudo sed -i s## notes/WEB-INF/classes/jeesite.properties

sudo rm -rf /docker/tomcat/webapps/notes
sudo cp -r notes /docker/tomcat/webapps/notes

sudo sed -i "s|^jdbc.url=jdbc:mysql.*|jdbc.url=jdbc:mysql://mysql:3306/zhijian?useUnicode=true\&characterEncoding=UTF-8|g" /docker/tomcat/webapps/notes/WEB-INF/classes/jeesite.properties
sudo sed -i "s|^jdbc.username=.*|jdbc.username=zhijian|g" /docker/tomcat/webapps/notes/WEB-INF/classes/jeesite.properties
sudo sed -i "s|^jdbc.password=.*|jdbc.password=ZQ4oegjqZ|g" /docker/tomcat/webapps/notes/WEB-INF/classes/jeesite.properties
sudo sed -i "s|^upLoadPath=.*|upLoadPath=/upload/notes/|g" /docker/tomcat/webapps/notes/WEB-INF/classes/jeesite.properties

sudo rm -rf notes
