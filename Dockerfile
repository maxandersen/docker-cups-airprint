FROM centos:7

LABEL maintainer="max"

RUN yum install -y epel-release && yum update -y
RUN yum --enablerepo=epel install -y inotify-tools

RUN yum install -y \
    cups cups-pdf \
    inotify-tools \
    python-cups && \
    yum clean all && \
    rm -rf /var/cache/yum

# This will use port 631
EXPOSE 631

# We want a mount for these
VOLUME /config
VOLUME /services

# Add scripts
ADD root /
RUN chmod +x /root/*


# Baked-in config file changes
RUN sed -i 's/Listen localhost:631/Listen 0.0.0.0:631/' /etc/cups/cupsd.conf && \
	sed -i 's/Browsing Off/Browsing On/' /etc/cups/cupsd.conf && \
	sed -i 's/<Location \/>/<Location \/>\n  Allow All/' /etc/cups/cupsd.conf && \
	sed -i 's/<Location \/admin>/<Location \/admin>\n  Allow All\n  Require user @SYSTEM/' /etc/cups/cupsd.conf && \
	sed -i 's/<Location \/admin\/conf>/<Location \/admin\/conf>\n  Allow All/' /etc/cups/cupsd.conf && \
	echo "ServerAlias *" >> /etc/cups/cupsd.conf && \
	echo "DefaultEncryption Never" >> /etc/cups/cupsd.conf

CMD ["/root/run_cups.sh"]
