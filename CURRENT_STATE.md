# Alien Drop Zone — Estado Atual do Projeto

> Snapshot de 29/09/2026 (commit `38ab4db`). Godot 4.7, ~1.600 linhas de GDScript.

## Resumo

O protótipo é jogável do início ao fim: **Tela Inicial → Jogo → Game Over → Tentar Novamente / Menu**, com recorde salvo em disco. O núcleo mecânico (queda, pouso, inimigos, power-ups, fases) está implementado. Faltam **áudio**, **efeitos de "game feel"** e alguns elementos que foram criados mas nunca conectados (ver [Pendências](#pendências)).

## Como executar

1. Instale o **Godot 4.7** ou mais recente (versão padrão, não .NET): https://godotengine.org/download
2. No Project Manager, clique em **Importar** e selecione `project.godot`.
3. Pressione **F5** para rodar a partir da tela inicial.

No WSL, sem suporte a Vulkan, rode com o renderizador OpenGL:

```bash
./Godot_v4.7-stable_linux.x86_64 --path . --rendering-driver opengl3
```

## Controles

| Ação | Teclas |
|---|---|
| Mover | A / D ou ← / → |
| Dobrar paraquedas (mergulho) | S, Espaço ou ↓ |
| Pausar | P ou Esc |
| Iniciar (tela inicial) | Enter ou Espaço |

## Funcionalidades implementadas

### Jogador ([Parachuter.gd](scripts/Parachuter.gd))
- Movimento horizontal a 320 px/s, limitado às bordas da tela.
- Queda com paraquedas aberto a **140 px/s**; dobrado a **420 px/s**.
- Escudo absorve um golpe e concede 1,5 s de invencibilidade (com piscar).
- Quando capturado pelo feixe trator, é puxado para cima a 250 px/s.

### Pouso ([Game.gd](scripts/Game.gd), [LandingZone.gd](scripts/LandingZone.gd))

| Resultado | Condição | Efeito |
|---|---|---|
| Pouso Perfeito | até 45 px do centro da plataforma | +500 +300 (bônus de fase) |
| Pouso na Borda | resto da plataforma | +200 +300 |
| Espatifou | velocidade de pouso > 350 px/s (paraquedas dobrado) | perde 1 vida |
| Passou Direto | sai pela base da tela | perde 1 vida |
| Atingido | contato com alien ou projétil, sem escudo | perde 1 vida |

Após um pouso bem-sucedido, a fase avança e a plataforma muda para uma posição X aleatória. Ao perder uma vida, a mesma fase recomeça.

### Inimigos

| Tipo | Script | Comportamento | Aparece a partir de |
|---|---|---|---|
| Patroller | [AlienPatroller.gd](scripts/AlienPatroller.gd) | Cruza a tela na horizontal e desce 48 px a cada borda | Fase 1 |
| Capture / Hunter | [AlienCapture.gd](scripts/AlienCapture.gd) + [TractorBeam.gd](scripts/TractorBeam.gd) | Mini-chefe: persegue o jogador no eixo X com feixe trator permanente; máximo de 1 na tela | Fase 2 (40%) |
| Shooter | [AlienShooter.gd](scripts/AlienShooter.gd) | Flutua na horizontal e dispara projéteis mirados a cada 2,5 s | Fase 3 |

Na fase 3 em diante, os três tipos têm ~33% de chance cada.

### Power-ups ([ItemPickup.gd](scripts/ItemPickup.gd))
Um item cai a cada 6–10 s, com tipo sorteado:

| Item | Efeito |
|---|---|
| Medkit | +1 vida (máximo 3) |
| Turbo | velocidade horizontal ×2 por 5 s |
| Escudo | absorve o próximo golpe |
| Bomba | remove todos os aliens, projéteis e itens da tela |
| Estrela | +500 pontos |

### Progressão de dificuldade ([GameManager.gd](scripts/GameManager.gd))

| Parâmetro | Fórmula | Fase 1 | Fase 5 | Limite |
|---|---|---|---|---|
| Velocidade dos aliens | 1 + 0,25 × (fase − 1) | 1,0× | 2,0× | sem limite |
| Intervalo de spawn | 2,0 − 0,2 × (fase − 1) | 2,0 s | 1,2 s | mín. 0,7 s |
| Largura da plataforma | 300 − 20 × (fase − 1) | 300 px | 220 px | mín. 120 px |
| Aliens iniciais | — | 0 | 1 | 1 |

### Interface e telas
- **HUD:** pontuação, fase atual, ícones de vida e banner de fase.
- **Pausa:** overlay escurecido.
- **Tela Inicial:** título, UFO animado e recorde.
- **Game Over:** pontuação final, recorde e aviso de novo recorde.
- **Persistência:** recorde em `user://highscore.dat`.

### Visual
- Sprites HD customizados para jogador, 3 aliens e 5 power-ups, mais um fundo espacial, carregados em runtime via `Image.load()`.
- Estrelas e nuvens procedurais com scroll ([BackgroundScroll.gd](scripts/BackgroundScroll.gd)).
- Feixe trator e projéteis desenhados proceduralmente.

## Estrutura do projeto

```
scenes/
  Game.tscn                 cena principal (HUD, spawn, jogador, plataforma, pausa)
  menus/                    TitleScreen, GameOver
  player/Parachuter.tscn
  enemies/                  AlienPatroller, AlienShooter, AlienCapture
  world/                    LandingZone, ItemPickup
scripts/
  GameManager.gd            autoload: pontos, vidas, fase, dificuldade, recorde
  Game.gd                   fluxo de fase, pouso, perda de vida, game over
  SpawnManager.gd           spawn de aliens e itens por fase
  AlienBase.gd              classe base dos inimigos
  ...                       um script por cena/entidade
assets/
  sprites/                  9 sprites PNG
  backgrounds/space_bg.png
```

## Pendências

### Não iniciado (previsto no README)
- *(nenhum item restante nesta categoria — ver "Parcialmente implementado" abaixo)*

### Parcialmente implementado
- **Áudio:** [AudioManager.gd](scripts/AudioManager.gd) (autoload) toca os efeitos em `assets/audio/` — `whoosh` (dobrar paraquedas), `thud` (pouso), `crash` (espatifar), `hit` (dano), `pickup` (coletar item), `laser` (tiro do Shooter) — e um loop manual de `theme.wav` como música de fundo, iniciado em `TitleScreen.gd` e `Game.gd`. Falta apenas o zumbido do feixe trator (nenhum asset fornecido para isso).
- **Game feel (partículas):** [Effects.gd](scripts/Effects.gd) adiciona um helper `Effects.spawn_burst()` (CPUParticles2D one-shot), usado no rastro de mergulho e morte do jogador ([Parachuter.gd](scripts/Parachuter.gd)), na coleta de itens ([ItemPickup.gd](scripts/ItemPickup.gd)) e na destruição de aliens ([AlienBase.gd](scripts/AlienBase.gd)). Ainda faltam: screen shake, hit-stop e um `Line2D`/rastro de fumaça mais elaborado.

### Implementado pela metade (código existe, mas não está conectado)
- **Aviso de feixe trator:** o método `HUD.show_beam_warning()` ([HUD.gd:76](scripts/HUD.gd#L76)) e o label "⚠ FEIXE ALIEN!" existem, mas nunca são chamados. O lugar natural é a captura em `TractorBeam._set_player_captured()`.
- **Animação de morte:** `Parachuter.die()` procura a animação `"death"`, mas o `AnimationPlayer` da cena está vazio. O jogador apenas congela.
- **Destruir aliens:** `AlienBase.destroy()`, o sinal `alien_destroyed` e o `score_value` de cada alien nunca são usados. O jogador não tem ataque, e a Bomba remove inimigos sem dar pontos.
- **Sinais sem ouvinte:** `Parachuter.landed` e `Parachuter.chute_folded` (este emitido a cada frame de física). A constante `LIVES_PER_PHASE_BONUS` também não é usada.

### Conexões de sinal quebradas (provável spam de erros no console)
- [AlienCapture.tscn:52-53](scenes/enemies/AlienCapture.tscn#L52-L53) conecta `body_entered` e `body_exited` do feixe a `_on_area_2d_body_entered` e `_on_area_2d_body_exited`, mas esses métodos não existem em `TractorBeam.gd`, que usa polling via `get_overlapping_bodies()`.
- [AlienPatroller.tscn:45](scenes/enemies/AlienPatroller.tscn#L45) e [AlienCapture.tscn:50](scenes/enemies/AlienCapture.tscn#L50) conectam o sinal `body_entered` de um `CharacterBody2D`, que não tem esse sinal. O dano por contato funciona mesmo assim, via colisões do `move_and_slide()`.

### Problemas menores de gameplay
- **Medkit inútil no início:** o jogo começa com o máximo de 3 vidas, então o Medkit não faz nada até o primeiro dano.
- **Game Over sem teclado:** nenhum botão recebe foco, então é preciso usar o mouse.
- **Transição de fundo:** a troca de estrelas para nuvens depende do tempo total de jogo (~33 s) e nunca reinicia. Depois disso, todas as fases mostram nuvens.
- **Timers durante a pausa:** os `get_tree().create_timer()` continuam contando com o jogo pausado. Pausar logo após um pouso ou morte ainda avança ou reinicia a fase por trás do overlay.
- **Sem condição de vitória:** as fases são infinitas e a velocidade dos aliens cresce sem limite.
- **Resíduos:** os polígonos antigos continuam nos `.tscn` e são apagados em runtime pelos scripts.
- **README impreciso:** o README descreve o pouso perfeito como no "centro matemático exato", mas a tolerância real é de 45 px.

## Próximos passos sugeridos

1. Corrigir as conexões de sinal quebradas (rápido; limpa o console).
2. Conectar o aviso de feixe trator ao HUD.
3. Adicionar áudio (SFX + BGM).
4. Adicionar partículas (rastro no mergulho, explosão ao espatifar, coleta de item) e a animação de morte.
5. Dar foco ao botão "Tentar Novamente" no Game Over.
6. Definir se o jogo terá fim (fase final ou chefe) ou um teto de dificuldade.
