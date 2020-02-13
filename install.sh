#!/bin/bash

cp ddns.service /etc/systemd/system/
cp ddns.timer /etc/systemd/system/

systemctl daemon-reload
systemctl enable ddns.timer
systemctl start ddns.timer
