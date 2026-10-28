# LP Só Aço: Gôndolas e Porta-Pallets

Landing page estática para campanhas Google Ads, servida por Nginx em Docker.

## Deploy no Easypanel

1. **+ Service → App**
2. **Source → GitHub**: repositório `fonil-company/lp-soaco`, branch `main`
3. **Build → Dockerfile** (arquivo `Dockerfile` na raiz)
4. **Domains**: adicione o domínio e aponte para a **porta 80**. O HTTPS é gerado pelo Easypanel.
5. **Deploy**

Cada `git push` na `main` pode publicar automaticamente: ative **Auto Deploy** no serviço.

## Antes de publicar

No fim do `index.html`, preencha o bloco `window.SOACO`:

| Campo | O que é |
|---|---|
| `ADS_ID` | ID da tag do Google Ads (`AW-...`) |
| `ADS_LABEL_LEAD` | Rótulo da conversão de lead (formulário) |
| `ADS_LABEL_CLICK` | Rótulo da conversão de clique (opcional) |
| `GA4_ID` | ID do GA4 (`G-...`, opcional) |
| `WHATSAPP` | Número com DDI + DDD, só dígitos (ex.: `5586999999999`) |

Troque também `SEUDOMINIO.com.br` pelo domínio real (canonical, Open Graph e dados estruturados).

## Rodar localmente

```bash
docker build -t lp-soaco .
docker run --rm -p 8080:80 lp-soaco
# http://localhost:8080
```
