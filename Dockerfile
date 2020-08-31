FROM centos:7.5.1804

MAINTAINER RP

RUN yum install -y epel-release && yum install -y nginx && yum clean all && rm -rf /var/cache/yum

#COPY blue.html /usr/share/nginx/html/index.html
COPY green.html /usr/share/nginx/html/index.html

EXPOSE 80

CMD ["nginx","-g","daemon off;"]
