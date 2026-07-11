# sb_admin – første testversion

Denne version indeholder kun fundamentet:

- Custom NUI-design
- `/admin`
- F10 key mapping
- ESX-gruppekontrol
- Navigation via piletaster
- Enter til valg
- Backspace/Escape til lukning
- Spilleren kan fortsat bevæge sig, løbe og kigge rundt
- ox_lib-notifikation ved manglende adgang

Der er endnu ingen adminfunktioner i menuen.

## Installation

1. Læg mappen `sb_admin` i din resources-mappe.
2. Sørg for at `es_extended` og `ox_lib` starter før `sb_admin`.
3. Tilføj dette i `server.cfg`:

```cfg
ensure sb_admin
```

4. Kontrollér tilladte grupper i `config.lua`.
5. Genstart serveren eller kør:

```text
refresh
ensure sb_admin
```

## Test

1. Log ind med en bruger, der har ESX-gruppen `admin` eller `superadmin`.
2. Skriv `/admin` eller tryk F10.
3. Kontrollér, at menuen åbner.
4. Kontrollér, at WASD, Shift og mus stadig virker.
5. Tryk Backspace eller Escape for at lukke.
6. Test med en almindelig bruger og kontrollér, at adgangen afvises.


## Rettelse i denne version

- Fikset sort fuldskærmsbaggrund fra NUI.
- NUI-laget er nu altid gennemsigtigt, når menuen er lukket.
