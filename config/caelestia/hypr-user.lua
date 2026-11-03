-- Config perso : thème du post r/unixporn (Caelestia + Hyprglass)

-- Stabilité iGPU AMD (Renoir) : le curseur matériel bloquait le page-flip DRM
-- (log : "drm: Cannot commit when a page-flip is awaiting" -> écran figé)
hl.config({
    cursor = { no_hardware_cursors = true },
})

-- Clavier AZERTY (identique à /etc/default/keyboard)
hl.config({
    input = { kb_layout = "fr", kb_variant = "latin9" },
})

-- Thèmes Qt / GTK (qtengine n'existe pas sur Debian -> qt6ct + Kvantum KvArcDark)
hl.env("QT_QPA_PLATFORMTHEME", "qt6ct")
hl.env("QT_STYLE_OVERRIDE", "kvantum")
hl.on("hyprland.start", function()
    hl.exec_cmd("gsettings set org.gnome.desktop.interface gtk-theme 'Arc-Dark'")
    hl.exec_cmd("gsettings set org.gnome.desktop.interface icon-theme 'candy-icons'")
    hl.exec_cmd("gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'")
    hl.exec_cmd("gsettings set org.gnome.desktop.interface monospace-font-name 'Maple Mono NF 11'")
end)

-- Hyprglass (compilé en v0.8.0 pour Hyprland 0.56.2)
-- Opt-in : ne se charge que si ce fichier existe -> touch ~/.config/caelestia/hyprglass.enable
local hg_flag = io.open(os.getenv("HOME") .. "/.config/caelestia/hyprglass.enable")
if hg_flag then
    hg_flag:close()
    hl.plugin.load(os.getenv("HOME") .. "/.local/share/hyprglass/hyprglass.so")
end

if hl.plugin.hyprglass then
    local hg = hl.plugin.hyprglass

    -- Config de l'OP (u/Minty_Stellar), transposée du .conf vers Lua
    -- https://www.reddit.com/r/unixporn/comments/1wqi4ip/comment/pca8s0b/
    hg.config({
        default_theme  = "dark",
        default_preset = "glass",

        -- Tint & tone mapping
        tint_color = 0x080c1499,
        brightness = 0.75,
        dark       = { brightness = 0.75, adaptive_dim = 0.75 },
        light      = { adaptive_boost = 0.5 },

        -- Blur
        blur_strength   = 2,
        blur_iterations = 3,

        -- Refraction & chromatic aberration
        refraction_strength  = 1.0,
        chromatic_aberration = 1.0,
        edge_thickness       = 0.09,
        lens_distortion      = 1.0,
        fresnel_strength     = 0.75,
        specular_strength    = 0.9,

        layers = { enabled = true },
    })

    -- Presets de l'OP
    hg.preset("custom_heavy", {
        glass_opacity        = 0.92,
        blur_strength        = 3.5,
        refraction_strength  = 0.9,
        chromatic_aberration = 0.85,
        dark = { tint_color = 0x050811aa, brightness = 0.62, adaptive_dim = 0.8 },
    })
    hg.preset("clear", {
        glass_opacity = 0.8,
        blur_strength = 2.5,
        dark  = { brightness = 0.65 },
        light = { brightness = 1.2 },
    })
    hg.preset("contrasted", {
        inherits     = "high_contrast",
        contrast     = 1.2,
        adaptive_dim = 1.5,
        dark = { tint_color = 0x02142aa9 },
    })

    -- Layers : l'OP vise waybar/swaync/quickshell:bezel, qui n'existent pas chez
    -- Caelestia. Équivalent Caelestia : le layer "caelestia-drawers" (barre +
    -- panneaux), avec le preset des layers de l'OP ("glass").
    hg.layer("caelestia-drawers", { preset = "glass", mask_threshold = 0.2 })
    hg.layer("caelestia-background", { exclude = true })
    hg.layer("caelestia-border-exclusion", { exclude = true })
    hg.layer("caelestia-area-picker", { exclude = true })
    hg.layer("caelestia-screenshot", { exclude = true })
end

-- Pas de verre sur les vidéos
hl.window_rule({ match = { class = "mpv" },    tag = "+hyprglass_disabled" })

-- autowall : fond aléatoire (Caelestia + pywal pour kitty) au login et via Super+Shift+W
hl.on("hyprland.start", function()
    hl.exec_cmd("sleep 3 && ~/autowall.sh")
end)
hl.bind("SUPER + SHIFT + W", hl.dsp.exec_cmd("~/autowall.sh"))

-- Animations de l'OP (u/Minty_Stellar)
-- https://www.reddit.com/r/unixporn/comments/1wqi4ip/comment/pcb22yc/
hl.curve("easeOutQuint",   { type = "bezier", points = { { 0.23, 1 },    { 0.32, 1 } } })
hl.curve("easeInOutCubic", { type = "bezier", points = { { 0.65, 0.05 }, { 0.36, 1 } } })
hl.curve("linear",         { type = "bezier", points = { { 0, 0 },       { 1, 1 } } })
hl.curve("almostLinear",   { type = "bezier", points = { { 0.5, 0.5 },   { 0.75, 1 } } })
hl.curve("quick",          { type = "bezier", points = { { 0.15, 0 },    { 0.1, 1 } } })

hl.animation({ leaf = "global",        enabled = true, speed = 10,   bezier = "default" })
hl.animation({ leaf = "border",        enabled = true, speed = 5.39, bezier = "easeOutQuint" })
hl.animation({ leaf = "windows",       enabled = true, speed = 4.79, bezier = "easeOutQuint" })
hl.animation({ leaf = "windowsIn",     enabled = true, speed = 4.1,  bezier = "easeOutQuint", style = "popin 87%" })
hl.animation({ leaf = "windowsOut",    enabled = true, speed = 1.49, bezier = "linear",       style = "popin 87%" })
hl.animation({ leaf = "fadeIn",        enabled = true, speed = 1.73, bezier = "almostLinear" })
hl.animation({ leaf = "fadeOut",       enabled = true, speed = 1.46, bezier = "almostLinear" })
hl.animation({ leaf = "fade",          enabled = true, speed = 3.03, bezier = "quick" })
hl.animation({ leaf = "layers",        enabled = true, speed = 3.81, bezier = "easeOutQuint" })
hl.animation({ leaf = "layersIn",      enabled = true, speed = 4,    bezier = "easeOutQuint", style = "fade" })
hl.animation({ leaf = "layersOut",     enabled = true, speed = 1.5,  bezier = "linear",       style = "fade" })
hl.animation({ leaf = "fadeLayersIn",  enabled = true, speed = 1.79, bezier = "almostLinear" })
hl.animation({ leaf = "fadeLayersOut", enabled = true, speed = 1.39, bezier = "almostLinear" })
hl.animation({ leaf = "workspaces",    enabled = true, speed = 1.94, bezier = "almostLinear", style = "fade" })
hl.animation({ leaf = "workspacesIn",  enabled = true, speed = 1.21, bezier = "almostLinear", style = "fade" })
hl.animation({ leaf = "workspacesOut", enabled = true, speed = 1.94, bezier = "almostLinear", style = "fade" })
hl.animation({ leaf = "zoomFactor",    enabled = true, speed = 7,    bezier = "quick" })

-- Bureaux en AZERTY : "SUPER + 1" ne matche pas (la touche donne "&") et l'API Lua
-- ne gère pas "code:N", on binde donc les keysyms AZERTY + pavé numérique (Verr Num on/off)
do
    local ws = require("utils.functions").wsaction
    local keys = {
        { "ampersand",  "KP_1", "KP_End" },
        { "eacute",     "KP_2", "KP_Down" },
        { "quotedbl",   "KP_3", "KP_Next" },
        { "apostrophe", "KP_4", "KP_Left" },
        { "parenleft",  "KP_5", "KP_Begin" },
        { "minus",      "KP_6", "KP_Right" },
        { "egrave",     "KP_7", "KP_Home" },
        { "underscore", "KP_8", "KP_Up" },
        { "ccedilla",   "KP_9", "KP_Prior" },
        { "agrave",     "KP_0", "KP_Insert" },
    }
    -- Super + 6 (minus) réduisait la largeur de la fenêtre : il reste Super + Alt + Gauche
    pcall(function() hl.unbind("SUPER + Minus") end)
    for i, list in ipairs(keys) do
        for _, key in ipairs(list) do
            hl.bind("SUPER + " .. key, ws("focus", "", i))
            hl.bind("SUPER + ALT + " .. key, ws("move", "", i))
        end
    end
end
