#!/bin/bash

## username to be created
echo "Enter name for normal user with sudo:"
read newuser

## add programs
apt update && apt upgrade
apt install curl htop nano screen sudo vlan

## setup skel and cron folders
mkdir -p /etc/skel/
mkdir -p /etc/skel/.cronjobs/15min
mkdir -p /etc/skel/.cronjobs/hourly
mkdir -p /etc/skel/.cronjobs/4aday
mkdir -p /etc/skel/.cronjobs/daily
mkdir -p /etc/skel/.cronjobs/monthly
mkdir -p /etc/skel/.cronjobs/startup
mkdir -p /etc/periodic/startup

## add screen autoconnect
cat <<EOF > /etc/skel/.bash_profile
# test if you are not in screen session, then reattaches first available or creates new session
if [ -z "$STY" ]; then screen -RR; fi
EOF

## set motd to display on entering bash (also works in screen)
echo "cat /etc/motd" > /etc/skel/.bashrc

## create .ssh folder for skel
mkdir -p /etc/skel/.ssh

# setup user cron
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

## setup root cron
cat <<EOF > rootcron
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

crontab rootcron
rm rootcron

## add user
adduser $newuser
usermod -aG sudo $newuser


## execute as new user
su $newuser -c "cd ~; curl -sSL https://raw.githubusercontent.com/NiiWiiCamo/ssh/master/get-keys.bash | tee ~/.cronjobs/4aday/get-ssh-keys | tee ~/.cronjobs/startup/get-ssh-keys | bash; chmod +x ~/.cronjobs/periodic/4aday/*; chmod +x ~/.cronjobs/startup/*; crontab ~/usercron; rm ~/usercron"

## setup sshd_config
sed -i 's/\#PermitRootLogin prohibit-password/PermitRootLogin no/g' /etc/ssh/sshd_config
sed -i 's/\#PubkeyAuthentication yes/PubkeyAuthentication yes/g' /etc/ssh/sshd_config
sed -i 's/\#PasswordAuthentication yes/PasswordAuthentication no/g' /etc/ssh/sshd_config
sed -i 's/\#PermitEmptyPasswords no/PermitEmptyPasswords no/g' /etc/ssh/sshd_config
