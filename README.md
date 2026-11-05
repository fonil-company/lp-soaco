# LP Só Aço: Porta-Pallets

Landing page estática para campanhas Google Ads, servida por Nginx em Docker.

## Deploy no Easypanel

1. **+ Service → App**
2. **Source → GitHub**: repositório `fonil-company/lp-soaco`, branch `main`
3. **Build → Dockerfile** (arquivo `Dockerfile` na raiz)
4. **Environment**: adicione as variáveis abaixo:
   ```
   CRM_WEBHOOK_URL=https://crm.fonilgroup.com.br/api/webhooks/leads/SEU_TOKEN
   META_CAPI_TOKEN=token da Conversions API (Gerenciador de Eventos > Configurações)
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
  "company": "Empresa LTDA", "segment": "Centros de distribuição", "product": "Porta-pallets",
  "utm_source": "google", "utm_medium": "cpc", "utm_campaign": "...", "utm_term": "...", "utm_content": "...",
  "gclid": "...", "gbraid": "...", "wbraid": "...", "fbclid": "...", "fbp": "fb.1...", "fbc": "fb.1...",
  "landing_page": "https://SEUDOMINIO.com.br/?utm_source=..."
}
```

`company` só vai quando o campo Empresa é preenchido (é opcional no formulário). `product` é sempre `Porta-pallets`, já que a página vende só esse produto. UTMs, GCLID, GBRAID, WBRAID e FBCLID são capturados da URL de chegada e guardados por 90 dias no navegador, junto com a URL de chegada (`landing_page`). Só são enviados os que existirem. `fbp` e `fbc` vêm dos cookies do Meta Pixel; sem Pixel na página, `fbp` não é enviado e `fbc` é montado a partir do `fbclid`.

Depois do envio, o visitante segue para o WhatsApp mesmo se o CRM falhar. Na falha, o console mostra `[CRM] falha ao enviar lead` e o dataLayer recebe `crm_lead_error`.

Se a variável não estiver definida, o site sobe normalmente, mas `/api/lead` responde com erro.

### Umbrella CRM

O mesmo lead também vai para o Umbrella CRM, por `/api/lead-umbrella`, que o Nginx repassa para `CRM_UMBRELLA_WEBHOOK_URL` (já vem preenchida no `Dockerfile`; dá para trocar em Easypanel > Environment). Além dos campos acima, vão `event_id`/`browserEventId`, `landingUrl`, `referrer`, `_fbc` e `_fbp`, no formato do snippet oficial deles.

O snippet `<script src="https://crm-api.umbrellaecosystem.com.br/api/v1/public/t/796b2005-3c30-4e92-8e97-d0ebdfc08bcd.js" defer>` está no `<head>` (ID trocado em 04/11/2026, cada domínio tem o seu), só para o rastreamento (first/last touch, UTMs e cookie `_fbc`). O formulário **não** tem `data-umbrella`, então o snippet não envia o lead sozinho: a API deles responde ao preflight sem `Access-Control-Allow-Origin`, e o envio direto do navegador seria bloqueado. Por isso o lead passa pelo servidor, para o mesmo webhook do snippet. Falhas aparecem no console como `[UMBRELLA] falha ao enviar lead` e no dataLayer como `umbrella_lead_error`.

### Meta (Pixel + Conversions API)

Pixel `1063603920051123` no `<head>`: PageView ao abrir a página e Lead no envio do formulário. O mesmo Lead também vai pela Conversions API, por `/api/meta-event`. O Nginx repassa para `graph.facebook.com` com o token `META_CAPI_TOKEN`, **que só existe no Easypanel** (não vai no código). Pixel, Conversions API e Umbrella usam o mesmo `event_id`, então o Meta deduplica o Lead.

A Conversions API recebe telefone, nome, cidade, UF, país e CNPJ (como `external_id`) com hash SHA-256, mais `fbp`, `fbc` e o user agent.

Para testar: Gerenciador de Eventos > Testar eventos. Copie o código e abra a página com `?test_event_code=TESTxxxx`. Falhas aparecem como `[META] falha ao enviar Lead` no console e `meta_capi_error` no dataLayer.

## Antes de publicar

No fim do `index.html`, preencha o bloco `window.SOACO`:

| Campo | O que é |
|---|---|
| `ADS_ID` | ID da tag do Google Ads (`AW-...`) |
| `ADS_LABEL_LEAD` | Rótulo da conversão de lead (formulário) |
| `ADS_LABEL_CLICK` | Rótulo da conversão de clique (opcional) |
| `GA4_ID` | ID do GA4 (`G-...`, opcional) |
| `WHATSAPP` | Número com DDI + DDD, só dígitos. Já configurado: `558699950140` (+55 86 9995-0140) |

Troque também `SEUDOMINIO.com.br` pelo domínio real (canonical, Open Graph e dados estruturados).

## Rodar localmente

```bash
docker build -t lp-soaco .
docker run --rm -p 8080:80 lp-soaco
# http://localhost:8080
```
