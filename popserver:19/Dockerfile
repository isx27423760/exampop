# Version: 0.0.1
# @edt M11 2018-2019
# mail server pop franlin colque
# -------------------------------------
FROM fedora:27
LABEL author="@edt ASIX M11-SAD"
LABEL description="SSH Server Curs 2018-2019"
RUN dnf -y install telnet xinetd iproute iputils nmap uw-imap procps net-tools passwd httpd vsftpd openssh-server tftp-server 
RUN mkdir /opt/docker
#RUN mkdir /opt/docker/xinetd.d
#COPY xinetd.d/* /opt/docker/xinetd.d/
ADD * /opt/docker/
RUN chmod +x /opt/docker/startup.sh /opt/docker/install.sh
WORKDIR /opt/docker
CMD [ "/opt/docker/startup.sh" ]

