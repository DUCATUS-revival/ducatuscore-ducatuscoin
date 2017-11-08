# Ubuntu 14.04 LTS (Trusty Tahr)
FROM ubuntu:14.04

# add bitcoind from the official PPA
RUN apt-get update --fix-missing
RUN apt-get install -y ntp git build-essential libssl-dev libdb-dev libdb++-dev libboost-all-dev libqrencode-dev libevent-dev autoconf libtool libboost-all-dev wget software-properties-common python-software-properties
RUN add-apt-repository -y ppa:bitcoin/bitcoin
RUN apt-get update -y
RUN apt-get install -y bitcoind git libdb4.8-dev libdb4.8++-dev

RUN git clone https://github.com/jgarzik/univalue; \
	cd univalue; \
	./autogen.sh; \
	./configure; \
	make install

# install bitcoind (from PPA) and make
RUN apt-get install --yes make pkg-config bsdmainutils libminiupnpc-dev libzmq3-dev libqt5gui5 libqt5core5a libqt5dbus5 qttools5-dev qttools5-dev-tools libprotobuf-dev protobuf-compiler

# copy the testnet-box files into the image
ADD . /root/ducatuscoin
WORKDIR /root/ducatuscoin

RUN ./autogen.sh
RUN aclocal
RUN ./autogen.sh
RUN autoreconf -i
RUN autoconf
RUN ./configure --with-system-univalue --with-gui=no --with-qrencode=no --disable-tests
RUN make
RUN make -j 5 install
RUN mkdir -p /root/.ducatuscoin/
ADD ./ducatuscoin.conf /root/.ducatuscoin/

# expose two rpc ports for the nodes to allow outside container access
EXPOSE 9690 9691
CMD ["/bin/bash"]
