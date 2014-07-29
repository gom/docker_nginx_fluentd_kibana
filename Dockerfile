FROM ubuntu
MAINTAINER gom "gomgom68@gmail.com"

# locale
#RUN echo "Asia/Tokyo" > /etc/timezone && \
#    rm -f /etc/localtime && \
#    ln -s /usr/share/zoneinfo/Asia/Tokyo /etc/localtime


# td-agent
ADD http://packages.treasure-data.com/debian/RPM-GPG-KEY-td-agent /var/tmp/
RUN apt-key add /var/tmp/RPM-GPG-KEY-td-agent && \
    echo "deb http://packages.treasure-data.com/precise/ precise contrib" > /etc/apt/sources.list.d/treasure-data.list

# elasticsearch
ADD http://packages.elasticsearch.org/GPG-KEY-elasticsearch /var/tmp/
RUN apt-key add /var/tmp/GPG-KEY-elasticsearch && \
    echo "deb http://packages.elasticsearch.org/elasticsearch/1.3/debian stable main" > /etc/apt/sources.list.d/elasticsearch.list

# apt-get
RUN sed -i s/us.archive.ubuntu.com/ftp.jaist.ac.jp/ /etc/apt/sources.list && \
    apt-get update && \
    apt-get install -qq -y --force-yes td-agent elasticsearch nginx openjdk-7-jre-headless libcurl4-openssl-dev make openssh-server 

# kibana
ENV _KIBANA_FILENAME kibana-3.0.0milestone5
ADD https://download.elasticsearch.org/kibana/kibana/${_KIBANA_FILENAME}.tar.gz /var/tmp/ 
RUN cd /var/tmp/ && \
    tar xzf /var/tmp/${_KIBANA_FILENAME}.tar.gz && \
    mv /var/tmp/${_KIBANA_FILENAME} /usr/share/nginx/html/kibana

RUN /usr/share/elasticsearch/bin/plugin -i elasticsearch/marvel/latest
RUN /usr/lib/fluent/ruby/bin/fluent-gem install --no-ri --no-rdoc fluent-plugin-elasticsearch 

# sshd
RUN mkdir -p /var/run/sshd
RUN useradd --create-home -s /bin/bash ubuntu ; \
    adduser ubuntu sudo ; \
    echo "ubuntu:ubuntu" | chpasswd;

# add files
ADD conf/td-agent.conf /etc/td-agent/
ADD conf/nginx.conf /etc/nginx/conf.d/kibana.conf
RUN rm /etc/nginx/sites-enabled/default
ADD bin/run.sh /usr/local/bin/

RUN LOG_DIR=/var/log/nginx/ && rm -rf $LOG_DIR && mkdir -p $LOG_DIR && chmod -R 777 $LOG_DIR

EXPOSE 22 80 9200

# sshd with foreground
CMD ["/usr/local/bin/run.sh"]
