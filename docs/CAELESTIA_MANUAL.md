# Manual rápido do Caelestia no RagOS VE

Hyprland continua sendo o desktop. Caelestia é a camada de shell e UI da sessão.

## Atalhos principais

| Atalho | Ação |
| --- | --- |
| `SUPER+A` | Abrir o launcher do Caelestia |
| `SUPER+D` | Abrir o centro de controle do Caelestia |
| `SUPER+G` | Abrir o dashboard do Caelestia |
| `SUPER+N` | Abrir a sidebar de notificações |
| `SUPER+X` | Abrir o menu de sessão/energia |
| `SUPER+L` | Bloquear a sessão |
| `CTRL+ALT+L` | Bloquear a sessão |
| `SUPER+SHIFT+Backspace` | Limpar todas as notificações |
| `SUPER+C` | Calculadora auxiliar |
| `SUPER+SHIFT+S` | Captura de área |
| `SUPER+CTRL+S` | Captura da tela inteira |
| `SUPER+CTRL+R` | Menu de gravação |
| `SUPER+SHIFT+R` | Iniciar gravação |
| `SUPER+O` | Menu de áudio |
| `SUPER+W` | Menu de rede/Bluetooth |

## Launcher

O launcher do Caelestia aceita apps e ações pelo prefixo `>`.

Comandos úteis:

- `>calc 2+2`
- `>scheme dynamic`
- `>variant vibrant`
- `>wallpaper`

Para abrir um app, basta digitar o nome normal do programa no launcher.

## Wallpapers

A galeria usada pelo shell fica em `~/.local/share/wallpapers`.

Para trocar o wallpaper pela CLI:

```sh
caelestia wallpaper -f /caminho/para/imagem.png
```

Para usar a paleta dinâmica com o papel de parede atual:

```sh
caelestia scheme set -n dynamic
```

Se o launcher mostrar poucos wallpapers, confirme se as imagens estão nesse diretório e se a configuração do home aponta para ele.

## Observações

- O caminho principal da interface é o Caelestia, não rofi.
- Os menus de áudio e rede ainda usam utilitários auxiliares porque não têm substituto nativo equivalente no shell atual.
- Se o wallpaper não aparecer no launcher, o problema quase sempre é diretório vazio ou caminho desalinhado.
