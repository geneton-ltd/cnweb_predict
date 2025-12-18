FROM node:21.1.0 AS build

WORKDIR /app

# Env variables necessary to be set during build 
ARG REACT_APP_BACKEND_URL
ENV REACT_APP_BACKEND_URL="https://rest.genovisio.com"

# Install Requirements
COPY package.json .
COPY yarn.lock .
RUN yarn install --prod

# Copy App files without nginx and build app
COPY public/ ./public/
COPY src/ ./src/
COPY tsconfig.json .

RUN yarn build

# Update NginX file with ENV vars
COPY nginx.conf /etc/nginx/conf.d/nginx.conf

FROM nginx:1.21.3-alpine
COPY --from=build /app/build /usr/share/nginx/html
COPY --from=build /etc/nginx/conf.d/nginx.conf /etc/nginx/conf.d/nginx.conf
RUN rm /etc/nginx/conf.d/default.conf

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
