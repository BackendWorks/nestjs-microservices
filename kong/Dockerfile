FROM kong:latest

ENV KONG_DATABASE="off" \
    KONG_DECLARATIVE_CONFIG="/usr/local/kong/declarative/kong.yml" \
    KONG_PROXY_LISTEN=0.0.0.0:8000 \
    KONG_PROXY_LISTEN_SSL=0.0.0.0:8443 \
    KONG_ADMIN_LISTEN=0.0.0.0:8001 \ 
    KONG_PROXY_ACCESS_LOG="/dev/stdout" \
    KONG_ADMIN_ACCESS_LOG="/dev/stdout" \
    KONG_PROXY_ERROR_LOG="/dev/stderr" \
    KONG_LOG_LEVEL=debug 

COPY ./conf/kong.yml /usr/local/kong/declarative/kong.yml

USER kong

CMD [ "kong", "start" ]
