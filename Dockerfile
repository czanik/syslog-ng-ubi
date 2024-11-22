FROM almalinux/9-init

# install syslog-ng and disable rsyslog
RUN dnf install -y 'dnf-command(config-manager)' && \
    dnf config-manager -y --set-enabled crb && \
    dnf install -y epel-release && \
    dnf copr -y enable czanik/syslog-ng-githead && \
    dnf clean all -y && \
    dnf update -y && \
    dnf remove -y rsyslog && \
    dnf install -y syslog-ng-amqp syslog-ng-geoip syslog-ng-http \
        syslog-ng-mongodb syslog-ng-python syslog-ng-redis \
        syslog-ng-riemann syslog-ng-smtp syslog-ng-grpc \
        syslog-ng-cloudauth syslog-ng-opentelemetry \
        syslog-ng-loki syslog-ng-bpf syslog-ng-slog \
        syslog-ng-kafka syslog-ng-python syslog-ng-python-modules && \
    dnf clean all

# add --no-caps to syslog-ng startup parameters
ADD syslog-ng /etc/sysconfig

#add a slightly modified syslog-ng configuration
ADD syslog-ng.conf /etc/syslog-ng/

# add files related to the syslog-ng Prometheus exporter
ADD sng_exporter.py /usr/local/bin/
ADD sngexporter.service /usr/lib/systemd/system/

# enable syslog-ng in systemd
RUN systemctl enable syslog-ng

# expose ports
# rfc3164
EXPOSE 514
# rfc5424
EXPOSE 601
# opentelemetry
EXPOSE 4317
# rfc5414 + TLS (does not work out of the box)
EXPOSE 6514
# syslog-ng Prometheus exporter
EXPOSE 9577

# start systemd, which starts syslog-ng
CMD ["/sbin/init"]
