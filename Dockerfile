## build

FROM node:12-alpine as build

COPY ./backend /src

WORKDIR /src

RUN npm ci

RUN npm run format
RUN npm run test

RUN npm prune --production

## stage 2

FROM node:12.1.0-alpine

ARG ARG_SERVICE_NAME
ARG ARG_SERVICE_VERSION
ARG ARG_GIT_SHA

ENV SERVICE_NAME=$ARG_SERVICE_NAME
ENV SERVICE_VERSION=$ARG_SERVICE_VERSION
ENV GIT_SHA=$ARG_GIT_SHA

WORKDIR /home/node

COPY --from=build /src/node_modules node_modules
COPY --from=build /src/server.js server.js
COPY --from=build /src/routes routes
COPY --from=build /src/lib lib

USER node

CMD ["node", "./server.js"]
