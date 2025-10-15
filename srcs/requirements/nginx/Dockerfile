FROM alpine:3.21.1

RUN apk add --no-cache nginx \
    && mkdir -p /var/log/nginx /usr/share/nginx/html \
    && chown -R nginx:nginx /var/log/nginx /usr/share/nginx/html /etc/nginx/http.d

VOLUME /var/www/html

WORKDIR /etc/nginx/http.d

COPY conf/nginx.conf default.conf

USER nginx

EXPOSE 443

CMD ["nginx", "-g", "daemon off;"]