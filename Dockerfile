FROM nginx:1.27-alpine

# URL completa do webhook do CRM (com token). Defina em Easypanel > Environment.
# Vazio por padrão: o site sobe normalmente e o envio ao CRM só passa a funcionar quando configurado.
ENV CRM_WEBHOOK_URL=""
# Só variáveis CRM_* são substituídas no template
ENV NGINX_ENVSUBST_FILTER="^CRM_"

COPY nginx.conf /etc/nginx/templates/default.conf.template

COPY index.html logo-so-aco.png logo-so-aco-transparente.png /usr/share/nginx/html/
COPY img/ /usr/share/nginx/html/img/

EXPOSE 80
