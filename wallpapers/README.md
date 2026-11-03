# Fonds d'écran

Les fonds d'écran **ne sont pas inclus** dans ce dépôt :

- la collection d'origine fait ~1,2 Go (264 images) ;
- ce sont majoritairement des œuvres tierces (Pixiv, Wallhaven) qu'on ne peut pas redistribuer.

## Mettre les tiens

Dépose tes images (`.jpg`, `.jpeg`, `.png`) dans :

```
~/Pictures/wallpaper/
```

C'est le dossier scruté par Caelestia (`shell.json` → `paths.wallpaperDir`) et par
`~/autowall.sh`.

## Rotation automatique (pywal + Caelestia)

`~/autowall.sh` choisit une image au hasard, génère une palette Material You via
Caelestia (barre, bordures, GTK/Qt, btop, terminaux) et une palette pywal pour kitty.

- Au login : lancé automatiquement (voir `config/caelestia/hypr-user.lua`).
- À la demande : **Super + Shift + W**.

## Sources recommandées

- https://wallhaven.cc  (filtre « anime » / « digital art », résolution ≥ 2560×1440)
- https://www.pixiv.net  (illustrations — respecte les licences des auteurs)
