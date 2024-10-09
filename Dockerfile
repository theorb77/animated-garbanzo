FROM ubuntu:latest

RUN mkdir -p /app

WORKDIR /app

RUN apt-get update -y

RUN apt-get upgrade -y

RUN apt-get install -y python3 python3-pip gunicorn

COPY . .

RUN pip3 install --no-cache-dir -r requirements.txt --break-system-packages

ARG ACCESS_ID=null
ENV ACCESS_ID=$ACCESS_ID

ARG ACCESS_KEY=null
ENV ACCESS_KEY=$ACCESS_KEY

CMD ["gunicorn" , "--bind","0.0.0.0:80", "wsgi:app"]
