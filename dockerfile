# build stage
# we start from a full debian stretch with node installed
FROM node:12-stretch AS build
# change the working directory to build
WORKDIR /build/
# notice that we only use yarn and not npm
# we only copy what's neccecary to install deps
COPY yarn.lock package.json ./
# equivalant to npm ci
# we install deps
RUN yarn install --frozen-lockfile
# install nestjs cli globally
RUN yarn global add @nestjs/cli
# we copy the code base over to build
# the reason we do this at a diffrent layer is to optomize docker cache
COPY . .
# building the application
RUN nest build
# -------------------------------------
# runtime stage
# starting from alpine to optimize image size
FROM node:12-alpine
# for security mesures we use the user created instaid of root user
USER node
# create a new folder and make it the current working directory
RUN mkdir /home/node/code
WORKDIR /home/node/code
# copy the build from the previous image
COPY --from=build --chown=node:node /build/ .
# set environemnt variables
ENV NODE_ENV=production
# start the app
CMD ["node", "dist/src/main"]