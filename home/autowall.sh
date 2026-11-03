#!/bin/bash

# ==========================================================
# CONFIGURATION
# ==========================================================

# Chemin de l'exécutable Pywal dans votre environnement virtuel (venv)
WAL_EXEC="$HOME/.local/pywal_venv/bin/wal"

# Chemin vers votre dossier de fonds d'écran
WALLPAPER_DIR="$HOME/Pictures/wallpaper/"

# Session courante : Hyprland (Wayland + Caelestia) ou Xfce (X11)
if [ -n "$HYPRLAND_INSTANCE_SIGNATURE" ]; then
    SESSION="hyprland"
else
    SESSION="xfce"
    # Arrête xfdesktop seulement s'il tourne (évite le message "not running")
    pgrep -x xfdesktop >/dev/null && xfdesktop --quit >/dev/null 2>&1
fi

# ----------------------------------------------------------
# 1. Vérifications et Choix Aléatoire
# ----------------------------------------------------------

# Vérifie l'existence de Pywal (pour éviter les erreurs silencieuses)
if [ ! -f "$WAL_EXEC" ]; then
    echo "ERREUR: Pywal n'a pas été trouvé. Lancez 'source ~/.local/pywal_venv/bin/activate' puis 'pip install pywal'."
    exit 1
fi

# Choix aléatoire d'un fichier image (jpg, jpeg ou png), différent du fond actuel
CURRENT_WALLPAPER=$(cat "$HOME/.local/state/caelestia/wallpaper/path.txt" 2>/dev/null)
RANDOM_WALLPAPER=$(find "$WALLPAPER_DIR" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" \) \
    | grep -vxF "${CURRENT_WALLPAPER:-/dev/null}" | shuf -n 1)

if [ -z "$RANDOM_WALLPAPER" ]; then
    echo "ERREUR: Aucun fond d'écran trouvé dans $WALLPAPER_DIR."
    exit 1
fi

# ----------------------------------------------------------
# 2. Générer la Palette de Couleurs pour Kitty (Pywal)
# ----------------------------------------------------------

# Exécute Pywal : -q pour silencieux, -i pour l'image d'entrée
# -e : désactive le "reload" auto de pywal (xrdb/i3/kitty…). C'est lui qui
#      lançait "kitty @ set-colors" -> "Remote control is disabled".
#      Le rechargement de kitty est fait plus bas via SIGUSR1.
# -n : pywal ne pose pas le fond lui-même (fait à l'étape 3 selon la session).
# -s (Hyprland) : pywal n'envoie pas ses couleurs aux terminaux ouverts, sinon
#      Caelestia les écrase juste après (couleurs qui "reviennent en arrière").
WAL_OPTS="-q -e -n"
[ "$SESSION" = "hyprland" ] && WAL_OPTS="$WAL_OPTS -s"
if ! "$WAL_EXEC" $WAL_OPTS -i "$RANDOM_WALLPAPER"; then
    echo "ERREUR: Pywal a échoué (venv cassé ?). Recréez-le :"
    echo "  rm -rf ~/.local/pywal_venv && python3 -m venv ~/.local/pywal_venv && ~/.local/pywal_venv/bin/pip install pywal"
    notify-send "autowall" "Pywal a échoué — thème non mis à jour" 2>/dev/null
    exit 1
fi

# ----------------------------------------------------------
# 3. Appliquer le Fond d'écran
# ----------------------------------------------------------

if [ "$SESSION" = "hyprland" ]; then
    # Caelestia pose le fond et régénère tout le thème Material You à partir
    # de l'image : shell, bordures Hyprland, GTK/Qt, btop, terminaux ouverts.
    if ! caelestia wallpaper -f "$RANDOM_WALLPAPER" >/dev/null 2>&1; then
        notify-send "autowall" "Caelestia n'a pas pu appliquer $(basename "$RANDOM_WALLPAPER")" 2>/dev/null
        exit 1
    fi
else
    # Xfce/X11 : Xwallpaper
    xwallpaper --zoom "$RANDOM_WALLPAPER"
fi

# ----------------------------------------------------------
# 4. Rafraîchir les Applications
# ----------------------------------------------------------

# Envoie le signal de rafraîchissement à Kitty pour charger le nouveau fichier de couleurs
if pgrep -x kitty >/dev/null; then
    killall -SIGUSR1 kitty
fi
