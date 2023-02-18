FROM kong:latest

ENV KONG_DATABASE="off" \
    KONG_DECLARATIVE_CONFIG="/usr/local/kong/declarative/kong.yml" \
    KONG_PROXY_LISTEN=0.0.0.0:8000 \
    KONG_PROXY_LISTEN_SSL=0.0.0.0:8443 \
    KONG_ADMIN_LISTEN=0.0.0.0:8001 

COPY ./conf/kong.yml /usr/local/kong/declarative/kong.yml

USER kong

CMD [ "kong", "start" ]
