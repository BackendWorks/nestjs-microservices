FROM kong:latest
COPY ./conf/kong.yml /usr/local/kong/declarative/kong.yml
USER kong
CMD [ "kong", "start" ]