FROM nginx:1.27-alpine

# URL completa do webhook do CRM (com token). Defina em Easypanel > Environment.
# Vazio por padrão: o site sobe normalmente e o envio ao CRM só passa a funcionar quando configurado.
ENV CRM_WEBHOOK_URL=""
# Webhook do Umbrella CRM (o mesmo que aparece no snippet público deles). Pode ser trocado em Easypanel > Environment.
ENV CRM_UMBRELLA_WEBHOOK_URL="https://crm-api.umbrellaecosystem.com.br/api/v1/webhooks/in/796b2005-3c30-4e92-8e97-d0ebdfc08bcd"
# Meta (Pixel + Conversions API). O Pixel ID é público; o token NÃO vai no código:
# defina META_CAPI_TOKEN em Easypanel > Environment.
ENV META_PIXEL_ID="1063603920051123"
ENV META_GRAPH_VERSION="v24.0"
ENV META_CAPI_TOKEN=""
# Só variáveis CRM_* e META_* são substituídas no template
ENV NGINX_ENVSUBST_FILTER="^(CRM_|META_)"

COPY nginx.conf /etc/nginx/templates/default.conf.template

COPY index.html logo-so-aco.png logo-so-aco-transparente.png /usr/share/nginx/html/
COPY img/ /usr/share/nginx/html/img/

EXPOSE 80
