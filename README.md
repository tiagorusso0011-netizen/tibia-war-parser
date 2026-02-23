# ⚔️ Havera Combat Log Parser & Ranking Engine

## 🛡️ Visão Geral e Racional de Negócio
Este projeto foi desenvolvido para resolver o desafio técnico de parsing de logs de combate, utilizando uma modelagem de domínio inspirada em servidores de MMORPG (OTServers), especificamente o servidor **Havera**.

Diferente de implementações genéricas, este sistema foi desenhado com uma mentalidade de **Tech Lead**, separando a inteligência de processamento da interface de comunicação, garantindo que o motor lógico seja agnóstico à plataforma que o consome.

## 🏗️ Arquitetura de Microsserviços
A solução utiliza uma arquitetura híbrida para máxima eficiência:
* **Core Engine (Worker):** Desenvolvido em **Ruby 3.x**. Escolhido por sua excelência em manipulação de strings, expressividade em Programação Orientada a Objetos e facilidade de implementação de regras de negócio complexas.
* **API Gateway:** Desenvolvida em **Node.js (NestJS)**. Atua como a porta de entrada para o mundo exterior, gerenciando uploads de arquivos, validações de segurança e comunicação com o Worker.

## 🚀 Como Executar (Docker Ready)
O projeto está totalmente "containerizado" para garantir que rode em qualquer ambiente sem necessidade de configurações manuais.

1.  Certifique-se de ter o Docker instalado.
2.  Na raiz do projeto, execute:
    ```bash
    docker-compose up --build
    ```
3.  A API estará disponível em: `http://localhost:3000/api/v1/wars/upload`

## 🛡️ Segurança e Resiliência (Implementações de Elite)
Para elevar o projeto ao nível de produção, foram implementadas as seguintes travas:
* **Validação de Integridade:** A API realiza um "sanity check" no cabeçalho do arquivo para garantir que apenas logs válidos de Havera sejam processados.
* **Trava de Payload:** Limite rigoroso de **10MB** por upload para prevenir ataques de negação de serviço (DoS).
* **Isolamento de Processos:** O motor Ruby é executado como um *Child Process* assíncrono, protegendo o loop de eventos principal do Node.js.
* **Sanitização de Diretórios:** Implementação de limpeza automática de arquivos temporários e proteção contra *Path Traversal*.

## 🏆 Regras de Negócio Implementadas
- [x] Ranking por Batalha com cálculo de Frags e Mortes (considerando mortes por `<WORLD>`).
- [x] Eventos Múltiplos processados no mesmo arquivo de log.
- [x] **Bônus:** Identificação do MVP (Most Valuable Player) com sua Magia/Runa favorita.
- [x] **Bônus:** Cálculo de *Killstreak* (maior sequência de kills sem morrer).
- [x] **Bônus:** Sistema de conquistas dinâmicas (Awards como "Survivor" e "Annihilator").

---
**Desenvolvido por:** Tiago Augusto da Silva Russo