FROM nginx:1.27-alpine

COPY nginx.conf /etc/nginx/conf.d/default.conf

COPY index.html logo-so-aco.png logo-so-aco-transparente.png /usr/share/nginx/html/
COPY img/ /usr/share/nginx/html/img/

EXPOSE 80
