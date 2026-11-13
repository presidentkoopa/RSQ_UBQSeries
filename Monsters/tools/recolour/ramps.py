#!/usr/bin/env python3
"""Each colour's own small palette per part, for paint.py: the art direction of the recolour (2026-11-13).

stops: (place on the source's shading from its darkest 0 to its brightest 1, colour). Five per part: the deepest
shadow, shadow, base, light, highlight. The hues are chosen to shift the way sprite artists shift them (shadows lean
cool or toward a deeper neighbour hue, highlights lean warm or toward a paler one), never one hue over everything.
horn: spikes, claws and teeth; its palette is picked to contrast the skin (e.g. Yellow's red spikes, Black's silver).
claw: optional, used only where a mask marks claws; falls back to horn.
contrast: >1 steepens the mid tones (Black and White would otherwise go flat).
sat_detail / hue_detail: how much of the source's own painted saturation and hue variation is carried over.
The themes follow the colours' kits (design/BD_XMVE_TIERING.md section 4): Green acid, Blue plasma, Purple volley,
Cyan ice, Brown support, Yellow fire, FireBlu twin fire, Gray stone, Red rage, Abyss phase, Black and White bosses.
The neutral colour is the monster as shipped and is never baked."""

LOOKS = {
    'green': {     # acid: blue-green shadows, toxic green body, yellow-green highlights; old yellowed bone spikes
        'skin': {'stops': [(0, '#06140f'), (.22, '#173d27'), (.5, '#3a7f2c'), (.78, '#86c03a'), (1, '#e4f27c')], 'contrast': 1.1},
        'horn': {'stops': [(0, '#1a1208'), (.3, '#4c3c1a'), (.6, '#a08c40'), (.85, '#dcd28a'), (1, '#fdf8d4')]},
    },
    'blue': {      # plasma: indigo shadows, royal blue, periwinkle highlights; cold steel spikes
        'skin': {'stops': [(0, '#05061c'), (.22, '#141f62'), (.5, '#2747b4'), (.78, '#5c88e6'), (1, '#c4d8ff')], 'contrast': 1.1},
        'horn': {'stops': [(0, '#0e1018'), (.3, '#383f4e'), (.6, '#7c8698'), (.85, '#c4ccda'), (1, '#ffffff')]},
    },
    'purple': {    # volley: plum shadows, violet body, orchid-pink highlights; gold horns
        'skin': {'stops': [(0, '#12041a'), (.22, '#3a0d4c'), (.5, '#7a288c'), (.78, '#b85cc0'), (1, '#f4bdea')], 'contrast': 1.1},
        'horn': {'stops': [(0, '#1c0e04'), (.3, '#5a380a'), (.6, '#b07a18'), (.85, '#eac44c'), (1, '#fff3b4')]},
    },
    'cyan': {      # ice: deep sea-blue shadows, teal body, pale aqua highlights; frosted white spikes
        'skin': {'stops': [(0, '#03141e'), (.22, '#0b4658'), (.5, '#178e98'), (.78, '#4ed2c8'), (1, '#d6fff6')], 'contrast': 1.1},
        'horn': {'stops': [(0, '#162036'), (.3, '#486488'), (.6, '#90b2d2'), (.85, '#d2e8f8'), (1, '#ffffff')]},
    },
    'brown': {     # support: darker, redder chocolate than the shipped imp, warm tan highlights; ivory horns
        'skin': {'stops': [(0, '#100503'), (.22, '#3a170c'), (.5, '#6c351b'), (.78, '#a86c3c'), (1, '#ecc48c')], 'contrast': 1.1},
        'horn': {'stops': [(0, '#2a1c10'), (.3, '#6a5034'), (.6, '#b29c76'), (.85, '#e4d8b6'), (1, '#fffaf0')]},
    },
    'yellow': {    # fire: burnt orange-red shadows, golden body, cream highlights; blood-red spikes
        'skin': {'stops': [(0, '#260902'), (.22, '#782608'), (.5, '#cf761c'), (.78, '#f2c23e'), (1, '#fff6b4')], 'contrast': 1.05},
        'horn': {'stops': [(0, '#1e0404'), (.3, '#680c0c'), (.6, '#bf221a'), (.85, '#ef6c3c'), (1, '#ffd2a4')]},
    },
    'fireblu': {   # twin fire: a burning top (flame red-orange, yellow-white highlights) that cools down the body into a
                   # blue-flame lower half; the blend runs down the sprite's own height through magenta, smooth, never
                   # by palette row (the old recipe alternated red and blue rows: speckle). Flame spikes and claws.
        'skin': {'stops': [(0, '#03051c'), (.22, '#0a1c68'), (.5, '#1858d8'), (.78, '#48b2ff'), (1, '#e2fbff')], 'contrast': 1.1,
                 'stops2': [(0, '#1e0402'), (.22, '#701006'), (.5, '#d8400c'), (.78, '#ffa030'), (1, '#fff2b0')],
                 'split': (0.45, 0.13)},
        'horn': {'stops': [(0, '#2a0400'), (.3, '#8c1a02'), (.6, '#e4580a'), (.85, '#ffb22c'), (1, '#fff5b4')]},
    },
    'gray': {      # stone: cool slate shadows, warm pale stone highlights; dark basalt horns
        'skin': {'stops': [(0, '#0c0d11'), (.22, '#323540'), (.5, '#6a6862'), (.78, '#a8a496'), (1, '#e8e4d4')], 'contrast': 1.0, 'hue_detail': 0.2},
        'horn': {'stops': [(0, '#050505'), (.3, '#1c1a1a'), (.6, '#3e3a38'), (.85, '#6e6862'), (1, '#b2aa9e')]},
    },
    'red': {       # rage: wine-purple shadows, crimson body, hot orange-pink highlights; black-to-bone horns
        'skin': {'stops': [(0, '#140208'), (.22, '#4a0618'), (.5, '#a1141a'), (.78, '#e24c2c'), (1, '#ffb68c')], 'contrast': 1.05},
        'horn': {'stops': [(0, '#0a0808'), (.3, '#2e2626'), (.6, '#6a5e5a'), (.85, '#baaea6'), (1, '#f8f2ea')]},
    },
    'abyss': {     # phase: near-black violet, deep indigo body, cold lavender highlights; spectral teal spikes
        'skin': {'stops': [(0, '#040208'), (.22, '#140a2e'), (.5, '#33186c'), (.78, '#6542b2'), (1, '#b69cff')], 'contrast': 1.1},
        'horn': {'stops': [(0, '#04161a'), (.3, '#0c4a50'), (.6, '#1e9c9a'), (.85, '#6ae8d8'), (1, '#e8fff8')]},
    },
    'black': {     # boss: black body that keeps its muscles (cool violet sheen on the lights); bright silver spikes
        'skin': {'stops': [(0, '#020203'), (.22, '#100f16'), (.5, '#2d2b39'), (.78, '#5a5872'), (1, '#aca8c8')], 'contrast': 1.15},
        'horn': {'stops': [(0, '#2e2e36'), (.3, '#6e7280'), (.6, '#b0b4c0'), (.85, '#e4e6ee'), (1, '#ffffff')]},
    },
    'white': {     # boss: blue-gray shadows, bone-white body, warm cream highlights; dark charcoal horns
        'skin': {'stops': [(0, '#262a36'), (.22, '#6a7086'), (.5, '#b0b4c2'), (.78, '#e2e2e6'), (1, '#fffcf2')], 'contrast': 1.15},
        'horn': {'stops': [(0, '#0a0808'), (.3, '#282222'), (.6, '#4e4642'), (.85, '#847a72'), (1, '#c6baac')]},
    },
}
