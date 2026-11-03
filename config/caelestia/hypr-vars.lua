-- Overrides Kali/Debian des variables Caelestia (voir ~/.config/hypr/variables.lua)
return {
    terminal      = "foot",
    browser       = "firefox",
    editor        = "mousepad",
    fileExplorer  = "thunar",
    audioSettings = "pavucontrol",
    cursorTheme   = "Adwaita",

    -- Hyprglass gère la transparence : fenêtres opaques (texte net),
    -- c'est le fond des applis (foot alpha) qui laisse passer le verre
    windowOpacity  = 1.0,
    windowRounding = 20,
    windowGapsIn   = 8,
    windowGapsOut  = 15,

    -- Scroll trackpad un peu plus rapide (défaut Caelestia : 0.3)
    touchpadScrollFactor = 0.6,
}
