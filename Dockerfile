## build

FROM node:12-alpine as build

COPY ./backend /src

COPY .git/refs/heads/master /src/.lastcommitsha

WORKDIR /src

RUN cat package.json \
        | grep version \
        | head -1 \
        | awk -F: '{ print $2 }' \
        | sed 's/[",]//g' \
        > /src/.appversion

RUN npm ci

RUN npm run format
RUN npm run test

RUN npm prune --production

## stage 2

FROM node:12.1.0-alpine

WORKDIR /home/node

COPY --from=build /src/node_modules node_modules
COPY --from=build /src/server.js server.js
COPY --from=build /src/.lastcommitsha .lastcommitsha
COPY --from=build /src/.appversion .appversion

HEALTHCHECK --interval=5s \
            --timeout=5s \
            --retries=6 \
            CMD curl -fs http://localhost:${port}/ || exit 1

USER node

CMD ["node", "./server.js"]