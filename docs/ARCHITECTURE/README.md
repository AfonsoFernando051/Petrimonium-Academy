# Atlas Técnico — lado Academy

O Atlas Técnico do ecossistema vive em um lugar só, porque quase toda
funcionalidade atravessa os três repositórios e documentá-la em pedaços
separados garante que os pedaços divirjam:

**➜ `Petrimonium-Backend/docs/ARCHITECTURE/`**

- `README.md` — o método, o formato das fatias e o índice completo
- `00-visao-geral.md` — o mapa dos 3 repositórios
- `fatias/` — uma funcionalidade por arquivo, sempre ponta a ponta

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
