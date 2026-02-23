# ⚔️ FPS / OTServer Combat Log Parser & Ranking Engine

## Visão Geral
Em vez de seguir o modelo tradicional e óbvio de jogos FPS genéricos, este projeto resolve o desafio de parsing de logs utilizando um domínio inspirado em MMORPGs (como Tibia ou servidores customizados). 

A lógica matemática e as regras de negócio permanecem rigorosamente as mesmas exigidas no desafio, mas a modelagem de domínio (Domain-Driven Design) foi adaptada. Onde havia "armas", temos "Magias/Runas"; onde havia "partidas", temos "Batalhas".

## Arquitetura & Stack (Microsserviços)
* **Core Engine (Worker):** Ruby 3.x (Foco extremo em SOLID e Orientação a Objetos).
* **API Gateway:** Node.js com NestJS.
* **Fluxo:** O NestJS recebe o arquivo de log via upload HTTP (`/api/v1/wars/upload`), aciona o script em Ruby passando o caminho do arquivo, o Ruby processa as regras de negócio e devolve o JSON estruturado para a API.

## Resolução das Regras & Bônus
- [x] Ranking por Batalha com cálculo de Frags e Mortes.
- [x] Eventos Múltiplos no mesmo arquivo.
- [x] Mortes pelo `<WORLD>` ignoradas para frags, mas contabilizadas como morte.
- [x] **Bônus:** Arma/Magia preferida do MVP identificada.
- [x] **Bônus:** *Killstreak* (maior sequência de frags sem morrer).
- [x] **Bônus:** Awards dinâmicos (`Survivor` para 0 mortes e `Annihilator` para 5 kills em 1 min).