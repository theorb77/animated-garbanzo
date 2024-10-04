FROM ubuntu:latest

RUN mkdir -p /app

WORKDIR /app

RUN apt-get update -y

RUN apt-get upgrade -y

RUN apt-get install -y python3 python3-pip

COPY . .

RUN pip3 install --no-cache-dir -r requirements.txt --break-system-packages

ENTRYPOINT [ "python3", "/app/helloworld.py" ]
