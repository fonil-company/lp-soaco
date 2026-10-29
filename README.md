# LP Só Aço: Gôndolas e Porta-Pallets

Landing page estática para campanhas Google Ads, servida por Nginx em Docker.

## Deploy no Easypanel

1. **+ Service → App**
2. **Source → GitHub**: repositório `fonil-company/lp-soaco`, branch `main`
3. **Build → Dockerfile** (arquivo `Dockerfile` na raiz)
4. **Environment**: adicione a variável abaixo (URL completa do webhook do CRM, com o token):
   ```
   CRM_WEBHOOK_URL=https://crm.fonilgroup.com.br/api/webhooks/leads/SEU_TOKEN
   ```
5. **Domains**: adicione o domínio e aponte para a **porta 80**. O HTTPS é gerado pelo Easypanel.
6. **Deploy**

Cada `git push` na `main` pode publicar automaticamente: ative **Auto Deploy** no serviço.

## Integração com o CRM

O formulário envia o lead para `/api/lead` no próprio domínio. O Nginx repassa esse envio para `CRM_WEBHOOK_URL`, então o token nunca aparece no código da página. Esse caminho aceita no máximo 10 envios por minuto por IP.

Payload enviado:

```json
{
  "phone": "86999999999", "name": "Nome", "document": "12345678000190", "city": "Teresina", "state": "PI",
  "company": "Empresa LTDA", "segment": "Supermercados", "product": "Gôndolas",
  "utm_source": "google", "utm_medium": "cpc", "utm_campaign": "...", "utm_term": "...", "utm_content": "...",
  "gclid": "...", "gbraid": "...", "wbraid": "...", "fbclid": "...", "fbp": "fb.1...", "fbc": "fb.1...",
  "landing_page": "https://SEUDOMINIO.com.br/?utm_source=..."
}
```

`company` só vai quando o campo Empresa é preenchido (é opcional no formulário). UTMs, GCLID, GBRAID, WBRAID e FBCLID são capturados da URL de chegada e guardados por 90 dias no navegador, junto com a URL de chegada (`landing_page`). Só são enviados os que existirem. `fbp` e `fbc` vêm dos cookies do Meta Pixel; sem Pixel na página, `fbp` não é enviado e `fbc` é montado a partir do `fbclid`.

Depois do envio, o visitante segue para o WhatsApp mesmo se o CRM falhar. Na falha, o console mostra `[CRM] falha ao enviar lead` e o dataLayer recebe `crm_lead_error`.

Se a variável não estiver definida, o site sobe normalmente, mas `/api/lead` responde com erro.

### Umbrella CRM

O mesmo lead também vai para o Umbrella CRM, por `/api/lead-umbrella`, que o Nginx repassa para `CRM_UMBRELLA_WEBHOOK_URL` (já vem preenchida no `Dockerfile`; dá para trocar em Easypanel > Environment). Além dos campos acima, vão `event_id`/`browserEventId`, `landingUrl`, `referrer`, `_fbc` e `_fbp`, no formato do snippet oficial deles.

O snippet `<script src="https://crm-api.umbrellaecosystem.com.br/api/v1/public/t/....js">` **não** é usado: em 29/10/2026 ele tinha um erro de sintaxe (expressão regular inválida em `getCookie`) e não carregava, e a API deles não libera CORS para outros domínios. Por isso o envio passa pelo servidor. Falhas aparecem no console como `[UMBRELLA] falha ao enviar lead` e no dataLayer como `umbrella_lead_error`.

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
