#!/bin/bash
#view logs via `sudo journalctl --follow --identifier=nm-dispatcher`
IP=1.1.8.1
DEPENDENT=some_con
set | grep 'NM\|CONNECTION'
if nmcli -t -f active c show $CONNECTION_ID | grep -qw "$IP"; then
    echo "IP $IP is present"
    if [[ -z "`nmcli -t -f active c show $DEPENDENT`" ]]; then
        echo "Connection $DEPENDENT is not active, activating"
        nmcli c up $DEPENDENT
    fi
else
    echo "IP $IP not found"
    if [[ -n "`nmcli -t -f active c show $DEPENDENT`" ]]; then
        echo "Connection $DEPENDENT is active, DEactivating"
        nmcli c down $DEPENDENT
    fi
fi
