FROM node:22-alpine

# 安裝 git
USER root
RUN apk add --no-cache git

USER node
WORKDIR /opt/openflow

# 從 GitHub clone
RUN git clone https://github.com/stan-smith/FossFLOW.git . --depth=1

COPY --chown=node:node package*.json ./
RUN npm ci && npm cache clean --force

COPY --chown=node:node . .

EXPOSE 3000

CMD ["npm", "start"]