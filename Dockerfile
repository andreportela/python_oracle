FROM oraclelinux:7-slim

LABEL maintainer="portela.eng@gmail.com"

ENV SRC_FOLDER /usr/src
ENV APP_FOLDER /app
ENV APP_USER kafka
ENV APP_USER_GROUP kafka
ENV ORACLE_VERSION 18.3
ENV PY_VERSION 3.7.3
ENV PYTHON_PKG Python-${PY_VERSION}.tgz
ENV PYTHON_FOLDER ${SRC_FOLDER}/Python-${PY_VERSION}

RUN mkdir -p ${SRC_FOLDER} && \
    yum install -y oracle-epel-release-el7 gcc openssl-devel bzip2-devel \
        libffi-devel wget tar gzip make oraclelinux-developer-release-el7 && \
    wget --output-document=${SRC_FOLDER}/${PYTHON_PKG} \
        https://www.python.org/ftp/python/${PY_VERSION}/${PYTHON_PKG} && \
    cd ${SRC_FOLDER} && \
    tar xzf ${PYTHON_PKG} && \
    cd ${PYTHON_FOLDER} && \
    ./configure --enable-optimizations && \
    make install && \
    yum install -y python-cx_Oracle && \
    echo /usr/lib/oracle/${ORACLE_VERSION}/client64/lib > /etc/ld.so.conf.d/oracle-instantclient.conf && \
    ldconfig && \
    pip3 install --upgrade pip && \
    pip3 install --no-cache-dir cx_Oracle==7.1.3 sqlalchemy==1.3.5 && \
    groupadd -r ${APP_USER_GROUP} && \
    useradd -r -g ${APP_USER_GROUP} ${APP_USER} && \
    rm -r ${PYTHON_FOLDER}* && \
    yum erase -y gcc wget tar gzip make && \
    yum clean all && \
    mkdir -p ${APP_FOLDER} && \
    chown -R ${APP_USER}:${APP_USER_GROUP} ${APP_FOLDER} && \
    chown -R ${APP_USER}:${APP_USER_GROUP} /usr/local

USER ${APP_USER}
WORKDIR ${APP_FOLDER}
