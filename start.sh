#!/bin/bash
set -u

# TODO: echo -n "Enter your masternode genkey respond and Hit [ENTER]: "
# read mngenkey

BOOTSTRAP='bootstrap.tar.gz'

#
# Step 8/10 - Downloading bootstrap file
#
mkdir -p /home/bitsend/.bitsend
chown -R bitsend:bitsend /home/bitsend
cd /home/bitsend/.bitsend
printf "** Step 8/10 - Downloading bootstrap file ***"
if [ ! -f /home/bitsend/.bitsend/${BOOTSTRAP} ] && [ "$(curl -Is 207.246.121.232:1337/${BOOTSTRAP} | head -n 1 | tr -d '\r\n')" = "HTTP/1.1 200 OK" ] ; then \
        sudo -u bitsend wget 207.246.121.232:1337/$BOOTSTRAP; \
        sudo -u bitsend tar -xvzf $BOOTSTRAP; \
        rm $BOOTSTRAP; \
fi
printf "*** Done 8/10 ***"

#
# Step 9/10 - Starting BitSend Service
#
# Hint: docker not supported systemd, use of supervisord
printf "*** Step 9/10 - Starting BitSend Service ***\n"
exec /usr/bin/supervisord -n -c /etc/supervisor/supervisord.conf
