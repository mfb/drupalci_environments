######
# Base
#####
FROM debian:jessie

ENV DRUPALCI TRUE

# Install deps + add Chrome Stable + purge all the things
RUN apt-get update && apt-get install -y \
	apt-transport-https \
	ca-certificates \
	curl \
	wget \
	unzip \
    gnupg \
	--no-install-recommends \
	&& curl -sSL https://dl.google.com/linux/linux_signing_key.pub | apt-key add - \
	&& echo "deb [arch=amd64] https://dl.google.com/linux/chrome/deb/ stable main" > /etc/apt/sources.list.d/google-chrome.list \
	&& apt-get update && apt-get install -y \
	google-chrome-stable \
	--no-install-recommends \
	&& apt-get purge --auto-remove -y curl gnupg \
	&& rm -rf /var/lib/apt/lists/*

#==================
# Chrome webdriver
#==================
ARG CHROME_DRIVER_VERSION=2.32
RUN wget --no-verbose -O /tmp/chromedriver_linux64.zip https://chromedriver.storage.googleapis.com/$CHROME_DRIVER_VERSION/chromedriver_linux64.zip \
  && unzip /tmp/chromedriver_linux64.zip -d /opt/google \
  && rm /tmp/chromedriver_linux64.zip \
  && mv /opt/google/chromedriver /opt/google/chromedriver-$CHROME_DRIVER_VERSION \
  && chmod 755 /opt/google/chromedriver-$CHROME_DRIVER_VERSION \
  && ln -fs /opt/google/chromedriver-$CHROME_DRIVER_VERSION /usr/bin/chromedriver

RUN wget -O /usr/local/bin/dumb-init https://github.com/Yelp/dumb-init/releases/download/v1.2.0/dumb-init_1.2.0_amd64
RUN chmod +x /usr/local/bin/dumb-init

# Add Chrome as a user
RUN groupadd -r chrome && useradd -r -g chrome -G audio,video chrome \
    && mkdir -p /home/chrome && chown -R chrome:chrome /home/chrome

# Run Chrome non-privileged
USER chrome

EXPOSE 9515

ENTRYPOINT [ "chromedriver" ]

CMD [ "--whitelisted-ips" ]
