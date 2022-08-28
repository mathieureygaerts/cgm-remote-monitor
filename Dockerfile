FROM --platform=linux/arm64 node:14.15.3-alpine

LABEL maintainer="Nightscout Contributors"

WORKDIR /opt/app
ADD . /opt/app

# TODO: We should be able to do `RUN npm install --only=production`.
# For this to work, we need to copy only package.json and things needed for `npm`'s to succeed.
# TODO: Do we need to re-add `npm audit fix`? Or should that be part of a development process/stage?
RUN npm install --cache /tmp/empty-cache && \
  npm run postinstall && \
  npm run env && \
  rm -rf /tmp/*
  # TODO: These should be added in the future to correctly cache express-minify content to disk
  # Currently, doing this breaks the browser cache.
  # mkdir /tmp/public && \
  # chown node:node /tmp/public

# ENV MONGODB_URI= set this when running the image. 
ENV MONGO_COLLECTION=entries

ENV INSECURE_USE_HTTP=true

# API_SECRET - A secret passphrase that must be at least 12 characters long.
ENV API_SECRET=change_me

### Features
# ENABLE - Used to enable optional features, expects a space delimited list, such as: careportal rawbg iob
# See https://github.com/nightscout/cgm-remote-monitor#plugins for details
ENV ENABLE="careportal basal sage iob cob cors ar2"
ENV SHOW_PLUGINS="careportal basal sage iob cob"
ENV TIME_FORMAT=24
ENV DISPLAY_UNITS=mmol
ENV BG_HIGH=260
ENV BG_LOW=55
ENV BG_TARGET_BOTTOM=70.2
ENV BG_TARGET_TOP=180
ENV ALARM_HIGH=on
ENV ALARM_LOW=on
ENV ALARM_TIMEAGO_URGENT=on
ENV ALARM_TIMEAGO_URGENT_MINS=30
ENV ALARM_TIMEAGO_WARN=on
ENV ALARM_TIMEAGO_WARN_MINS=15
ENV ALARM_TYPES=simple
ENV ALARM_URGENT_HIGH=on
ENV ALARM_URGENT_LOW=on
ENV SCALE_Y=linear

# AUTH_DEFAULT_ROLES (readable) - possible values readable, denied, or any valid role name.
# When readable, anyone can view Nightscout without a token. Setting it to denied will require
# a token from every visit, using status-only will enable api-secret based login.
ENV AUTH_DEFAULT_ROLES=denied



USER node
EXPOSE 1337

CMD ["node", "lib/server/server.js"]
