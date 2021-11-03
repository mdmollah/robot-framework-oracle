FROM christophettat/devops_coe_robot:latest 

LABEL description Robot Framework in Docker with Cx_Oracle and Instant Client.

ENV LDAP_VERSION 2.9.1
ENV CX_ORACLE 8.2.1
USER root

RUN apk del glibc* && \
apk --no-cache add libc6-compat libaio libnsl curl && \
cd /tmp && \
curl -o instantclient-basiclite.zip https://download.oracle.com/otn_software/linux/instantclient/instantclient-basiclite-linuxx64.zip -SL && \
unzip instantclient-basiclite.zip && \
mv instantclient*/ /usr/lib/instantclient && \
rm instantclient-basiclite.zip && \
ln -s /usr/lib/instantclient/libclntsh.so.19.1 /usr/lib/libclntsh.so && \
ln -s /usr/lib/instantclient/libocci.so.19.1 /usr/lib/libocci.so && \
ln -s /usr/lib/instantclient/libociicus.so /usr/lib/libociicus.so && \
ln -s /usr/lib/instantclient/libnnz19.so /usr/lib/libnnz19.so && \
ln -s /usr/lib/libnsl.so.2 /usr/lib/libnsl.so.1 && \
ln -s /lib/libc.so.6 /usr/lib/libresolv.so.2 && \
ln -s /lib/libc.so.6 /usr/lib/instantclient/libresolv.so.2 && \
ln -s /lib64/ld-linux-x86-64.so.2 /usr/lib/ld-linux-x86-64.so.2

ENV LD_LIBRARY_PATH /usr/lib/instantclient:$LD_LIBRARY_PATH:/usr/lib

RUN apk --no-cache upgrade \
  && apk --no-cache --virtual .build-deps add \
    g++ \
  && pip3 install \
    --no-cache-dir \
    ldap3==$LDAP_VERSION \
	cx_Oracle==$CX_ORACLE \
  && apk del --no-cache --update-cache .build-deps	

# Execute all robot tests
CMD ["run-tests-in-virtual-screen.sh"]
