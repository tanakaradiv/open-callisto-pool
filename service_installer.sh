#!/bin/bash
#will make the services for the pool, based on the pool exe location of /usr/local/bin/poolbin
user="clopool"
config_dir="/home/$user/open-callisto-pool/configs"
poolbinary="/home/$user/open-callisto-pool/build/bin/open-callisto-pool"

if [ ! -e $config_dir ] || [ ! -e $poolbinary ]
then
echo missing config dir or pool binary, exiting
exit 1
fi

echo "
[Unit]
Description=pool-api

[Service]
Type=simple
ExecStart=$poolbinary $config_dir/api.json

[Install]
WantedBy=multi-user.target
">/etc/systemd/system/pool-api.service

echo "
[Unit]
Description=pool-stratum2b

[Service]
Type=simple
ExecStart=$poolbinary $config_dir/stratum2b.json

[Install]
WantedBy=multi-user.target
">/etc/systemd/system/pool-stratum2b.service


echo "
[Unit]
Description=pool-stratum4b

[Service]
Type=simple
ExecStart=$poolbinary $config_dir/stratum4b.json

[Install]
WantedBy=multi-user.target
">/etc/systemd/system/pool-stratum4b.service


echo "
[Unit]
Description=pool-stratum9b


[Service]
Type=simple
ExecStart=$poolbinary $config_dir/stratum9b.json

[Install]
WantedBy=multi-user.target
">/etc/systemd/system/pool-stratum9b.service


echo "
[Unit]
Description=pool-unlocker


[Service]
Type=simple
ExecStart=$poolbinary $config_dir/unlocker.json

[Install]
WantedBy=multi-user.target
">/etc/systemd/system/pool-unlocker.service

echo "
[Unit]
Description=pool-payout

[Service]
Type=simple
ExecStart=$poolbinary $config_dir/payout.json

[Install]
WantedBy=multi-user.target
">/etc/systemd/system/pool-payout.service

systemctl daemon-reload

systemctl enable pool-api
systemctl enable pool-stratum2b
systemctl enable pool-stratum4b
systemctl enable pool-stratum9b
systemctl enable pool-unlocker
systemctl enable pool-payout

systemctl start pool-api
systemctl start pool-stratum2b
systemctl start pool-stratum4b
systemctl start pool-stratum9b
systemctl start pool-unlocker
systemctl start pool-payout



