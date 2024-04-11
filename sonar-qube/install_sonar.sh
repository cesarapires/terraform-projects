#!/bin/bash

DB_USER="ddsonar"
DB_PASSWORD="mwd#2%#!!#%rgs"
DB_NAME="ddsonarqube"

sudo sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt/ `lsb_release -cs`-pgdg main" >> /etc/apt/sources.list.d/pgdg.list'
wget -q https://www.postgresql.org/media/keys/ACCC4CF8.asc -O - | sudo apt-key add -

sudo apt update
sudo apt upgrade -y


sudo apt install -y openjdk-17-jdk
java -version

sudo sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt/ `lsb_release -cs`-pgdg main" /etc/apt/sources.list.d/pgdg.list'

wget -q https://www.postgresql.org/media/keys/ACCC4CF8.asc -O - | sudo apt-key add -

sudo apt install postgresql postgresql-contrib -y

sudo systemctl enable postgresql

sudo systemctl start postgresql

sudo systemctl status postgresql

psql --version

sudo -i -u postgres << EOF
# Dentro do contexto do usuário postgres

# Criar usuário 'ddsonar' no PostgreSQL
createuser $DB_USER

# Acessar o console do PostgreSQL (psql)
psql << SQL
-- Dentro do console do PostgreSQL

-- Definir senha criptografada para o usuário 'ddsonar'
ALTER USER $DB_USER WITH ENCRYPTED password '$DB_PASSWORD';

-- Criar um novo banco de dados 'ddsonarqube' e atribuir como proprietário o usuário 'ddsonar'
CREATE DATABASE $DB_NAME OWNER $DB_USER;

-- Conceder todas as permissões no banco de dados 'ddsonarqube' para o usuário 'ddsonar'
GRANT ALL PRIVILEGES ON DATABASE $DB_NAME to $DB_USER;

-- Sair do console do PostgreSQL
\q
SQL

# Sair do contexto do usuário 'postgres'
exit
EOF

sudo apt install zip -y

sudo wget https://binaries.sonarsource.com/Distribution/sonarqube/sonarqube-10.0.0.68432.zip

sudo unzip sonarqube-10.0.0.68432.zip

sudo mv sonarqube-10.0.0.68432 sonarqube

sudo mv sonarqube /opt/

sudo groupadd $DB_USER

sudo useradd -d /opt/sonarqube -g $DB_USER $DB_USER

sudo chown $DB_USER:$DB_USER /opt/sonarqube -R

# Editar o arquivo sonar.properties usando sed para substituir ou adicionar linhas
sudo sed -i.bak -e "s/^#sonar.jdbc.username=/sonar.jdbc.username=$DB_USER/" \
                -e "s/^#sonar.jdbc.password=/sonar.jdbc.password=$DB_PASSWORD/" \
                -e "/APP_NAME=\"SonarQube\"/i RUN_AS_USER=$DB_USER" \
                -e "\$asonar.jdbc.url=jdbc:postgresql://localhost:5432/$DB_NAME" \
                /opt/sonarqube/conf/sonar.properties

sudo sed -i.bak "/APP_NAME=\"SonarQube\"/i RUN_AS_USER=$DB_USER" /opt/sonarqube/bin/linux-x86-64/sonar.sh

cat <<EOF | sudo tee "/etc/systemd/system/sonar.service" > /dev/null
[Unit]
Description=SonarQube service
After=syslog.target network.target

[Service]
Type=forking
ExecStart=/opt/sonarqube/bin/linux-x86-64/sonar.sh start
ExecStop=/opt/sonarqube/bin/linux-x86-64/sonar.sh stop
User=ddsonar
Group=ddsonar
Restart=always
LimitNOFILE=65536
LimitNPROC=4096
[Install]
WantedBy=multi-user.target
EOF

sudo systemctl enable sonar

sudo systemctl start sonar

sudo systemctl status sonar

sudo sed -i.bak -E "/^vm.max_map_count=/d; /^fs.file-max=/d" /etc/sysctl.conf
sudo sed -i.bak -e "\$avm.max_map_count=262144" -e "\$afs.file-max=65536" /etc/sysctl.conf

sudo reboot