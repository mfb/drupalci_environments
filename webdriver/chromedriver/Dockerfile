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
	&& curl -sS -o - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add - \
	&& echo "deb [arch=amd64] https://dl.google.com/linux/chrome/deb/ stable main" > /etc/apt/sources.list.d/google-chrome.list \
	&& apt-get update && apt-get install -y \
	google-chrome-stable \
	&& apt-get purge --auto-remove -y curl \
	&& rm -rf /var/lib/apt/lists/*


#==================
# Chromedriver
#==================
ARG CHROME_DRIVER_VERSION=2.33
RUN wget --no-verbose -O /tmp/chromedriver_linux64.zip https://chromedriver.storage.googleapis.com/$CHROME_DRIVER_VERSION/chromedriver_linux64.zip \
  && unzip /tmp/chromedriver_linux64.zip -d /opt\
  && rm /tmp/chromedriver_linux64.zip \
  && mv /opt/chromedriver /opt/chromedriver-$CHROME_DRIVER_VERSION \
  && chmod 755 /opt/chromedriver-$CHROME_DRIVER_VERSION \
  && ln -fs /opt/chromedriver-$CHROME_DRIVER_VERSION /usr/local/bin/chromedriver

RUN wget -O /usr/local/bin/dumb-init https://github.com/Yelp/dumb-init/releases/download/v1.2.0/dumb-init_1.2.0_amd64
RUN chmod +x /usr/local/bin/dumb-init

# Add Chrome as a user
RUN groupadd -r chromeuser && useradd -r -g chromeuser -G audio,video chromeuser \
    && mkdir -p /home/chromeuser && chown -R chromeuser:chromeuser /home/chromeuser

# Run Chrome non-privileged
USER chromeuser

EXPOSE 9515

ENTRYPOINT [ "chromedriver" ]

#TODO Remove the logging and verbosity
CMD [ "--log-path=/tmp/chromedriver.log", "--verbose", "--whitelisted-ips=" ]
