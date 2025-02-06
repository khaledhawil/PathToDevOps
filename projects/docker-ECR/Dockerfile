FROM ubuntu:24.04

RUN apt-get update && \
 apt-get install -y apache2 
RUN echo 'Hello From The docker container on Ubuntu!' > /var/www/html/index.html

RUN echo '. /etc/apache2/envvars' > /root/run_apache.sh && \
echo 'mkdir -p /var/run/apache2' >> /root/run_apache.sh && \
echo '/usr/sbin/apache2 -D FOREGROUND' >> /root/run_apache.sh && \
chmod 755 /root/run_apache.sh

EXPOSE 80

CMD ["/root/run_apache.sh"]