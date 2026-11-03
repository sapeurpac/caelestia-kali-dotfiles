#!/usr/bin/env bash
#
# install.sh — Reconstruit l'environnement Hyprland + Caelestia sur une Kali standard.
#
# Usage :
#   ./install.sh            # sauvegarde l'existant puis pose les dotfiles (symlinks)
#   ./install.sh --copy     # idem mais copie les fichiers au lieu de symlinks
#   ./install.sh --deps     # installe en plus les paquets apt disponibles
#   ./install.sh --deps --copy
#
# Ne touche JAMAIS à tes secrets : ce dépôt ne contient que de la config visuelle.
set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_SRC="$REPO/config"
STAMP="$(date +%Y%m%d-%H%M%S)"
BACKUP="$HOME/.config-backup-$STAMP"
MODE="link"
WITH_DEPS=0

for arg in "$@"; do
  case "$arg" in
    --copy) MODE="copy" ;;
    --deps) WITH_DEPS=1 ;;
    -h|--help) grep '^#' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
    *) echo "Argument inconnu : $arg" >&2; exit 1 ;;
  esac
done

say()  { printf '\033[38;5;75m::\033[0m %s\n' "$*"; }
warn() { printf '\033[38;5;214m!!\033[0m %s\n' "$*"; }
ok()   { printf '\033[38;5;78m ✓\033[0m %s\n' "$*"; }

# ----------------------------------------------------------------------------
# 1. Dépendances apt (optionnel : --deps)
# ----------------------------------------------------------------------------
APT_PKGS=(
  hyprland                # compositeur Wayland
  foot fuzzel kitty       # terminal, lanceur, terminal 2
  cava btop fastfetch     # visualiseur audio, moniteur, infos système
  fish                    # shell
  qt6ct qt5ct             # thèmes Qt
  qt6-style-kvantum qt5-style-kvantum
  gnome-themes-extra      # fournit Arc-Dark / préférence sombre
  python3-venv python3-pip
  grim slurp wl-clipboard # captures + presse-papier Wayland
  brightnessctl playerctl # médias / rétroéclairage (keybinds)
  fonts-firacode          # police mono de secours
  jq git curl
)

if [ "$WITH_DEPS" -eq 1 ]; then
  say "Installation des paquets apt disponibles sur Kali…"
  sudo apt-get update
  # on installe au mieux : un paquet manquant n'arrête pas tout
  for p in "${APT_PKGS[@]}"; do
    sudo apt-get install -y "$p" 2>/dev/null && ok "$p" || warn "$p indisponible via apt (voir section manuelle)"
  done
else
  say "Étape dépendances ignorée (relance avec --deps pour les installer)."
fi

# ----------------------------------------------------------------------------
# 2. Sauvegarde de l'existant
# ----------------------------------------------------------------------------
say "Sauvegarde des configs existantes dans $BACKUP"
mkdir -p "$BACKUP"
while IFS= read -r -d '' item; do
  rel="${item#"$CONFIG_SRC"/}"          # ex: hypr, foot/foot.ini
  top="${rel%%/*}"                       # dossier applicatif de 1er niveau
  dst="$HOME/.config/$top"
  if [ -e "$dst" ] && [ ! -e "$BACKUP/$top" ]; then
    cp -a "$dst" "$BACKUP/$top"
  fi
done < <(find "$CONFIG_SRC" -mindepth 1 -maxdepth 1 -print0)
# starship.toml est un fichier, pas un dossier
[ -e "$HOME/.config/starship.toml" ] && cp -a "$HOME/.config/starship.toml" "$BACKUP/" || true
ok "Sauvegarde faite (restaurable depuis $BACKUP)"

# ----------------------------------------------------------------------------
# 3. Pose des dotfiles
# ----------------------------------------------------------------------------
place() {  # $1 = source dans le dépôt, $2 = destination
  local src="$1" dst="$2"
  mkdir -p "$(dirname "$dst")"
  rm -rf "$dst"
  if [ "$MODE" = "link" ]; then ln -s "$src" "$dst"; else cp -a "$src" "$dst"; fi
}

say "Pose de la configuration (mode : $MODE)…"
# Dossiers applicatifs de ~/.config
for d in "$CONFIG_SRC"/*/; do
  name="$(basename "$d")"
  place "${d%/}" "$HOME/.config/$name"
  ok "~/.config/$name"
done
# Fichiers isolés de ~/.config
place "$CONFIG_SRC/starship.toml" "$HOME/.config/starship.toml"; ok "~/.config/starship.toml"

# Scripts du HOME
install -Dm755 "$REPO/home/autowall.sh" "$HOME/autowall.sh"; ok "~/autowall.sh"

# ----------------------------------------------------------------------------
# 4. Substitution des chemins dépendant du HOME
# ----------------------------------------------------------------------------
# shell.json contient un chemin absolu (JSON = pas d'expansion ~). On le fige
# sur le HOME courant. En mode symlink on édite une vraie copie pour ne pas
# modifier le dépôt.
SHELL_JSON="$HOME/.config/caelestia/shell.json"
if [ -L "$HOME/.config/caelestia" ]; then
  warn "caelestia/ est un symlink → copie de shell.json pour y figer le HOME"
  tmp="$(mktemp)"; sed "s#__HOME__#$HOME#g" "$SHELL_JSON" > "$tmp"
  # remplace le lien par un vrai dossier éditable
  realdir="$(readlink -f "$HOME/.config/caelestia")"
  rm "$HOME/.config/caelestia"; cp -a "$realdir" "$HOME/.config/caelestia"
  sed -i "s#__HOME__#$HOME#g" "$HOME/.config/caelestia/shell.json"; rm -f "$tmp"
else
  sed -i "s#__HOME__#$HOME#g" "$SHELL_JSON"
fi
ok "shell.json : wallpaperDir → $HOME/Pictures/wallpaper"

# ----------------------------------------------------------------------------
# 5. Dossiers et pywal
# ----------------------------------------------------------------------------
mkdir -p "$HOME/Pictures/wallpaper"
if [ ! -x "$HOME/.local/pywal_venv/bin/wal" ]; then
  say "Création du venv pywal (~/.local/pywal_venv)…"
  python3 -m venv "$HOME/.local/pywal_venv" && \
    "$HOME/.local/pywal_venv/bin/pip" -q install pywal && ok "pywal installé" || \
    warn "pywal non installé — crée le venv manuellement (voir README)"
fi

cat <<EOF

$(ok "Dotfiles posés.")

Sauvegarde de ton ancienne config : $BACKUP

ÉTAPES MANUELLES RESTANTES (pas dans les dépôts apt de Kali) :
  • Caelestia shell + CLI  → https://github.com/caelestia-dots/shell
  • Quickshell (requis par Caelestia)
  • (option) Hyprglass      → effet « verre » ; activé seulement si
                              ~/.config/caelestia/hyprglass.enable existe
  • Polices : Maple Mono NF, JetBrains Mono NF, Google Sans Flex
  • Thème icônes candy-icons, curseur sweet-cursors (sinon Adwaita par défaut)
  • starship (prompt)       → curl -sS https://starship.rs/install.sh | sh

Ajoute ensuite tes fonds d'écran dans ~/Pictures/wallpaper puis Super+Shift+W.
Détails complets dans le README.md.
EOF
