#!/QOpenSys/pkgs/bin/bash

echo " "
echo -e "\e[36mHello $USER, you are running a script to configure PASE, shell and SSH permissions on IBM i (initial setup)\e[0m"
echo " "
echo -e "\e[31mNote: in case of a typing error, or if you would like to cancel the program, press Ctrl + C\e[0m"
echo " "

# prompt and read user profil
read -p "Please, enter the user profil you would like to configure: " -r user

# check if user string is empty
if [[ -z "$user" ]]; then
   printf '\e[31m%s\e[0m\n' "No user profile entered! Please try again."
    exit 1
else
echo "------------------------------------------------------------------------------------------------------------"
#echo " "

# creating and changing ownership/permissions
echo -e "\e[32m==> Creating, changing ownership and permissions for /home/$user + .profile + .ssh + authorized_keys \e[0m"

# is there home directory (nothing to do), if not (create it)
if ! test -d /home/$user; then
    echo " "
    echo "/home/$user doesn't exist - creating it..."
    mkdir /home/$user
fi

# is there .profile file (nothing to do), if not (create it)
if ! test -f /home/$user/.profile; then
    echo "/home/$user/.profile doesn't exist - creating it..."
    touch /home/$user/.profile
fi

# is there .ssh directory (nothing to do), if not (create it)
if ! test -d /home/$user/.ssh; then
    echo "/home/$user/.ssh doesn't exist - creating it..."
    mkdir /home/$user/.ssh
fi

# is there authorized_keys file (nothing to do), if not (create it)
if ! test -f /home/$user/.ssh/authorized_keys; then
    echo "/home/$user/.ssh/authorized_keys doesn't exist - creating it..."
    touch /home/$user/.ssh/authorized_keys
fi

chown -R $user /home/$user
chmod 700 /home/$user
chmod 600 /home/$user/.profile
chmod 700 /home/$user/.ssh
chmod 600 /home/$user/.ssh/authorized_keys
echo " "

# list permissions for .ssh and authorized_keys
echo -e "\e[31m* PERMISSIONS * \e[0m"
/QOpenSys/pkgs/bin/ls -ald --color=auto /home/$user
/QOpenSys/pkgs/bin/ls -ald --color=auto /home/$user/.profile
/QOpenSys/pkgs/bin/ls -ald --color=auto /home/$user/.ssh
/QOpenSys/pkgs/bin/ls -ald --color=auto /home/$user/.ssh/authorized_keys
echo "------------------------------------------------------------------------------------------------------------"
#echo " "

# configure PATH
echo -e "\e[32m==> Configuring PATH\e[0m"
echo 'export PATH="$HOME/.local/bin:/QOpenSys/pkgs/bin:$PATH:/QOpenSys/usr/bin:/usr/bin"' >> /home/$user/.profile
echo 'Current PATH is now: $HOME/.local/bin:/QOpenSys/pkgs/bin:$PATH:/QOpenSys/usr/bin:/usr/bin'
echo " "

# specify path name of the home directory on IBM i OS and character conversion to UTF-8
echo -e "\e[32m==> Specifying HOMEDIR path name and UTF-8 character conversion\e[0m"
/QOpenSys/usr/bin/system "CHGUSRPRF USRPRF($user) HOMEDIR('/home/$user')"
/QOpenSys/usr/bin/setccsid 1208 /home/$user/.profile
echo " "

# configure BASH
echo -e "\e[32m==> Installing and configuring BASH\e[0m"
/QOpenSys/pkgs/bin/yum install bash
/QOpenSys/pkgs/bin/chsh -s /QOpenSys/pkgs/bin/bash $user
echo "Current shell is now: /QOpenSys/pkgs/bin/bash"
echo " "

# configure PS1
echo -e "\e[32m==> Configuring PS1\e[0m"
echo 'export PS1="\[\e[92m\]\u@\h \w \$ \[\e[0m\]"' >> /home/$user/.profile
echo "Prompt string is now: $USER@$(hostname) pwd $"
echo " "

# configure colors
echo -e "\e[32m==> Configuring colors\e[0m"
cat <<EOF >> /home/$user/.profile
alias diff='diff --color=auto'
alias grep='grep --color=auto'
alias ls='ls --color=auto'
alias tree='tree -C'
EOF
/QOpenSys/pkgs/bin/ls -a --color=auto /home/$user
echo "------------------------------------------------------------------------------------------------------------"

# apply .profile configuration
source /home/$user/.profile

# end of script message
#echo " "
echo -e "\e[35mSetting up the PASE, shell and SSH permissions for the user $user is finished :)\e[0m"
echo " "
echo -e "\e[31mReminder: if you launched this script for the user you are signed in with, apply the configuration by relogging or launching a new shell with command \"exec \$SHELL -l\"\e[0m"
echo " "

fi
