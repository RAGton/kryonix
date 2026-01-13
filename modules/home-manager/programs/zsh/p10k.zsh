# Powerlevel10k (p10k)
# Arquivo compartilhado entre todas as máquinas via Home Manager.
#
# Para personalizar do seu jeito:
# 1) Rode `p10k configure` no terminal
# 2) Copie o conteúdo gerado em ~/.config/zsh/.p10k.zsh
# 3) Cole aqui (este arquivo) e rode `home-manager switch --flake .#rag@<host>`

# Exemplo mínimo (substitua pela sua configuração completa):
typeset -g POWERLEVEL9K_MODE='nerdfont-complete'
typeset -g POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(user dir vcs)
typeset -g POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(status time)
