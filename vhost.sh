#!/bin/sh

# vhost.sh
#
# script to create/delete/fix sites stored in ~/public_html

TLD="local"
ACTION="$1"
HOSTNAME="${2}.${TLD}"
SITEDIR="${HOME}/public_html/${HOSTNAME}"
LOGDIR="${SITEDIR}/log"
PUBDIR="${SITEDIR}/public"
USER=`whoami`
APACHEGRP="www-data"

create () {
	# Create site directory if not exist.
	if [ -d "${SITEDIR}" ]; then
		echo "Site directory exists."
	else
		echo "Creating site directory."
		mkdir -p $SITEDIR
	fi

	# Create log directory if not exist.
	if [ -d "${LOGDIR}" ]; then
		echo "Log directory exists."
	else
		echo "Creating log directory."
		mkdir -p $LOGDIR
	fi

	# Create public directory if not exist.
	if [ -d "${PUBDIR}" ]; then
		echo "Public directory exists."
	else
		echo "Creating public directory."
		mkdir -p $PUBDIR
	fi

	# Create site vhost file
	echo "Creating virtualhost file"
	cat vhost.tmpl | sed "s/\${HOSTNAME}/${HOSTNAME}/" | sed "s|\${PUBDIR}|$PUBDIR|" | sed "s|\${LOGDIR}|${LOGDIR}|" > "/tmp/${HOSTNAME}"
	sudo mv "/tmp/${HOSTNAME}" "/etc/apache2/sites-available/${HOSTNAME}"

	# Enable site
	echo "Enabling site."
	sudo a2ensite $HOSTNAME

	# Add site to hosts file
	#sudo $(cat "127.0.0.1	${HOSTNAME}" >> /etc/hosts)

	# Restart webserver
	/etc/init.d/apache2 restart
}

delete () {
	sudo a2dissite $HOSTNAME
	sudo rm "/etc/apache2/sites-available/${HOSTNAME}"
	sudo /etc/init.d/apache2 restart
}

permissions() {
	chown -R $USER:$APACHEGRP
	chmod -R 775 $SITEDIR
}

case "$1" in
	add) create ;;
	del) delete ;;
	per) permissions ;;
esac
