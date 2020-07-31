FROM ubuntu:focal as builder

ENV TERM linux
ENV DEBIAN_FRONTEND=noninteractive

# RUN apt-get update \
#     && apt-get upgrade \ 
#     && apt-get install -y \
#     git composer php php-cli php-fpm php-json php-pdo php-mysql php-zip php-gd  php-mbstring php-curl php-xml php-pear php-bcmath

    
RUN apt-get update -y
RUN apt-get upgrade -y
RUN apt-get install -y git composer php php-cli php-fpm php-json php-pdo php-mysql php-zip php-gd  php-mbstring php-curl php-xml php-pear php-bcmath php-intl zip

WORKDIR /prestashop
COPY . .

RUN php tools/build/CreateRelease.php --version="1.7.6.7" --destination-dir=/prestashop

FROM prestashop/base:5.6-apache
LABEL maintainer="Andrew Roesch"

WORKDIR /tmp
COPY --from=builder /prestashop/prestashop_1.7.6.7.zip prestashop.zip

ENV PS_VERSION 1.7.6.7


# Get PrestaShop
#ADD https://www.prestashop.com/download/old/prestashop_1.7.6.7.zip /tmp/prestashop.zip

# Extract
RUN mkdir -p /tmp/data-ps \
	&& unzip -q /tmp/prestashop.zip -d /tmp/data-ps/ \
	&& bash /tmp/ps-extractor.sh /tmp/data-ps \
	&& rm /tmp/prestashop.zip


CMD ["/bin/bash"]