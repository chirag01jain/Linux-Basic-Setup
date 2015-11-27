#!/bin/bash

# Author : Chirag Jain
# Copyright (c) Amaeka
# For Redhat, Cent0S and Fedora distros

# IMP - Check exit status before using rm command, 0 -> true => cd newDir; echo $?

update_Server
set_Hostname
set_TimeZone
secure_Server


function update_Server() {
  echo "Do you want to update your server yes/no?"
  read answer
  if [ $answer == "yes" ]; then
      yum update -y
  fi
}

function set_Hostname() {

    echo "Define your server hostname (FQDN format):"
    read myHost
    newHostname=`echo "$myHost" | awk -F"." '{ print $1 }'`
    sed -i "s/`hostname --fqdn`/$myHost/" /etc/sysconfig/network /etc/hosts
    sed -i "s/`hostname`/$newHostname/g" /etc/hosts
    hostname $newHostname
    service network restart
      # /etc/sysconfig/network - Specify desired network configuration like Networking, Gateway, Gatewaydev, hostname (fqdn), NISDOMAIN,
      #https://access.redhat.com/documentation/en-US/Red_Hat_Enterprise_Linux/4/html/Reference_Guide/ch-networkscripts.html
}

function set_TimeZone(){
  echo "Selecting Indian TimeZone"
  # Create soft link of localtime
  ln -sf /usr/share/zoneinfo/Asia/Kolkata /etc/localtime ## for Indian Time
  # Syntex ln -sf sourceFile softLinkFile :: Remove softlink -> rm /etc/localtime
}

function install_Package() {
  if rpm -q $1 &> /dev/null ; then
    echo "$1 already exist"
  else
    yum install $1 -y
}

function secure_Server() {
    # 1. Update Your System–Frequently :: updateServer
    # 2. Automatic Security Updates

        setup_Automatic_Update

    # 3. Add a Limited User Account
        echo "Enter username :: Limited User Account >> "
        read username
        useradd $username && passwd $username
        # Add user to wheel group for sudo privileges:, logs in /var/log/auth.log
        usermod -aG wheel $username

    # 4. Harden SSH Access using cryptographic key-pair, not easy to brute-force

        ssh_Key_Authentication
        # /etc/ssh/sshd_config - SSH config file, ~/.ssh => Key Pair folder

    # 5. Enable sudo
          install_Package sudo
          visudo
          ## Add the user You want to provide sudo privileges
          /*
            user ALL=(ALL) ALL
            jupitor ALL=(ALL) ALL
            %groupName ALL=(ALL) ALL
            %sys ALL = cmnd_alias , STORAGE
          */


      # 6. Fail2Ban for SSH Login Protection : App ban IP if too many log failure https://www.linode.com/docs/security/using-fail2ban-for-security

      # 7. Remove Unused Network-Facing Services
      install_Package net-tools
      netstat -tulpn
      # UDP are stateless, TCP has states LISTEN, ESTABLISHED and CLOSE_WAIT
      # Remove unnecessary packages yum remove

      # 8. Configure a firewall :: iptables
      firewall
}
function setup_Automatic_Update() {
    # Applies only to packages sourced from repos, not self-compiled applications
    ## CentOS uses yum-cron for automatic updates.

    install_Package yum-cron

    # Enable Automatic update flag
    file='/etc/yum/yum-cron.conf';

    grep -q '^apply_updates' $file &&
    sed -i 's/^apply_updates.*/apply_updates=yes/' $file ||
    echo 'apply_updates=yes' >> $file
}

function ssh_Key_Authentication() {

  # ----------------------------------
          # (A) Create an Authentication Key-pair
          # Can be created from local system (putty) or from Linux
          # https://www.youtube.com/watch?v=LySsRcTOYiI
          # https://www.linode.com/docs/security/use-public-key-authentication-with-ssh#windows-operating-system
  # ----------------------------------

  # On Server

  cd ~/.ssh/ || mkdir -m 700 ~/.ssh && cd ~/.ssh/ && touch authorized_keys

    echo "Please select your O.S (type 'l' for Linux and 'W' for windows)"
    read osType
    if [ $osType == 'l' ]; then {
      # Linux Local System => Public (server) and Private (Laptop)
      cd ~/.ssh/ || mkdir ~/.ssh && cd ~/.ssh/ && ssh-keygen -t rsa -b 1024
      # Copy pub key to server, id_rsa, id_rsa.pub :: pr ssh-copy-id
      scp ~/.ssh/id_rsa.pub jupitor@amaeka.com:~/.ssh/pub_key.pub
      # On Server
      echo `cat ~/.ssh/pub_key.pub` >> ~/.ssh/authorized_keys
      }
    else {
      # Download putty and puttygen.exe
      # 1. Generate public and private key pair in puttygen.exe and save it
      # 2. Copy and save the content of pub key in authprized_keys file on server
    }

    # Disable SSH root password authentication
    search="#PermitRootLogin yes"
    replaceTo="PermitRootLogin no"
    file="/etc/ssh/sshd_config"
    grep -q $search file && sed -i "s/$search/$replaceTo/" file

    # Disallow root logins over SSH, means first login to restricted user -> sudo
    # Set :: PasswordAuthentication no
    service ssh restart
    # CentOS 7 :: systemctl restart sshd

}

function firewall(){
  # https://www.linode.com/docs/security/securing-your-server#configure-a-firewall
    install_Package iptables
    iptables -L  # Current iptables -L
    # save ipv4 basic conf in /tmp/v4
    iptables-restore < /tmp/v4
    ip6tables-restore < /tmp/v6
  # Save firewall rules to /etc/sysconfig/iptables & /etc/sysconfig/ip6tables
    service iptables save
    service ip6tables save
    rm -f /tmp/{v4,v6}

    iptables -vL --line-numbers
    # Use below command to add more rules
    # Insert new rule '9' is rule number
    iptables -I INPUT 9 -p tcp --dport 3306 -j ACCEPT

    # Replace a rule
    iptables -R INPUT 11 -m limit --limit 3/min -j LOG --log-prefix "iptables_INPUT_denied: " --log-level 7

    # Delete a rule
    iptables -D INPUT 9
}
