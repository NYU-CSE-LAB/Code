# createusers.sh
# FILE FORMAT: studentemail@students.poly.edu PASSWORD FIRST_NAME LAST_NAME
STUDENTS=/root/list
SEMESTER=SPRING2017
GROUPNAME=spring2017_sd

cat $STUDENTS | while read line; do
        user=`echo $line | awk -F@ '{print $1}'`
        pass=`echo $line | awk '{print $2}'`
        full_name=`echo $line | awk '{print $3, $4}'`

cat /etc/passwd | grep -w $user
return=`echo "$?"`
        if [ "$return" = "1" ];then
                useradd -m -c "$full_name" -s /bin/bash -g $GROUPNAME  -d /home/$SEMESTER/$user $user
                echo "$pass" | passwd --stdin $user

                for i in .bashrc .bash_profile .bash_logout; do
                        cp /etc/skel/$i /home/$SEMESTER/$user/
                done
		# Make www directory in users home directory, to be served by Apache
                mkdir /home/$SEMESTER/$user/www
		#Copy example html to www
		cp /root/index.html /home/$SEMESTER/$user/www
                chown -R $user:apache /home/$SEMESTER/$user/www
                chmod -R 701 /home/$SEMESTER/$user  #Readable only by owner
                chmod -R 750 /home/$SEMESTER/$user/www
		#Fix the selinux context
		chcon -Rv --type=httpd_sys_content_t /home/SPRING2017/*/www
		# Make the context permanent
		semanage fcontext -a -t httpd_sys_content_t "/home/SPRING2017/*/www(/.*)?"
                #echo "user" >> maillist.$1`date +%m-%d-%y`
        else
                echo "$user exists"
        fi
done
