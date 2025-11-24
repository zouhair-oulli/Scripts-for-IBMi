#!/QOpenSys/pkgs/bin/bash

echo " "
echo -e "\e[34mHello $USER, you are running a script to configure PASE, shell and SSH permissions on IBM i (initial setup)\e[0m"
echo " "
echo -e "\e[31mRemark: In case of a typing error, or if you would like to cancel the program, press Ctrl + C\e[0m"
echo " "

# prompt and read user profil
read -p "Please, enter the user profil you would like to configure: " -r user
echo " "
echo "------------------------------------------------------------------------------------------------------------"
echo " "

# check if user string is empty
if [[ -z "$user" ]]; then
   printf '\e[31m%s\e[0m\n' "No user profile entered! Please try again."
    exit 1
else

# if string is not empty, show what the user typed
printf "\e[36m* Setting up PASE and shell environment for user %s\e[0m\n" "'$user' *"
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
echo "------------------------------------------------------------------------------------------------------------"
echo " "

# change ownership and authorities
echo -e "\e[32m ==> Changing ownership and permissions for /home/$user + .profile + .ssh + authorized_keys \e[0m"
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
echo " "

# configure .profile (PATH)
echo -e "\e[32m==> Configuring .profile (PATH)\e[0m"
echo 'export PATH="$HOME/.local/bin:/QOpenSys/pkgs/bin:$PATH:/QOpenSys/usr/bin:/usr/bin"' >> /home/$user/.profile
echo 'Current PATH is now: "$HOME/.local/bin:/QOpenSys/pkgs/bin:$PATH:/QOpenSys/usr/bin:/usr/bin'
echo "------------------------------------------------------------------------------------------------------------"
echo " "

# specify path name of the home directory on IBM i OS and character conversion to UTF-8
echo -e "\e[32m==> Specifying path name of HOMEDIR and character conversion to UTF-8\e[0m"
/QOpenSys/usr/bin/system "CHGUSRPRF USRPRF($user) HOMEDIR('/home/$user')"
/QOpenSys/usr/bin/setccsid 1208 $HOME/.profile
echo "------------------------------------------------------------------------------------------------------------"
echo " "

# configure BASH
echo -e "\e[32m==> Configuring BASH\e[0m"
/QOpenSys/pkgs/bin/chsh -s /QOpenSys/pkgs/bin/bash $user
echo "Current shell is now: /QOpenSys/pkgs/bin/bash"
echo "------------------------------------------------------------------------------------------------------------"
echo " "

# configure .profile (prompt string 1)
echo -e "\e[32m==> Configuring prompt string\e[0m"
echo 'export PS1="\[\e[92m\]\u@\h \$ \[\e[0m\]"' >> /home/$user/.profile
echo "Prompt string is now: $USER@$(hostname) $"
echo "------------------------------------------------------------------------------------------------------------"
echo " "

# configure .profile (colors)
echo -e "\e[32m==> Configuring .profile (colors)\e[0m"
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

echo " "
echo -e "\e[34mEND OF PROGRAM MESSAGE: Setting up the PASE and shell environment for the user profile $user is finished :)\e[0m"
echo " "
echo -e "\e[31mVERY IMPORTRANT: If you launched this script for the user you are signed in with, apply the configuration by relogging or launching a new shell with command \"exec \$SHELL -l\"\e[0m"

echo " "

fi
