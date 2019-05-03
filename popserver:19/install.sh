#! /bin/bash
# @edt ASIX M11 2018-2019
#Franlin colque
# instal.lacio pop
# -------------------------------------
useradd pere
useradd marta
echo "pere" | passwd --stdin pere
echo "marta" | passwd --stdin marta
cp /opt/docker/pere /var/spool/mail/pere
cp /opt/docker/marta /var/spool/mail/marta
chown -R pere.pere /var/spool/mail/pere
chown -R marta.marta /var/spool/mail/marta

#------------------------------------------
echo "@edt ASIX M11-SAD" > /var/www/index.html
echo "Benvinguts al vsftpd" > /var/ftp/hola.pdf
echo "directori public" > /var/ftp/pub/info.txt
echo "Benvingutts al servei tftp" > /var/lib/tftpboot/hola.txt
echo "llista de fitxers del tftp" > /var/lib/tftpboot/llista.txt
/usr/bin/ssh-keygen -A
touch /var/run/tftp.sock
cp /opt/docker/xinetd.d/* /etc/xinetd.d/
