## build

FROM node:12-alpine as build

ARG COMMIT_HASH

COPY ./backend /src

RUN echo ${COMMIT_HASH} > /src/.lastcommitsha

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
COPY --from=build /src/routes routes
COPY --from=build /src/.lastcommitsha .lastcommitsha
COPY --from=build /src/.appversion .appversion

USER node

CMD ["node", "./server.js"]