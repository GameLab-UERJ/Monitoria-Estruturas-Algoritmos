# Projeto Monitoria

Jogo educativo de ensino de lógica de programação, construído em **Godot 4.6** com **GDScript**.

A ideia central do projeto (disciplina de Monitoria de Estruturas e Algoritmos) é transformar o
exercício de programar em um jogo de fazenda em grade: o jogador comanda um drone que planta e
colhe plantas, mas **não aperta botões para jogar** — ele escreve um pequeno programa em
pseudo-código num painel de comandos, e o jogo executa esses comandos como um interpretador.

---

## O jogo

- Cenário 2D visto de cima, com terreno em grade gerado proceduralmente.
- O jogador controla um drone que se move **um bloco por vez**, com colisão contra pedras e bordas.
- O terreno sorteia, por célula: **15%** pedra (obstáculo), **30%** broto e **55%** solo vazio.
- Plantas crescem por tics de `Timer`: `broto` → estágios intermediários → `flor` (colhível).
- Cada estágio tem um objetivo do tipo *colete N plantas em menos de M passos*, exibido no HUD
  junto com barras de progresso de plantas e passos.
- O drone carrega um **inventário de 10 slots de sementes**; plantar consome uma semente do slot
  indicado e colher devolve a celula para solo vazio.

### Loop de jogo

```text
1. O jogador escreve um bloco de comandos no painel
        ↓
2. Clica em "Executar" e o interpretador valida a sintaxe
        ↓
3. O drone executa os comandos um a um (movimento, plantio, colheita)
        ↓
4. As plantas crescem com o tempo enquanto o jogador planeja
        ↓
5. Bate o objetivo de plantas/passos para avançar de estágio
```

---

## A linguagem de comandos

Implementada em `scripts/prompt_de_comando.gd`, que faz o *parsing* linha a linha, expande blocos
e executa as ações com `await`. Erros de sintaxe e de execução são reportados no histórico ao lado
do painel, e **nada** é executado se o bloco for inválido.

### Comandos válidos

| Comando            | Efeito                                              |
| ------------------ | --------------------------------------------------- |
| `move_up`          | Move o drone um bloco para cima                     |
| `move_down`        | Move o drone um bloco para baixo                    |
| `move_left`        | Move o drone um bloco para a esquerda               |
| `move_right`       | Move o drone um bloco para a direita                |
| `plant(n)`         | Planta a semente do slot `n` (1 a 10) na celula atual |
| `collect`          | Colhe a planta que estiver no estagio `flor`        |
| `open`             | Abre o inventário                                  |
| `close`            | Fecha o inventário                                 |

### Blocos

| Bloco              | Descrição                                                        |
| ------------------ | ---------------------------------------------------------------- |
| `repeat(n):`       | Repete o bloco indentado `n` vezes (expanded antes de executar). |
| `if <condição>:`   | Executa o bloco indentado só se a condição for verdadeira.        |

Condições aceitas: `pode_plantar` e `pode_colher`.

### Exemplo

```text
repeat(2):
	move_right
	plant(3)
	collect
```

```text
if pode_plantar:
	plant(1)
	collect
```

> A indentação do bloco é feita com **tabs ou espaços** — a validação aceita os dois, mas o guia de
> estilo do projeto pede tabs.

---

## Estágios

| Estágio        | Grade  | Plantas a coletar | Limite de passos | Próxima cena                     |
| -------------- | ------ | ----------------- | ---------------- | -------------------------------- |
| Estágio 1      | 4 x 4  | 1                 | 15               | `scenes/nivel2.tscn`             |
| Estágio 2      | 4 x 8  | 1                 | 20               | `scenes/nivel3.tscn`             |
| Estágio 3      | 8 x 8  | 1                 | 22               | Menu principal                   |

O tamanho do Estágio 1 pode ser alterado no menu inicial, nos campos **linhas** e **colunas**
(valores menores ou iguais a zero caem no padrão `4 x 4`).

---

## Como executar

1. Instale o [Godot 4.6](https://godotengine.org/download) (com ou sem .NET — o projeto usa
   apenas GDScript).
2. No editor, abra o `project.godot` desta pasta.
3. Execute (`F5`). A cena principal é `scenes/control.tscn` (menu inicial).

Configurações relevantes do projeto:

- Renderizador: **Forward Plus**, filtro de textura padrão **nearest** (pixel art).
- Física 3D: **Jolt Physics** (o jogo em si é 2D).
- Stretch: `canvas_items`.

---

## Controles

| Ação                                | Controle                    |
| ----------------------------------- | --------------------------- |
| Mover o drone                       | Setas do teclado            |
| Digitar o programa                  | Painel de comando (CodeEdit) |
| Executar o bloco                    | Botão `Executar`            |
| Abrir/fechar inventário pelo código | `open` / `close`            |

As setas continuam funcionando para movimentação direta — elas são o caminho para aprender a
traduzir a ação manual em comando.

---

## Estrutura do projeto

```text
project/
├── assets/          # sprites, tilesets, fontes pixeladas (PixelOperator)
├── inventory/       # sistema de inventário (Inv, InvItem, slots, itens .tres)
├── scenes/          # menu, HUD/Interface, estágios e player
├── scripts/         # lógica do jogo (player, tile_map_layer, prompt_de_comando, ...)
├── GuideLines.md    # guia de estilo, commits, branches e PRs
├── Ideia para Prototipo de Minijogo.md
└── project.godot
```

Mapa dos scripts principais:

| Script                            | Responsabilidade                                                |
| --------------------------------- | --------------------------------------------------------------- |
| `scripts/prompt_de_comando.gd`    | Interpretador da linguagem de comandos (parsing e execução)     |
| `scripts/player.gd`               | Movimento em grade, colisão e animação de interação             |
| `scripts/tile_map_layer.gd`       | Geração do terreno, crescimento e plantio/colheita por célula   |
| `scripts/game_manager.gd`         | Objetivos, contadores de passos/frutas e troca de cena          |
| `scripts/timer.gd`                | Tic de crescimento das plantas                                  |
| `inventory/inventario_hud.gd`     | Abertura do inventário e leitura dos slots                      |

Convenções de código (tabs, `snake_case`, tipagem explícita, ordem de declarações) e padrão de
commits/PRs estão em [GuideLines.md](GuideLines.md) — seguir esse guia antes de abrir um PR.

---

## Status e próximos passos

Protótipo em andamento. O que já funciona e o que ainda está aberto:

- [x] Geração procedural do terreno e crescimento das plantas
- [x] Interpretador de comandos com `repeat`, `if`, `plant(n)` e `collect`
- [x] Inventário de sementes com consumo por slot
- [x] HUD de objetivo, passos e plantas + 3 estágios encadeados
- [ ] Botão **Configurações** do menu (sem comportamento implementado)
- [ ] `scenes/fruit.tscn` ainda não é instanciada por nenhuma cena
- [ ] `proxima_cena` do Estágio 3 está gravado com aspas extras no `.tscn`, o que quebra a troca
      de cena de volta ao menu
- [ ] Áudio, animações de vitória/derrota e balanceamento dos limites de passos

O escopo do protótipo está sendo documentado em
[Ideia para Prototipo de Minijogo.md](<Ideia%20para%20Prototipo%20de%20Minijogo.md>).

---

## Documentação relacionada

- [GuideLines.md](GuideLines.md) — padrão de commits, branches, PRs e estilo de código.
- [Ideia para Prototipo de Minijogo.md](<Ideia%20para%20Prototipo%20de%20Minijogo.md>) — template
  de design doc do minijogo.
- [Style guide do GDScript](https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_styleguide.html)
- [Conventional commits](https://www.conventionalcommits.org/pt-br/v1.0.0/)
