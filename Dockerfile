FROM ubuntu
RUN apt update && apt install -y netcat
WORKDIR /app
EXPOSE 3000
