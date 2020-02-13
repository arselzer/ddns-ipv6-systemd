#!/bin/bash
# in /etc/ddclient.conf:
# postscript=/opt/scripts/update_ipv6.sh

# Originally taken from https://gist.github.com/dominikholler/aec112a2ee05288588895120f41189d7

function update_domain() {
  DOMAIN=$1
  USERNAME=$2
  PASSWORD=$3
  SERVER=$4
  DEVICE="dev enp4s0"
  URL=https://$SERVER/nic/update
  FORCE_GET="-X GET -G"
  DNS_SERVER=@2606:4700:4700::1111 # bypass DNS rebinding protection
  VERBOSITY="-v"
  LOGGER="logger -t $(basename $0 .sh)"

  # Get the IPv6 address from the network interface
  ACTUAL_ADDRESS=$(dig $DOMAIN AAAA $DNS_SERVER +short)
  # Alternatively get it from the no-ip service
  #ACTUAL_ADDRESS=$(curl "http://ip1.dynupdate6.no-ip.com/")
  TARGET_ADDRESS=$(\
          ip -6 -o addr show $DEVICE scope global dynamic -deprecated -temporary \
          | grep -v " inet6 f[cd]" | head -n 1 | cut -d " " -f 7 | cut -d / -f 1)

  echo $ACTUAL_ADDRESS

  echo $TARGET_ADDRESS

  if [ "$ACTUAL_ADDRESS" != "$TARGET_ADDRESS" ]; then
    curl $VERBOSITY $FORCE_GET \
      --user $USERNAME:$PASSWORD \
      --data-urlencode hostname=$DOMAIN \
      --data-urlencode myip=$TARGET_ADDRESS $URL | \
    xargs echo updating $DOMAIN from $ACTUAL_ADDRESS to $TARGET_ADDRESS: | \
    $LOGGER
  fi
}

# TODO global config file
update_domain x.ddns.net username password dynupdate.no-ip.com

