FROM bash:latest
WORKDIR /app

COPY . .

RUN apk add gawk make
RUN apk add --update nodejs npm
RUN apk add icu-data-full

RUN npm ci

RUN make api
RUN make descriptions
