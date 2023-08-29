FROM ubuntu AS base
RUN apt update && apt install -y netcat postgresql-client socat
WORKDIR /app

FROM base AS prod
COPY . .
EXPOSE 3000
CMD ["bash", "netcat.bash"]
