FROM ubuntu:24.04 AS builder
RUN apt-get update && apt-get install -y curl git unzip xz-utils zip libglu1-mesa \
    && curl -fsSL https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.29.2-stable.tar.xz \
    | tar -xJ -C /usr/local \
    && ln -s /usr/local/flutter/bin/flutter /usr/local/bin/flutter \
    && flutter config --enable-web
WORKDIR /app
COPY . .
RUN flutter build web --release

FROM nginx:alpine
COPY --from=builder /app/build/web /usr/share/nginx/html
COPY nginx.conf /etc/nginx/conf.d/default.conf
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
