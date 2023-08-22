FROM ubuntu
RUN apt update && apt install -y netcat postgresql-client jq
WORKDIR /app
EXPOSE 3000
