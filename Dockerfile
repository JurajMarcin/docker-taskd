FROM alpine:3

WORKDIR /var/taskd

ENV TASKDDATA=/var/taskd
VOLUME /var/taskd
EXPOSE 53589

RUN apk --no-cache add tini taskd taskd-pki

COPY entrypoint.sh /
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]

CMD ["taskd", "server"]
