FROM debian:latest-slim

# Install initial necessary packages
RUN apt-get update && apt-get install -y \
    wget curl bzip2 patch sudo

# Download and extract Asterisk source
RUN wget http://downloads.asterisk.org/pub/telephony/asterisk/asterisk-21-current.tar.gz && \
    tar xzf asterisk-21-current.tar.gz && \
    rm asterisk-21-current.tar.gz

# Compile and install Asterisk
RUN cd /asterisk-21* && \
    sed -i 's/ast_sockaddr_stringify_host(&transport_state->external_signaling_address)/"___ACTUAL.FQDN.HERE___"/' res/res_pjsip_nat.c && \
    sed -i 's/ast_sockaddr_stringify_host(&transport_state->external_signaling_address)/"___ACTUAL.FQDN.HERE___"/' res/res_pjsip_nat.c && \
    ./contrib/scripts/install_prereq install && \
    ./configure && \
    make menuselect.makeopts && \
    menuselect/menuselect --enable codec_silk && \
    make -j8 && \
    make install && \
    ldconfig && \
    make config && \
    make basic-pbx


# Check if "load = res_srtp.so" exists in /etc/asterisk/modules.conf, if not, append it
RUN grep -qxF 'load = res_srtp.so' /etc/asterisk/modules.conf || echo 'load = res_srtp.so' >> /etc/asterisk/modules.conf


# Clean up build dependencies and source files
RUN apt-get remove -y wget curl bzip2 patch build-essential && \
    apt-get autoremove -y && \
    apt-get clean && rm -rf /var/lib/apt/lists/* && \
    rm -rf /asterisk-21.*


# Start Asterisk in the foreground
ENTRYPOINT ["/usr/sbin/asterisk", "-f", "-vvv"]
