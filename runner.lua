-- =====================================================
-- Configuration des chemins
-- =====================================================

-- ===== Fonctions utilitaires =====
local function join(...)
  return table.concat({...}, "/")
end

-- ===== JSON support (dkjson) =====
local ok, json = pcall(require, "lib.dkjson-master.dkjson")
if not ok then
  error("Impossible de charger dkjson : " .. tostring(json))
end


-- =====================================================
-- Fonctions génériques de chargement de fichiers
-- =====================================================

local function loadJSON(path)
  local file = io.open(path, "r")
  if not file then error("Fichier introuvable : " .. path) end
  local content = file:read("*a")
  file:close()
  return json.decode(content)
end

local function loadCSV(path)
  local file = io.open(path, "r")
  if not file then error("Fichier introuvable : " .. path) end
  local data = {}
  for line in file:lines() do
    local row = {}
    for value in string.gmatch(line, '([^,]+)') do
      table.insert(row, value)
    end
    table.insert(data, row)
  end
  file:close()
  return data
end

local root = "H:/Downloads/Run&Bun/NG+ Encounter Generator/"

local dataDir   = join(root,"data")

-- ============================================================================
-- 1. PRÉPARATION DES DICTIONNAIRES ET FONCTIONS DE CONVERSION
-- ============================================================================

-- Fonction pour nettoyer les chaînes et pouvoir comparer (ex: "Sludge Bomb" -> "sludgebomb")
local function normalize(str)
    if not str then return "" end
    local s = str:lower()
    -- Supprime les espaces, tirets, apostrophes et caractères spéciaux
    s = s:gsub("’", ""):gsub("'", ""):gsub("%s+", ""):gsub("-", ""):gsub(":", "")
    return s
end

-- Dictionnaire pour les Moves : clé = "sludgebomb", valeur = "Sludge Bomb"
local move_lookup = {}
if move then -- Vérification de sécurité si la table globale existe
    for _, name in ipairs(move) do
        if name ~= "" and name ~= "None" then
            move_lookup[normalize(name)] = name
        end
    end
end

-- Dictionnaire pour les Pokémons : clé = "bulbasaur", valeur = "Bulbasaur"
local mons_lookup = {}
if mons then -- Vérification de sécurité si la table globale existe
    for _, name in ipairs(mons) do
        mons_lookup[normalize(name)] = name
    end
end

-- Fonction de conversion du fichier JS (déplacée ici pour être appelée plus bas)
local function convertJsToDatabase(filepath)
    local file = io.open(filepath, "r")
    if not file then 
        console:log("Impossible d'ouvrir le fichier : " .. filepath)
        return nil 
    end

    local database = {}
    local current_mon = nil
    local in_learnset = false

    for line in file:lines() do
        -- Détection du Pokémon (ex: bulbasaur: {)
        local mon_match = line:match("^%s*([%w%-]+)%s*:%s*{")
        if mon_match and not line:find("learnset") then
            local norm_mon = normalize(mon_match)
            -- On cherche le nom propre (ex: "Bulbasaur") à partir de la clé (ex: "bulbasaur")
            current_mon = mons_lookup[norm_mon] or mon_match
            in_learnset = false
        end

        -- Entrée dans le bloc learnset de ce Pokémon
        if current_mon and line:find("learnset%s*:%s*{") then
            in_learnset = true
            database[current_mon] = {}
        end

        -- Extraction des capacités (ex: sludgebomb: ["9L32", "9M"],)
        if current_mon and in_learnset then
            local move_key, move_data = line:match("^%s*([%w]+)%s*:%s*%[(.*)%]")
            
            if move_key and move_data then
                local norm_move = normalize(move_key)
                -- TRADUCTION : "sludgebomb" devient "Sludge Bomb" si présent dans la table de référence
                local correct_move_name = move_lookup[norm_move]

                if correct_move_name then
                    -- On parcourt le tableau des codes d'apprentissage (ex: "9L32", "9M")
                    for method in move_data:gmatch('"(.-)"') do
                        -- On ne garde QUE les "9L" (Niveau requis)
                        if method:sub(1, 2) == "9L" then
                            local level = tonumber(method:sub(3))
                            if level then
                                -- Stockage final avec l'orthographe exacte
                                database[current_mon][correct_move_name] = level
                            end
                        end
                    end
                end
            end
        end

        -- Détection de la fin du bloc d'un Pokémon
        if line:find("^%s*},") or line:find("^%s*}") then
            if in_learnset then
                in_learnset = false
            else
                current_mon = nil
            end
        end
    end

    file:close()
    return database
end


-- =====================================================
-- Chargement des fichiers principaux
-- =====================================================

console:log("Chargement des fichiers JSON...")

local dupesFamily        = loadJSON(join(dataDir, "dupes_family.json"))
local dupesRegional      = loadJSON(join(dataDir, "dupes_regionnal_variant.json"))
local staticUsers        = loadJSON(join(dataDir, "static.json"))
local magnetPullUsers    = loadJSON(join(dataDir, "magnet_pull.json"))
local zonesData          = loadJSON(join(dataDir, "zones.json"))
local typesData          = loadJSON(join(dataDir, "types.json"))

-- 🌟 NOUVEAU : Chargement de la liste des Pokémon déjà capturés par le joueur
local playerDupes        = loadJSON(join(dataDir, "dupes.json"))

-- Maintenant, la fonction est connue, on peut l'appeler sans crash
local learnsetData       = convertJsToDatabase(join(dataDir, "learnsets.js"))

console:log("Tous les fichiers JSON et JS ont été chargés avec succès.")


-- =====================================================
-- Initialisation du randomizer
-- =====================================================

-- Charger les paramètres utilisateur
local selectedDupesMode  = "dupe both"

console:log("Paramètres de session :")
console:log("   Mode dupes :", console:log(selectedDupesMode))

-- =====================================================
-- Exposer les données globales au randomizer
-- =====================================================

GLOBAL_SETTINGS = {
  dupes_mode   = selectedDupesMode,
}

GLOBAL_DATA = {
  dupes_family        = dupesFamily,
  dupes_regional      = dupesRegional,
  static_users        = staticUsers,
  magnet_pull_users   = magnetPullUsers,
  zones               = zonesData,
  types               = typesData,
  learnset            = learnsetData,
  player_dupes        = playerDupes
}

console:log("Initialisation complète du runner terminée.")


return {
  settings = GLOBAL_SETTINGS,
  data = GLOBAL_DATA
}