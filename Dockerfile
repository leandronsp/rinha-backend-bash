FROM ubuntu
RUN apt update && apt install -y netcat postgresql-client
WORKDIR /app

COPY . .

EXPOSE 3000
CMD ["bash app.bash"]
