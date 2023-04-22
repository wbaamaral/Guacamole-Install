#!/bin/bash
#######################################################################################################################
# Add Let's Encrypt SSL Certificates to Guacamole with Nginx reverse proxy
# For Ubuntu / Debian / Raspian
# 4b of 4
# David Harrop
# April 2023
#######################################################################################################################

# Prepare text output colours
GREY='\033[0;37m'
DGREY='\033[0;90m'
GREYB='\033[1;37m'
RED='\033[0;31m'
LRED='\033[0;91m'
GREEN='\033[0;32m'
LGREEN='\033[0;92m'
YELLOW='\033[0;33m'
LYELLOW='\033[0;93m'
BLUE='\033[0;34m'
LBLUE='\033[0;94m'
CYAN='\033[0;36m'
LCYAN='\033[0;96m'
MAGENTA='\033[0;35m'
LMAGENTA='\033[0;95m'
NC='\033[0m' #No Colour

echo
echo
echo -e "${LGREEN}Installing Let's Encrypt SSL configuration for Nginx...${GREY}"
echo

# Install nginx
apt-get update -qq &>> ${LOG_LOCATION}
apt-get install nginx certbot python3-certbot-nginx -qq -y &>> ${LOG_LOCATION}

# Backup the current Nginx config
	cp /etc/nginx/sites-enabled/${PROXY_SITE}  $DOWNLOAD_DIR/${PROXY_SITE}-nginx.bak
	echo
	echo -e "${GREY}Backing up previous Nginx proxy to $DOWNLOAD_DIR/$PROXY_SITE-nginx.bak"
if [ $? -ne 0 ]; then
	echo -e "${RED}Failed. See ${LOG_LOCATION}${GREY}" 1>&2
	exit 1
else
	echo -e "${LGREEN}OK${GREY}"
	echo
fi

# Configure Nginx to accept the new certificates
echo -e "${GREY}Configuring Nginx proxy for Let's Encrypt SSL and setting up automatic HTTP redirect...${GREY}"
cat > /etc/nginx/sites-available/$PROXY_SITE <<EOL
server {
    listen 80 default_server;
    #listen [::]:80 default_server;
    root /var/www/html;
    index index.html index.htm index.nginx-debian.html;
    server_name $PROXY_SITE;
    location / {
        proxy_pass $GUAC_URL;
        proxy_buffering off;
        proxy_http_version 1.1;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection \$http_connection;
        access_log off;
    }
}
EOL
if [ $? -ne 0 ]; then
	echo -e "${RED}Failed. See ${LOG_LOCATION}${GREY}" 1>&2
	exit 1
	else
	echo -e "${LGREEN}OK${GREY}"
	echo
fi

# Bounce Nginx to reload the new Nginx config so certbot config can start continue
systemctl restart nginx

# Run certbot to create and associate certificates with currenly public IP (must have tcp 80 and 443 open to work)
certbot --nginx -n -d $LE_DNS_NAME --email $LE_EMAIL --agree-tos --redirect --hsts
echo -e 
echo -e "${GREY}Let's Encrypt successfully installed, but check for any errors above (DNS & firewall are the usual culprits).${GREY}"
if [ $? -ne 0 ]; then
	echo -e "${RED}Failed. See ${LOG_LOCATION}${GREY}" 1>&2
	exit 1
	else
	echo -e "${LGREEN}OK${GREY}"
	echo
fi

# Select a random daily time to schedule a daily check for Let's Encrypt certificates due to expire in next 30 days.
# If are any due to expire within a 30 day window, Certbot will attempt to renew automatically renew.
echo -e "${GREY}Scheduling automatic certificate renewals for certificates with < 30 days till expiry.)${GREY}"
#Dump out the current crontab
crontab -l > cron_1
# Remove any previosly added certbot renewal entries
sed -i '/# certbot renew/d' cron_1
# Randomly choose a daily update schedule and append this to the cron schedule
HOUR=$(shuf -i 0-23 -n 1)
MINUTE=$(shuf -i 0-59 -n 1)
echo "${MINUTE} ${HOUR} * * * /usr/bin/certbot renew --quiet --pre-hook 'service nginx stop' --post-hook 'service nginx start'" >> cron_1
# Overwrite old cron settings and cleanup
crontab cron_1
rm cron_1
if [ $? -ne 0 ]; then
	echo -e "${RED}Failed. See ${LOG_LOCATION}${GREY}" 1>&2
	exit 1
	else
	echo -e "${LGREEN}OK${GREY}"
	echo
fi

# Reload everything once again
echo -e "${GREY}Restaring Guacamole & Ngnix..."
sudo systemctl restart $TOMCAT_VERSION
sudo systemctl restart guacd
sudo systemctl restart nginx
if [ $? -ne 0 ]; then
	echo -e "${RED}Failed. See ${LOG_LOCATION}${GREY}" 1>&2
	exit 1
	else
	echo -e "${LGREEN}OK${GREY}"
fi

# Done
echo -e ${NC}