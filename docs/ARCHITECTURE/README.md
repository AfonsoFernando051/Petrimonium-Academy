# Atlas Técnico — lado Academy

O Atlas Técnico do ecossistema vive em um lugar só, porque quase toda
funcionalidade atravessa mais de um repositório e documentá-la em pedaços
separados garante que os pedaços divirjam:

**➜ `Petrimonium-Backend/docs/ARCHITECTURE/`**

- `README.md` — o método, o formato das fatias e o índice completo
- `00-visao-geral.md` — o mapa dos 4 repositórios e dos 3 produtos
- `fatias/` — uma funcionalidade por arquivo, sempre ponta a ponta

E o acordo entre os produtos — o que é compartilhado, o que nunca atravessa a
fronteira e quais são as lacunas conhecidas — em
**`Petrimonium-Backend/docs/INTEGRATION.md`**.

## O que é específico deste repositório

| Fato | Valor |
|---|---|
| `ApiConstants.appContext` | `'academy'` — fixo, não é flag de build |
| Endpoints exclusivos | ver visão geral §5 |
| DI | `lib/core/di/dependency_injection.dart` (estático, não `get_it`) |
| Cliente HTTP | `lib/core/network/api_client.dart` — tokens, 401/refresh/retry |

## Aviso que vale para todo PR neste repositório

Wallet e Academy nasceram como clones do mesmo código. **Um arquivo com o
mesmo caminho no outro repositório pode ter divergido.** Compare antes de
copiar uma correção de um lado para o outro.

O Health é um caso diferente e mais perigoso: ele **não** veio desse clone.
Tem a própria camada de rede, o próprio controller de estado e o próprio tema.
Um nome de arquivo igual lá não indica implementação parecida.
