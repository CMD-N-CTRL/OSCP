#!/bin/bash
#---------------------------------------------------------------------------#
# Name   = SUIDEnumerationScript                                            #
# Author = cmd-n-ctrl                                                       #
# Date   = 18/01/2018                                                       #
# Usage  = chmod 755 SUIDEnumerationScript.sh | ./SUIDEnumerationScript.sh  #
#---------------------------------------------------------------------------#

echo    "                                          "
echo -e "\e[32m#----------------------------------#"
echo -e "\e[32m#   \e[36m SUID Enumeration Script  \e[32m     #"
echo -e "\e[32m#----------------------------------#"
echo    "                                          "


#Find SUID files and store them in SUID_SCRIPT.txt
echo "[+] Dumping SUID files list into SUID_SCRIPT.txt.."
find / \( -perm -4000 \) -exec ls -ld {} \; 2>/dev/null | awk '{print $9}' > SUID_SCRIPT.txt
sleep 2

#loop through common linux binaries and then remove them from SUID_SCRIPT.txt
echo "[+] Trimming common SUID files from SUID_SCRIPT.txt..."

for bname in '/umount/d' '/su/d' '/mount/d' '/sudo/d' '/passwd/d' '/exim4/d' '/chfn/d' '/chsh/d' '/procmail/d' '/newgrp/d' '/ping/d' '/ntfs-3g/d' '/pppd/d' '/pkexec/d' '/ssh-keysign/d' '/dbus-daemon-launch-helper/d' '/uuidd/d' '/pt_chown/d' '/at/d' '/mtr/d' '/dmcrypt-get-device/d' '/X/d' '/traceroute6.iputils/d' '/polkit-resolve-exe-helper/d' '/polkit-set-default-helper/d' '/polkit-grant-helper-pam/d'

do
  sed -i $bname ./SUID_SCRIPT.txt
done
sleep 2

echo "[+] Preform strings on the following binaries.."
echo "                                                  "  
echo "#------------------------------------------------#"
for line in $(cat SUID_SCRIPT.txt); do                              
echo " * "$line
done 
echo "#------------------------------------------------#"
echo "                                                  " 
sleep 5

# Perform string command on uncommon SUID binaries
for line in $(cat SUID_SCRIPT.txt); do 
  echo "             "
  echo "#------------------------------------------------#"
  echo $line
  echo "#------------------------------------------------#"
  strings $line
  echo "                                                  "
  sleep 5
done
echo    "                                     "
echo -e "\e[32m#-----------------------------#"
echo -e "\e[32m#     \e[36m TASK COMPLETE!!!  \e[32m     #"
echo -e "\e[32m#-----------------------------#"
echo " 
