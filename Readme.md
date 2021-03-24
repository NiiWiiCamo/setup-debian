# setup-debian
Debian setup script
This script sets up debian ready for use. This setup is mainly for my own use, as it automatically sets up openssh with my ssh keys. You can substitute your own, the username gets read. Look at the script to see what actually happens ;=

1. install debian with ssh
2. reboot
3. wget -O customize-deb.sh https://raw.githubusercontent.com/NiiWiiCamo/setup-debian/main/customize-deb.sh && bash customize.sh
