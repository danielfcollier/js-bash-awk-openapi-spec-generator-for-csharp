FROM bash:latest
WORKDIR /app

RUN apk add --update gawk icu-data-full make nodejs npm

COPY . .

RUN npm ci

RUN make api
RUN make descriptions
