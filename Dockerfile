FROM dorowu/ubuntu-desktop-lxde-vnc:focal

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
  python3.10 \
  python3.10-venv \
  python3-pip \
  curl \
  wget \
  && rm -rf /var/lib/apt/lists/*

RUN python3.10 -m venv /opt/molbot-env
ENV PATH="/opt/molbot-env/bin:$PATH"

RUN pip install --upgrade pip && \
  pip install supabase openai playwright

RUN playwright install chromium && \
  playwright install-deps chromium

WORKDIR /home/ubuntu
RUN mkdir -p /home/ubuntu/molbot

ENV HTTP_PASSWORD=""

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 80 5900

ENTRYPOINT ["/entrypoint.sh"]
