FROM alpine AS builder

RUN apk add --no-cache nodejs npm git curl jq python3 python3-dev py3-pip

RUN adduser -D app
USER app
WORKDIR /home/app

RUN git clone https://github.com/louislam/uptime-kuma.git
WORKDIR /home/app/uptime-kuma
RUN npm run setup

ENV VIRTUAL_ENV=/home/app/venv
RUN python3 -m venv $VIRTUAL_ENV
ENV PATH="$VIRTUAL_ENV/bin:$PATH"

RUN pip install --no-cache-dir requests webdavclient3

COPY --chown=app:app sync_data.sh /home/app/uptime-kuma/
RUN chmod +x /home/app/uptime-kuma/sync_data.sh

EXPOSE 3001
CMD ["/bin/sh", "-c", "./sync_data.sh & sleep 30 && node server/server.js"]
