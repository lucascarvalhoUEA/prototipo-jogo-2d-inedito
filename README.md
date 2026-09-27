# Alien Drop Zone - Documento do Projeto

Este repositório contém o código do jogo **Alien Drop Zone**, um arcade 2D de queda-livre na Godot Engine 4.

## 🎯 Conceito Central
Um jogo de ação em queda-livre onde o jogador controla um paraquedista descendo por um espaço infestado de naves alienígenas. O objetivo é desviar das ameaças e pousar com segurança e precisão em uma plataforma na base da tela.

## 🎨 Estado Visual
O jogo possui arte vetorizada 2D customizada:
- Sprites HD carregados em runtime via `Image.load()` para evitar gargalos do importador da Godot e aplicar mipmapping.
- UI refinada com efeitos de Drop Shadow, ícones gráficos para vidas e fundo dinâmico estrelado.
- Feixes de laser (Tractor Beam) gerados processualmente sobre as sprites das naves alienígenas (Alien Capture).

## 🕹️ Mecânicas Principais
- **Física do Paraquedas:** Alternância entre Queda Suave (Paraquedas aberto) e Mergulho Acelerado (Paraquedas dobrado) para manobras evasivas.
- **Pouso de Precisão:** Pousar no centro matemático exato da plataforma recompensa com "Pouso Perfeito" (+500 pts). Pousar nas pontas concede um "Pouso na Borda". Esquecer de abrir o paraquedas resulta em morte fatal ("Espatifou").
- **3 Variantes Inimigas:** Patroller (Físico/Zigue-Zague), Shooter (Artilharia/Tiro) e Capture (Laser/Feixe Trator).
- **5 Power-Ups:** Escudo, Bomba Limpa-Tela, Turbo, Medkit e Estrela de Pontos.

## 🔜 Próximas Atualizações Previstas
A base estrutural mecânica e de recursos está 100% pronta. O escopo final focará na adição de **Áudio** (SFX e BGM) e refinamento do **"Game Feel"** usando `CPUParticles2D` e `Line2D` para rastros e fumaça.
