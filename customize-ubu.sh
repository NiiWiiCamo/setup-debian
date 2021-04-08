#!/bin/bash

## add programs
sudo bash -c '
apt update && apt upgrade -y
apt install curl htop nano screen sudo vlan -y
'

## setup skel and cron folders
sudo bash -c '
mkdir -p /etc/skel/
mkdir -p /etc/skel/.cronjobs/15min
mkdir -p /etc/skel/.cronjobs/hourly
mkdir -p /etc/skel/.cronjobs/4aday
mkdir -p /etc/skel/.cronjobs/daily
mkdir -p /etc/skel/.cronjobs/monthly
mkdir -p /etc/skel/.cronjobs/startup
mkdir -p /etc/periodic/startup
'

## setup cron folders for local user
mkdir -p ~/.cronjobs/15min
mkdir -p ~/.cronjobs/hourly
mkdir -p ~/.cronjobs/4aday
mkdir -p ~/.cronjobs/daily
mkdir -p ~/.cronjobs/monthly
mkdir -p ~/.cronjobs/startup


## add screen autoconnect
sudo bash -c '
cat <<EOF > /etc/skel/.profile
# check for default screen, create if necessary
if screen -ls | grep -q "default"; then
echo "default screen found. connecting..."
screen -x default
else
echo "no default screen found. creating..."
screen -S default
fi
EOF
'

cp /etc/skel/.profile ~/.profile

## create .ssh folder for skel
sudo mkdir -p /etc/skel/.ssh

## create .ssh user folder
mkdir -p ~/.ssh

# setup user cron
sudo bash -c '
cat <<EOF > /etc/skel/usercron
# do daily/weekly/monthly maintenance
# min	hour	day	month	weekday	command
*/15	*	*	*	*	run-parts ~/.cronjobs/15min
0	*	*	*	*	run-parts ~/.cronjobs/hourly
0	*/6	*	*	*	run-parts ~/.cronjobs/4aday
0	2	*	*	*	run-parts ~/.cronjobs/daily
0	3	*	*	6	run-parts ~/.cronjobs/weekly
0	5	1	*	*	run-parts ~/.cronjobs/monthly
@reboot					run-parts ~/.cronjobs/startup
# custom cronjobs:
EOF
'
cp /etc/skel/usercron ~/usercron


## setup root cron
sudo bash -c '
cat <<EOF > /rootcron
# do daily/weekly/monthly maintenance
# min	hour	day	month	weekday	command
*/15	*	*	*	*	run-parts /etc/periodic/15min
0	*	*	*	*	run-parts /etc/periodic/hourly
0	*/6	*	*	*	run-parts /etc/periodic/4aday
0	2	*	*	*	run-parts /etc/periodic/daily
0	3	*	*	6	run-parts /etc/periodic/weekly
0	5	1	*	*	run-parts /etc/periodic/monthly
@reboot					run-parts /etc/periodic/startup
# custom cronjobs:
EOF
'

sudo crontab /rootcron
sudo rm /rootcron

## user setup
cd ~ && curl -sSL https://raw.githubusercontent.com/NiiWiiCamo/ssh/master/get-keys.bash | tee ~/.cronjobs/4aday/get-ssh-keys | tee ~/.cronjobs/startup/get-ssh-keys | bash && chmod +x ~/.cronjobs/4aday/*; chmod +x ~/.cronjobs/startup/*; crontab ~/usercron && rm ~/usercron

## setup sshd_config
sudo sed -i 's/\#PermitRootLogin prohibit-password/PermitRootLogin no/g' /etc/ssh/sshd_config
sudo sed -i 's/\#PubkeyAuthentication yes/PubkeyAuthentication yes/g' /etc/ssh/sshd_config
sudo sed -i 's/\#PasswordAuthentication yes/PasswordAuthentication no/g' /etc/ssh/sshd_config
sudo sed -i 's/\#PermitEmptyPasswords no/PermitEmptyPasswords no/g' /etc/ssh/sshd_config
