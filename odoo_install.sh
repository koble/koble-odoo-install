#!/bin/bash
################################################################################
# Script for Installation: ODOO Saas4/Trunk server on Ubuntu 14.04 LTS
# Author: André Schenkels, ICTSTUDIO 2014
# Adpated for Brazilian Localization by Koble Open Solutions (Wagner Pereira)
#-------------------------------------------------------------------------------
#  
# This script will install ODOO Server on Ubuntu LTS Servers (14.04+)
#-------------------------------------------------------------------------------
# USAGE:
#
# odoo-install
#
# EXAMPLE:
# ./odoo-install 
#
################################################################################
 
##fixed parameters
#odoo
OE_USER="odoo"
OE_HOME="/opt/$OE_USER"
OE_HOME_EXT="/opt/$OE_USER/$OE_USER-server"
OE_LOCALE="pt_BR.UTF-8"

#Enter version for checkout "8.0" for version 8.0, "7.0 (version 7), saas-4, saas-5 (opendays version) and "master" for trunk
OE_VERSION="10.0"

#set the superadmin password
OE_SUPERADMIN="admin"
OE_CONFIG="$OE_USER-server"

#list of custom addons to be installed
declare -a addons=( \
	"l10n-brazil" \
	"odoo-brazil-eletronic-documents" \
	"odoo-brazil-banking" \
	"account-fiscal-rule" \
	"server-tools" \
	"manufacture" \
	"partner-contact" \
	"project" \
	"commission" \
	"stock-logistics-warehouse" \
	"account-financial-tools" \
	"web" \
	"website" \
	"social" \
	"knowledge" \
	"hr" \
	"purchase-reporting" \
	"crm"\
	"product-attribute" \
	"business-requirement" \
	"account-financial-reporting" \
	"bank-payment" \
	"purchase-workflow" \
	"account-invoicing" \
	"sale-reporting" \
	"sale-workflow" \
	"rma" \
	"contract" \
	"management-system" \
	"geospatial" \
	"e-commerce" \
	"stock-logistics-workflow" \
	"bank-statement-reconcile" \
	"account-invoice-reporting" \
	"reporting-engine" \
	"maintainer-quality-tools" \
	"stock-logistics-barcode" \
	"product-variant" \
	"delivery-carrier" \
	"vertical-isp" \
	"survey" \
	"account-closing" \
	"bank-statement-import" \
	"multi-company" \
	"pos" \
	"vertical-association" \
	"report-print-send" \
	"account-payment" \
	"account-budgeting" \
	"account-analytic" \
	"vertical-medical" \
	"vertical-travel" \
	"event" \
	"donation" \
	"stock-logistics-reporting" \
	"hr-timesheet" \
	"webkit-tools" \
	"department" \
	"sale-financial" \
	"margin-analysis" \
	"stock-logistics-transport" \
	"vertical-ngo" \
	"vertical-hotel" \
	"vertical-education" \
	"vertical-edition" \
	"vertical-construction" \
	"vertical-abbey" \
	"stock-logistics-tracking" \
	"project-reporting" \
	"manufacture-reporting" \
	"account-consolidation" 
	)

##--------------------------------------------------
## Update Server
##--------------------------------------------------
echo -e "\n---- Update Server ----"
sudo apt-get update
sudo apt-get upgrade -y
sudo apt-get install -y locales
export LANGUAGE=en_US.UTF-8
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8
#sudo locale-gen en_US.UTF-8
#sudo dpkg-reconfigure locales

##--------------------------------------------------
## Install PostgreSQL Server
##--------------------------------------------------
echo -e "\n---- Install PostgreSQL Server ----"
sudo apt-get install postgresql -y
	
echo -e "\n---- PostgreSQL $PG_VERSION Settings  ----"
sudo sed -i s/"#listen_addresses = 'localhost'"/"listen_addresses = '*'"/g /etc/postgresql/`psql --version 2>&1 | tail -1 | awk '{print $3}' | sed 's/\./ /g' | awk '{print $1 "." $2}'`/main/postgresql.conf

#echo -e "\n---- Creating the ODOO PostgreSQL User  ----"
sudo su - postgres -c "createuser -s $OE_USER" 2> /dev/null || true

##--------------------------------------------------
## Install Dependencies
##--------------------------------------------------
echo -e "\n---- Install tool packages ----"
sudo apt-get install wget subversion git bzr bzrtools python-pip unixodbc libgeos-dev -y
	
#echo -e "\n---- Install python packages ----"
sudo apt-get install python-pyodbc python-dateutil python-feedparser python-ldap python-libxslt1 python-lxml python-mako python-openid python-psycopg2 python-pybabel python-pychart python-pydot python-pyparsing python-reportlab python-simplejson python-tz python-vatnumber python-vobject python-webdav python-werkzeug python-xlwt python-yaml python-zsi python-docutils python-psutil python-mock python-unittest2 python-jinja2 python-pypdf python-decorator python-requests python-passlib python-pil python-mysqldb node-less python-xlsxwriter python-fdb -y
	
#echo -e "\n---- Install python libraries ----"
sudo pip install gdata phonenumbers woocommerce magento sqlalchemy pymssql ofxparse Shapely geojson phonenumbers

#echo -e "\n---- Install wkhtml and place on correct place for ODOO 8 ----"
sudo wget http://download.gna.org/wkhtmltopdf/0.12/0.12.1/wkhtmltox-0.12.1_linux-trusty-amd64.deb
sudo dpkg -i wkhtmltox-0.12.1_linux-trusty-amd64.deb
sudo cp /usr/local/bin/wkhtmltopdf /usr/bin
sudo cp /usr/local/bin/wkhtmltoimage /usr/bin
	
#echo -e "\n---- Create ODOO system user ----"
sudo adduser --system --quiet --shell=/bin/bash --home=$OE_HOME --gecos 'ODOO' --group $OE_USER

#echo -e "\n---- Create Log directory ----"
sudo mkdir /var/log/$OE_USER
sudo chown $OE_USER:$OE_USER /var/log/$OE_USER

#--------------------------------------------------
# Install ODOO
#--------------------------------------------------
echo -e "\n==== Installing ODOO Server ===="
sudo git clone --branch $OE_VERSION https://www.github.com/koble/OCB $OE_HOME_EXT/

echo -e "\n==== Change permission to $OE_USER:$OE_USER ===="
sudo chown -Rf $OE_USER:$OE_USER $OE_HOME

echo -e "\n---- Create custom module directory ----"
sudo su $OE_USER -c "mkdir $OE_HOME/custom"
sudo su $OE_USER -c "mkdir $OE_HOME/custom/addons"

#--------------------------------------------------
# Download extra addons
#--------------------------------------------------
for i in "${addons[@]}"
do
	echo -e "\n---- Download $i ----"
	sudo git clone https://github.com/koble/`echo $i` \
        	--depth 1 \
	        --branch $OE_VERSION \
		`echo $OE_HOME`/custom/`echo $i`

	echo -e "---- Change permissions $i ----"
	sudo chown -Rf $OE_USER:$OE_USER $OE_HOME/custom/$i

	echo -e "---- Create symlinks to custom/addons directory ----"
	for dir in `echo $OE_HOME`/custom/`echo $i`/*
	do
	  if [ -d $dir ] ; then
	    if [[ ! $dir = *__unported__ ]] ; then
	      if [[ ! $dir = *setup ]] ; then
	        if [ -e $dir/__init__.py ] ; then
	          ln -s $dir $OE_HOME/custom/addons
	        else
	          ln -s $OE_HOME/custom/$i $OE_HOME/custom/addons
	        fi
	      fi
	    fi
	  fi
	done
done
chown -Rf $OE_USER:$OE_USER $OE_HOME/custom/addons/*

#--------------------------------------------------
# Install pyxmlsec
#--------------------------------------------------
echo -e "* Install pyxmlsec"
mkdir `echo $OE_HOME`/custom/pyxmlsec
cd `echo $OE_HOME`/custom/pyxmlsec
wget http://labs.libre-entreprise.org/frs/download.php/897/pyxmlsec-0.3.1.tar.gz
sudo tar -zxvf pyxmlsec-0.3.1.tar.gz --strip-components=1
sudo ./setup.py install
cd -

#--------------------------------------------------
# Install PySPED
#--------------------------------------------------
echo -e "* Install PySPED"
sudo git clone https://github.com/koble/PySPED --depth 1 `echo $OE_HOME`/custom/PySPED
cd `echo $OE_HOME`/custom/PySPED
sudo python setup.py install
cd -

#--------------------------------------------------
# Install Geraldo Reports
#--------------------------------------------------
echo -e "* Install Geraldo Reports"
sudo git clone https://github.com/aricaldeira/geraldo --depth 1 `echo $OE_HOME`/custom/geraldo
cd `echo $OE_HOME`/custom/geraldo
sudo python setup.py install
cd -

#--------------------------------------------------
# Create Config Files
#--------------------------------------------------
echo -e "* Create server config file"
sudo cp $OE_HOME_EXT/debian/odoo.conf /etc/$OE_CONFIG.conf
sudo chown $OE_USER:$OE_USER /etc/$OE_CONFIG.conf
sudo chmod 640 /etc/$OE_CONFIG.conf

echo -e "* Change server config file"
sudo sed -i s/"db_user = .*"/"db_user = $OE_USER"/g /etc/$OE_CONFIG.conf
sudo sed -i s/"; admin_passwd.*"/"admin_passwd = $OE_SUPERADMIN"/g /etc/$OE_CONFIG.conf
sudo su root -c "echo 'logfile = /var/log/$OE_USER/$OE_CONFIG$1.log' >> /etc/$OE_CONFIG.conf"
sudo su root -c "echo 'addons_path=$OE_HOME_EXT/addons,$OE_HOME/custom/addons' >> /etc/$OE_CONFIG.conf"
sudo su root -c "echo '; workers = 5' >> /etc/$OE_CONFIG.conf"

echo -e "* Create startup file"
sudo su root -c "echo '#!/bin/sh' >> $OE_HOME_EXT/start.sh"
sudo su root -c "echo 'sudo -u $OE_USER $OE_HOME_EXT/odoo-bin --config=/etc/$OE_CONFIG.conf' >> $OE_HOME_EXT/start.sh"
sudo chmod 755 $OE_HOME_EXT/start.sh

#--------------------------------------------------
# Adding ODOO as a deamon (initscript)
#--------------------------------------------------

echo -e "* Create init file"
echo '#!/bin/sh' >> ~/$OE_CONFIG
echo '### BEGIN INIT INFO' >> ~/$OE_CONFIG
echo "# Provides: $OE_CONFIG" >> ~/$OE_CONFIG
echo '# Required-Start: $remote_fs $syslog' >> ~/$OE_CONFIG
echo '# Required-Stop: $remote_fs $syslog' >> ~/$OE_CONFIG
echo '# Should-Start: $network' >> ~/$OE_CONFIG
echo '# Should-Stop: $network' >> ~/$OE_CONFIG
echo '# Default-Start: 2 3 4 5' >> ~/$OE_CONFIG
echo '# Default-Stop: 0 1 6' >> ~/$OE_CONFIG
echo '# Short-Description: Enterprise Business Applications' >> ~/$OE_CONFIG
echo '# Description: ODOO Business Applications' >> ~/$OE_CONFIG
echo '### END INIT INFO' >> ~/$OE_CONFIG
echo 'PATH=/bin:/sbin:/usr/bin' >> ~/$OE_CONFIG
echo "DAEMON=$OE_HOME_EXT/odoo-bin" >> ~/$OE_CONFIG
echo "NAME=$OE_CONFIG" >> ~/$OE_CONFIG
echo "DESC=$OE_CONFIG" >> ~/$OE_CONFIG
echo '' >> ~/$OE_CONFIG
echo '# Specify the user name (Default: odoo).' >> ~/$OE_CONFIG
echo "USER=$OE_USER" >> ~/$OE_CONFIG
echo '' >> ~/$OE_CONFIG
echo '# Specify an alternate config file (Default: /etc/odoo-server.conf).' >> ~/$OE_CONFIG
echo "CONFIGFILE=\"/etc/$OE_CONFIG.conf\"" >> ~/$OE_CONFIG
echo '' >> ~/$OE_CONFIG
echo '# pidfile' >> ~/$OE_CONFIG
echo 'PIDFILE=/var/run/$NAME.pid' >> ~/$OE_CONFIG
echo '' >> ~/$OE_CONFIG
echo '# Additional options that are passed to the Daemon.' >> ~/$OE_CONFIG
echo 'DAEMON_OPTS="-c $CONFIGFILE"' >> ~/$OE_CONFIG
echo '[ -x $DAEMON ] || exit 0' >> ~/$OE_CONFIG
echo '[ -f $CONFIGFILE ] || exit 0' >> ~/$OE_CONFIG
echo 'checkpid() {' >> ~/$OE_CONFIG
echo '[ -f $PIDFILE ] || return 1' >> ~/$OE_CONFIG
echo 'pid=`cat $PIDFILE`' >> ~/$OE_CONFIG
echo '[ -d /proc/$pid ] && return 0' >> ~/$OE_CONFIG
echo 'return 1' >> ~/$OE_CONFIG
echo '}' >> ~/$OE_CONFIG
echo '' >> ~/$OE_CONFIG
echo 'case "${1}" in' >> ~/$OE_CONFIG
echo 'start)' >> ~/$OE_CONFIG
echo 'echo -n "Starting ${DESC}: "' >> ~/$OE_CONFIG
echo 'start-stop-daemon --start --quiet --pidfile ${PIDFILE} \' >> ~/$OE_CONFIG
echo '--chuid ${USER} --background --make-pidfile \' >> ~/$OE_CONFIG
echo '--exec ${DAEMON} -- ${DAEMON_OPTS}' >> ~/$OE_CONFIG
echo 'echo "${NAME}."' >> ~/$OE_CONFIG
echo ';;' >> ~/$OE_CONFIG
echo 'stop)' >> ~/$OE_CONFIG
echo 'echo -n "Stopping ${DESC}: "' >> ~/$OE_CONFIG
echo 'start-stop-daemon --stop --quiet --pidfile ${PIDFILE} \' >> ~/$OE_CONFIG
echo '--oknodo' >> ~/$OE_CONFIG
echo 'echo "${NAME}."' >> ~/$OE_CONFIG
echo ';;' >> ~/$OE_CONFIG
echo '' >> ~/$OE_CONFIG
echo 'restart|force-reload)' >> ~/$OE_CONFIG
echo 'echo -n "Restarting ${DESC}: "' >> ~/$OE_CONFIG
echo 'start-stop-daemon --stop --quiet --pidfile ${PIDFILE} \' >> ~/$OE_CONFIG
echo '--oknodo' >> ~/$OE_CONFIG
echo 'sleep 1' >> ~/$OE_CONFIG
echo 'start-stop-daemon --start --quiet --pidfile ${PIDFILE} \' >> ~/$OE_CONFIG
echo '--chuid ${USER} --background --make-pidfile \' >> ~/$OE_CONFIG
echo '--exec ${DAEMON} -- ${DAEMON_OPTS}' >> ~/$OE_CONFIG
echo 'echo "${NAME}."' >> ~/$OE_CONFIG
echo ';;' >> ~/$OE_CONFIG
echo '*)' >> ~/$OE_CONFIG
echo 'N=/etc/init.d/${NAME}' >> ~/$OE_CONFIG
echo 'echo "Usage: ${NAME} {start|stop|restart|force-reload}" >&2' >> ~/$OE_CONFIG
echo 'exit 1' >> ~/$OE_CONFIG
echo ';;' >> ~/$OE_CONFIG
echo '' >> ~/$OE_CONFIG
echo 'esac' >> ~/$OE_CONFIG
echo 'exit 0' >> ~/$OE_CONFIG

echo -e "* Security Init File"
sudo mv ~/$OE_CONFIG /etc/init.d/$OE_CONFIG
sudo chmod 755 /etc/init.d/$OE_CONFIG
sudo chown root: /etc/init.d/$OE_CONFIG

echo -e "* Start ODOO on Startup"
sudo update-rc.d $OE_CONFIG defaults
 
sudo service $OE_CONFIG start
echo "Done! The ODOO server can be started with: service $OE_CONFIG start"
