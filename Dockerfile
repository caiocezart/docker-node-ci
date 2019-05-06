## build

FROM node:12-alpine as build

COPY ./backend /src

WORKDIR /src

RUN npm ci

## stage 2

FROM node

WORKDIR /home/node

COPY --from=build /src/node_modules node_modules
COPY --from=build /src/server.js server.js

USER node

CMD ["node", "./server.js"]