FROM oraclelinux:7-slim

LABEL maintainer="portela.eng@gmail.com"

ENV SRC_FOLDER /usr/src
ENV APP_FOLDER /app
ENV APP_USER kafka
ENV APP_USER_GROUP kafka
ENV ORACLE_VERSION 18.3
ENV PY_VERSION 3.7.4
ENV PYTHON_PKG Python-${PY_VERSION}.tgz
ENV PYTHON_FOLDER ${SRC_FOLDER}/Python-${PY_VERSION}

RUN mkdir -p ${SRC_FOLDER} && \
    yum install -y  https://download.postgresql.org/pub/repos/yum/11/redhat/rhel-7-x86_64/pgdg-centos11-11-2.noarch.rpm && \
    yum install -y oracle-epel-release-el7 gcc openssl-devel bzip2-devel \
        libffi-devel wget tar gzip make oraclelinux-developer-release-el7 postgresql11-devel postgresql11-libs && \
    wget --output-document=${SRC_FOLDER}/${PYTHON_PKG} \
        https://www.python.org/ftp/python/${PY_VERSION}/${PYTHON_PKG} && \
    cd ${SRC_FOLDER} && \
    tar xzf ${PYTHON_PKG} && \
    cd ${PYTHON_FOLDER} && \
    ./configure --enable-optimizations && \
    make install && \
    yum install -y python-cx_Oracle && \
    echo /usr/lib/oracle/${ORACLE_VERSION}/client64/lib > /etc/ld.so.conf.d/oracle-instantclient.conf && \
    export PATH=$PATH:/usr/pgsql-11/bin && \
    ldconfig && \
    pip3 install --upgrade pip && \
    pip3 install --no-cache-dir cx_Oracle==7.1.3 sqlalchemy==1.3.5 psycopg2==2.8.3 && \
    groupadd -r ${APP_USER_GROUP} && \
    useradd -r -g ${APP_USER_GROUP} ${APP_USER} && \
    rm -r ${PYTHON_FOLDER}* && \
    yum erase -y gcc wget make postgresql11-devel && \
    yum clean all && \
    mkdir -p ${APP_FOLDER} && \
    chown -R ${APP_USER}:${APP_USER_GROUP} ${APP_FOLDER} && \
    chown -R ${APP_USER}:${APP_USER_GROUP} /usr/local

USER ${APP_USER}
WORKDIR ${APP_FOLDER}
