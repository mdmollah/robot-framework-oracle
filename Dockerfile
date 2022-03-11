FROM python:3.9-alpine3.13

MAINTAINER Hassan Mollah <mdmollah@gmail.com>

LABEL description Robot Framework in Docker.

ENV ROBOT_UID 1000
ENV ROBOT_GID 1000

# reports directory environment variable
ENV ROBOT_REPORTS_DIR /opt/robotframework/reports

# tests directory environment variable
ENV ROBOT_TESTS_DIR /opt/robotframework/tests

# working directory environment variable
ENV ROBOT_WORK_DIR /opt/robotframework/temp

# Setup X Window Virtual Framebuffer
ENV SCREEN_COLOUR_DEPTH 24
ENV SCREEN_HEIGHT 1080
ENV SCREEN_WIDTH 1920

# Setup the timezone to use, defaults to UTC
ENV TZ UTC

# Set number of threads for parallel execution
# By default, no parallelisation
ENV ROBOT_THREADS 1

# Dependency versions
#ENV AXE_SELENIUM_LIBRARY_VERSION 2.1.6
ENV CHROMIUM_VERSION 86.0
ENV DATABASE_LIBRARY_VERSION 1.2.4
#ENV DATADRIVER_VERSION 1.4.1
ENV DATETIMETZ_VERSION 1.0.6
#ENV FAKER_VERSION 5.0.0
ENV FIREFOX_VERSION 78
ENV FTP_LIBRARY_VERSION 1.9
ENV GECKO_DRIVER_VERSION v0.26.0
ENV IMAP_LIBRARY_VERSION 0.4.0
ENV PABOT_VERSION 2.0.1
ENV REQUESTS_VERSION 0.9.1
ENV ROBOT_FRAMEWORK_VERSION 4.1
ENV SELENIUM_LIBRARY_VERSION 5.1.3
ENV SSH_LIBRARY_VERSION 3.7.0
ENV XVFB_VERSION 1.20
ENV LDAP_VERSION 2.9.1
ENV EXCELLIB_VERSION 2.0.0
#ENV PDF2TEXTLIBRARY_VERSION 1.0.1
#ENV SELENIUM2LIBRARY_VERSION 3.0.0
ENV JIRA_VERSION 3.0.1
#ENV PYPDF2_VERSION 1.26.0
ENV CX_ORACLE 8.2.1
#ENV XVFB_VERSION 1.20
ENV PDFPLUMBER_VERSION 0.6.0

# By default, no reports are uploaded to AWS S3
#ENV AWS_UPLOAD_TO_S3 false

# Prepare binaries to be executed
COPY bin/chromedriver.sh /opt/robotframework/bin/chromedriver
COPY bin/chromium-browser.sh /opt/robotframework/bin/chromium-browser
COPY bin/run-tests-in-virtual-screen.sh /opt/robotframework/bin/

# Install system dependencies
RUN apk update \
  && apk --no-cache upgrade \
  && apk --no-cache --virtual .build-deps add \

    # Install dependencies for cryptography due to https://github.com/pyca/cryptography/issues/5771
#    cargo \
#    rust \

    # Continue with system dependencies
    gcc \
    g++ \
    libffi-dev \
    linux-headers \
    make \
    musl-dev \
    openssl-dev \
    which \
    wget \
  && apk --no-cache add \
    "chromium~$CHROMIUM_VERSION" \
    "chromium-chromedriver~$CHROMIUM_VERSION" \
    "firefox-esr~$FIREFOX_VERSION" \
    xauth \
    tzdata \
    "xvfb-run~$XVFB_VERSION" \
	libc6-compat \
	libaio \
	libnsl \ 
	curl \
	libxml2-dev \
    libxslt-dev \
	jpeg-dev \
	zlib-dev \
	freetype-dev \
	lcms2-dev \
	openjpeg-dev \
#	tiff-dev \
#	tk-dev \
#	tcl-dev \
    "xvfb-run~$XVFB_VERSION" \
  && mv /usr/lib/chromium/chrome /usr/lib/chromium/chrome-original \
  && ln -sfv /opt/robotframework/bin/chromium-browser /usr/lib/chromium/chrome \
# FIXME: above is a workaround, as the path is ignored

# Install Robot Framework and Selenium Library
  
  && pip3 install \
    --no-cache-dir \
	--upgrade pip \
    robotframework==$ROBOT_FRAMEWORK_VERSION \
    robotframework-databaselibrary==$DATABASE_LIBRARY_VERSION \
#    robotframework-datadriver==$DATADRIVER_VERSION \
#    robotframework-datadriver[XLS] \
    robotframework-datetime-tz==$DATETIMETZ_VERSION \
#    robotframework-faker==$FAKER_VERSION \
    robotframework-ftplibrary==$FTP_LIBRARY_VERSION \
    robotframework-imaplibrary2==$IMAP_LIBRARY_VERSION \
    robotframework-pabot==$PABOT_VERSION \
    robotframework-requests==$REQUESTS_VERSION \
    robotframework-seleniumlibrary==$SELENIUM_LIBRARY_VERSION \
    robotframework-sshlibrary==$SSH_LIBRARY_VERSION \
    #axe-selenium-python==$AXE_SELENIUM_LIBRARY_VERSION \
    PyYAML \
	ldap3==$LDAP_VERSION \
	cx_Oracle==$CX_ORACLE \
	robotframework-excellib==$EXCELLIB_VERSION \
#    robotframework-selenium2library==$SELENIUM2LIBRARY_VERSION \
#    robotframework-pdf2textlibrary==$PDF2TEXTLIBRARY_VERSION \
#    robotframework-archivelibrary \
    #PyPDF2==$PYPDF2_VERSION \
    JayDeBeApi \
    lxml \
    xlrd \
    suds-py3\
    jira==$JIRA_VERSION \
	pdfplumber==$PDFPLUMBER_VERSION \


# Download Gecko drivers directly from the GitHub repository
  && wget -q "https://github.com/mozilla/geckodriver/releases/download/$GECKO_DRIVER_VERSION/geckodriver-$GECKO_DRIVER_VERSION-linux64.tar.gz" \
    && tar xzf geckodriver-$GECKO_DRIVER_VERSION-linux64.tar.gz \
    && mkdir -p /opt/robotframework/drivers/ \
    && mv geckodriver /opt/robotframework/drivers/geckodriver \
    && rm geckodriver-$GECKO_DRIVER_VERSION-linux64.tar.gz \

# Download Instant Client   
	&& cd /tmp && \
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
	ln -s /lib64/ld-linux-x86-64.so.2 /usr/lib/ld-linux-x86-64.so.2 \

   
# Clean up buildtime dependencies
  && apk del --no-cache --update-cache .build-deps

#ENV JAVA_HOME /usr/lib/jvm/java-1.8-openjdk
#ENV LD_LIBRARY_PATH=$JAVA_HOME/jre/lib/amd64:$JAVA_HOME/jre/lib/amd64/server
ENV LD_LIBRARY_PATH /usr/lib/instantclient:$LD_LIBRARY_PATH:/usr/lib

#RUN set -x && apk add --no-cache openjdk8

# Define the default user who'll run the tests

RUN mkdir -p ${ROBOT_REPORTS_DIR} \
  && mkdir -p ${ROBOT_WORK_DIR} \
  && chown ${ROBOT_UID}:${ROBOT_GID} ${ROBOT_REPORTS_DIR} \
  && chown ${ROBOT_UID}:${ROBOT_GID} ${ROBOT_WORK_DIR} \
  && chmod ugo+w ${ROBOT_REPORTS_DIR} ${ROBOT_WORK_DIR}
  
# Allow any user to write logs
RUN chmod ugo+w /var/log \
  && chown ${ROBOT_UID}:${ROBOT_GID} /var/log

# Update system path
ENV PATH=/opt/robotframework/bin:/opt/robotframework/drivers:$PATH

# Set up a volume for the generated reports
VOLUME ${ROBOT_REPORTS_DIR}



# A dedicated work folder to allow for the creation of temporary files
WORKDIR ${ROBOT_WORK_DIR}
  
CMD ["run-tests-in-virtual-screen.sh"]
