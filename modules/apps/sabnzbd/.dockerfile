# Test dockerfile for development
FROM ubuntu:latest as build
WORKDIR /app
COPY ./scripts/sabnzbd.sh .
RUN chmod +x sabnzbd.sh
CMD ["bash", "-x", "/app/sabnzbd.sh"]
