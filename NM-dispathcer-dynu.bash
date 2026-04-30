#!/bin/bash
#view logs via `sudo journalctl --follow --identifier=nm-dispatcher`
set | grep NM
if [[ "$NM_DISPATCHER_ACTION" = "dhcp6-change" ]]
then
        ip -6 a
        ip -6 r
        set | grep CONNECTION
        set | grep IP
        curl --max-time 5 --retry 5 "https://api-ipv6.dynu.com/nic/update?hostname=skalam6.mywire.org&password=sha256_of_pwd_without_\n"
fi
