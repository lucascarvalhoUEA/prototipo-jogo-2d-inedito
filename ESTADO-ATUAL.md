# Estado Atual do Protótipo (Alien Drop)

Este documento serve como um registro consolidado do estado atual de desenvolvimento do nosso jogo de paraquedismo sci-fi, destacando tudo o que já foi implementado de forma estável, as regras de negócio e os próximos passos.

## 🎯 Conceito Central
Um jogo de sobrevivência em queda-livre onde o jogador controla um paraquedista descendo através de camadas atmosféricas infestadas de alienígenas. O objetivo é sobreviver à descida e pousar com segurança em uma plataforma móvel na base da tela para avançar às próximas fases.

---

## 🕹️ Mecânicas de Jogabilidade (Gameplay)

### 1. O Paraquedista (Player)
- **Movimentação:** Usa `A`/`D` ou Setas para planar horizontalmente.
- **Velocidade de Queda (Mecânica de Risco/Recompensa):**
  - **Paraquedas Aberto:** Queda suave (140 px/s). Mais controle, mas mais tempo exposto aos inimigos.
  - **Paraquedas Fechado (Mergulho):** Ao segurar `S` (Baixo) ou `Espaço`, o paraquedas se fecha e o jogador mergulha a uma velocidade insana (420 px/s) para fugir de situações de perigo.
- **Sistema de Pouso (Crash Mechanic):** A plataforma de pouso (`LandingZone`) muda de posição horizontal a cada fase. Se o jogador tocar a base da tela ou a plataforma em velocidade de mergulho (velocidade > 250 px/s), o boneco se espatifa ("Crash") e o jogador perde uma vida. É **obrigatório** abrir o paraquedas próximo ao chão para um pouso seguro.
- **Pausa:** O jogo pode ser pausado e despausado a qualquer momento com a tecla `P` (gerenciado de forma assíncrona pelo `PauseHandler`).

### 2. Inimigos (A Ameaça Alienígena)
A progressão de ondas é gerenciada pelo `SpawnManager`, que escala a dificuldade e dita quais naves aparecem dependendo da fase atual:
- **🛸 Alien Patroller (Patrulheiro):** Inimigo comum. Flutua da esquerda para a direita quicando nas bordas da tela enquanto cai em direção ao jogador sob efeito da gravidade. 
- **🔴 Alien Shooter (Atirador):** Inimigo de artilharia. Entra pela parte superior, estaciona em uma altura fixa da tela e começa a atirar projéteis de energia em linha reta para baixo.
- **👾 Alien Capture (O Caçador / Mini-Boss):**
  - Tem spawn limitado a apenas **1 por tela**.
  - Não possui gravidade. Ele nasce sempre no topo e possui uma animação de "descida suave" até o campo de visão.
  - **Inteligência Artificial:** Possui inércia matemática. Ele lê a posição X do jogador e desliza tentando se manter exatamente em cima do paraquedista (com derrapagem baseada em física).
  - **Ameaça:** Projeta um **raio trator roxo permanente** de 350 pixels. Se o jogador encostar no raio, fica preso e levita até a nave, perdendo uma vida.

### 3. Sistema de Power-Ups (Itens)
De tempos em tempos, itens caem do céu. Há 5 tipos no momento:
- 💊 **Vida Extra:** Restaura o contador de vidas do jogador.
- ⚡ **Turbo (Boost):** Dobra a velocidade de esquiva horizontal temporariamente.
- 🛡️ **Escudo:** Cria uma bolha que absorve exatamente 1 (um) hit letal (tiro ou nave).
- 💣 **Bomba (Limpa-Tela):** Vaporiza instantaneamente todos os inimigos, tiros e naves da tela atual, criando uma rota de fuga de emergência (Possui sistema de fail-safe que impede que o jogador fique travado caso o Caçador seja destruído enquanto o suga).
- ⭐ **Estrela (Pontuação):** Concede 500 pontos extras.

---

## 🛠️ Arquitetura e Código (Sistemas Consolidados)
- **`GameManager` (Autoload/Singleton):** Guarda o estado global da partida (Score, Vidas, Fase atual) para que a interface e o jogo se comuniquem perfeitamente.
- **`Game.gd` (Controlador de Sessão):** Orquestra o ciclo de vida da fase. Quando o jogador morre ou passa de nível, ele executa um "Reset Limpo" (`_clear_enemies`), removendo todo o lixo da tela (aliens, tiros e power-ups residuais) antes de reposicionar o jogador e sortear a nova `LandingZone`.
- **Clean State (Prevenção de Bugs):** O estado de "Capturado" no jogador não é mais um interruptor binário que pode bugar se mais de uma coisa acontecer ao mesmo tempo. Ele usa um contador de instâncias virtuais (`add_capture` / `remove_capture`) e as naves avisam o código de encerramento (`_exit_tree()`) caso sejam deletadas enquanto executam ações.

---

## 🔜 Próximos Passos e Metas (O que falta fazer?)
Atualmente o jogo é um **Protótipo Mecânico Perfeito**, construído 100% usando caixas geométricas sólidas (`Polygon2D`) do próprio motor, provando que a jogabilidade (Game Feel) funciona de forma brilhante e responsiva.

O próximo salto no escopo do projeto é transformá-lo num produto visual finalizado ("Suco"):
1. **Ativos Visuais (Sprites 2D):**
   - Substituir os polígonos coloridos por arquivos PNG reais (O Paraquedista, Spritesheets das Naves, Fundo estrelado/Céu).
2. **Sistema de Áudio (SFX / BGM):**
   - Implementar música de fundo e efeitos sonoros vitais (Som de abrir/fechar o paraquedas, explosões, tiro do alien vermelho, raio trator do roxo, som ao pegar power-up, alarme de crash).
3. **Efeitos Visuais e Polimento (VFX):**
   - Implementar "Rastros" (`Line2D`) ao fechar o paraquedas (indicando alta velocidade).
   - Partículas (`CPUParticles2D`) de fumaça ao fazer pouso bruto ou explodir.
