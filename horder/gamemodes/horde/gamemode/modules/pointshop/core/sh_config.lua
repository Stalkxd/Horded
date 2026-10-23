--[[-------------------------------------------------------------------------
    HORDE POINTSHOP - CONFIG

    Everything a server owner normally wants to change lives in this file.
    Prices, class restrictions and enabled/disabled state can ALSO be changed
    in-game from the ADMIN tab of the pointshop (F4 or !ps). In-game changes
    are stored in the server database and override the values below.

    ITEM FORMAT
        {
            id      = "unique_id",                       -- unique, never change it once players own the item
            name    = "Display Name",
            model   = "models/player/xxx.mdl",           -- playermodel path
            price   = 1000,                              -- price in skulls
            rarity  = "common",                          -- key from PS.Config.Rarities
            classes = { "Assault", "Medic" },            -- optional: only these classes can wear it
                                                         -- leave it out (nil) to allow every class
        }

    Class names: Survivor, Assault, Heavy, Medic, Demolition, Ghost,
                 Engineer, Berserker, Warden, Cremator
---------------------------------------------------------------------------]]

local PS = HORDE.Pointshop
PS.Config = PS.Config or {}
local C = PS.Config

-- Name of the pointshop currency (test currency, separate from Horde skull tokens).
C.CurrencyName      = "Skulls"
C.CurrencyNameRU    = "Черепа"
C.CurrencyIcon      = "skull.png"

-- Default menu language: "auto" (follows the game's language), "en" or "ru".
-- Every player can change it in the SETTINGS tab.
C.DefaultLanguage   = "auto"

-- Skulls every new player starts with.
C.StartingSkulls    = 1000

-- Inventory size (playermodel slots) and how many slots are shown per page.
C.InventorySlots    = 64
C.SlotsPerPage      = 32

-- Daily store: how many random skins are featured each day and their discount range (percent).
C.DailyCount        = 3
C.DailyDiscountMin  = 20
C.DailyDiscountMax  = 50
C.DailyDiscountStep = 5

-- Hour offset (relative to UTC) at which the daily store and daily contracts reset.
-- 0 = midnight UTC, 3 = midnight UTC+3 (Moscow), -5 = midnight UTC-5 (New York), ...
C.ResetUTCOffset    = 0

-- Daily contracts (both can also be changed in ADMIN > CONTRACTS).
C.ContractsPerDay   = 3
C.ContractReward    = 100
-- Count contract progress while sandbox mode (horde_enable_sandbox 1) is on?
C.ContractsInSandbox = false

-- Open the pointshop with F4 (gm_showspare2) in addition to !ps / !pointshop / horde_pointshop.
-- Players can also bind their own key in the SETTINGS tab.
C.OpenWithF4        = true
C.ChatCommands      = { "!ps", "!pointshop", "!store", "/ps", "/pointshop" }

-- Who can use the ADMIN tab (prices, class restrictions, models, bank, contracts).
C.IsAdmin = function(ply)
    return IsValid(ply) and ply:IsAdmin()
end

-- Item rarities (TF2-like quality colours, kept in the black / white / red palette).
C.Rarities = {
    common    = { name = "Common",    name_ru = "Обычный",     order = 1, color = Color(185, 185, 185) },
    uncommon  = { name = "Uncommon",  name_ru = "Необычный",   order = 2, color = Color(245, 245, 245) },
    rare      = { name = "Rare",      name_ru = "Редкий",      order = 3, color = Color(225, 75, 75)   },
    legendary = { name = "Legendary", name_ru = "Легендарный", order = 4, color = Color(255, 25, 25)   },
}
C.DefaultRarity = "common"

-- Daily contract templates. One is picked at random per contract slot every day.
-- They can also be edited, disabled or added in-game: ADMIN > CONTRACTS.
--   event   : "kill"  (enemy killed by the player)
--             "win"   (game finished with VICTORY while the player is on the server)
--             "wave"  (wave completed while the player is alive)
--   min/max : goal range, step rounds the random goal
--   enemy   : (kill) enemy names to count, case-insensitive. nil = any enemy
--   elite   : (kill) only elite enemies
--   boss    : (kill) only bosses
--   per_class: (kill) a random class is chosen; kills only count while playing it
--   reward  : optional override for C.ContractReward
--   desc / desc_ru : %d = goal, %s = class name (per_class only)
C.Contracts = {
    { id = "win_game",      name = "Last Stand",    name_ru = "Последний рубеж",  desc = "Complete a game (win the final wave).", desc_ru = "Пройдите игру (победите в последней волне).", event = "win",  min = 1, max = 1 },
    { id = "kill_hulks",    name = "Hulk Smasher",  name_ru = "Крушитель Халков", desc = "Destroy %d Hulks.",          desc_ru = "Уничтожьте Халков: %d.",          event = "kill", enemy = { "Hulk", "Mutated Hulk" }, min = 3, max = 3 },
    { id = "kill_enemies",  name = "Exterminator",  name_ru = "Истребитель",      desc = "Kill %d enemies.",           desc_ru = "Убейте врагов: %d.",              event = "kill", min = 150, max = 300, step = 25 },
    { id = "kill_elites",   name = "Elite Hunter",  name_ru = "Охотник на элиту", desc = "Kill %d elite enemies.",     desc_ru = "Убейте элитных врагов: %d.",      event = "kill", elite = true, min = 10, max = 25, step = 5 },
    { id = "kill_bosses",   name = "Giant Slayer",  name_ru = "Убийца гигантов",  desc = "Defeat %d boss.",            desc_ru = "Победите боссов: %d.",            event = "kill", boss = true,  min = 1,  max = 1 },
    { id = "survive_waves", name = "Endurance",     name_ru = "Выносливость",     desc = "Survive %d waves.",          desc_ru = "Переживите волн: %d.",            event = "wave", min = 5, max = 10 },
    { id = "class_kills",   name = "Specialist",    name_ru = "Специалист",       desc = "Kill %d enemies as %s.",     desc_ru = "Убейте врагов: %d, играя за класс %s.", event = "kill", per_class = true, min = 75, max = 150, step = 25 },
    { id = "kill_exploder", name = "Bomb Squad",    name_ru = "Сапёры",           desc = "Kill %d Exploders.",         desc_ru = "Убейте Взрывунов: %d.",           event = "kill", enemy = { "Exploder" },  min = 15, max = 30, step = 5 },
    { id = "kill_screech",  name = "Silence",       name_ru = "Тишина",           desc = "Kill %d Screechers.",        desc_ru = "Убейте Крикунов: %d.",            event = "kill", enemy = { "Screecher" }, min = 5,  max = 10 },
    { id = "kill_blight",   name = "Plague Doctor", name_ru = "Чумной доктор",    desc = "Kill %d Blights.",           desc_ru = "Убейте Блайтов: %d.",             event = "kill", enemy = { "Blight" },    min = 5,  max = 10 },
}

-- Playermodels available in the pointshop. Stock Garry's Mod models are used so it works
-- out of the box; add workshop models the same way (make sure clients download them).
C.Items = {
    -- Citizens / Rebels (any class)
    { id = "citizen_male_01",   name = "Citizen Van",        model = "models/player/group01/male_01.mdl",   price = 400,  rarity = "common" },
    { id = "citizen_male_02",   name = "Citizen Ted",        model = "models/player/group01/male_02.mdl",   price = 400,  rarity = "common" },
    { id = "citizen_male_03",   name = "Citizen Joe",        model = "models/player/group01/male_03.mdl",   price = 400,  rarity = "common" },
    { id = "citizen_male_04",   name = "Citizen Eric",       model = "models/player/group01/male_04.mdl",   price = 400,  rarity = "common" },
    { id = "citizen_female_01", name = "Citizen Joey",       model = "models/player/group01/female_01.mdl", price = 400,  rarity = "common" },
    { id = "citizen_female_02", name = "Citizen Kanisha",    model = "models/player/group01/female_02.mdl", price = 400,  rarity = "common" },
    { id = "rebel_male_05",     name = "Rebel Art",          model = "models/player/group03/male_05.mdl",   price = 650,  rarity = "common" },
    { id = "rebel_male_06",     name = "Rebel Sandro",       model = "models/player/group03/male_06.mdl",   price = 650,  rarity = "common" },
    { id = "rebel_male_07",     name = "Rebel Mike",         model = "models/player/group03/male_07.mdl",   price = 650,  rarity = "common" },
    { id = "rebel_female_03",   name = "Rebel Kim",          model = "models/player/group03/female_03.mdl", price = 650,  rarity = "common" },
    { id = "rebel_female_04",   name = "Rebel Chau",         model = "models/player/group03/female_04.mdl", price = 650,  rarity = "common" },
    { id = "refugee_male_02",   name = "Refugee Ted",        model = "models/player/group02/male_02.mdl",   price = 500,  rarity = "common" },
    { id = "refugee_male_04",   name = "Refugee Eric",       model = "models/player/group02/male_04.mdl",   price = 500,  rarity = "common" },

    -- Medic only
    { id = "medic_male_01",     name = "Field Medic Van",    model = "models/player/group03m/male_01.mdl",   price = 900, rarity = "uncommon", classes = { "Medic" } },
    { id = "medic_male_08",     name = "Field Medic Vance",  model = "models/player/group03m/male_08.mdl",   price = 900, rarity = "uncommon", classes = { "Medic" } },
    { id = "medic_female_01",   name = "Field Medic Joey",   model = "models/player/group03m/female_01.mdl", price = 900, rarity = "uncommon", classes = { "Medic" } },
    { id = "medic_female_06",   name = "Field Medic Lakeetra", model = "models/player/group03m/female_06.mdl", price = 900, rarity = "uncommon", classes = { "Medic" } },
    { id = "kleiner",           name = "Dr. Kleiner",        model = "models/player/kleiner.mdl",   price = 2500, rarity = "rare", classes = { "Medic", "Engineer" } },
    { id = "mossman",           name = "Dr. Mossman",        model = "models/player/mossman.mdl",   price = 2500, rarity = "rare", classes = { "Medic" } },

    -- Assault / Heavy / Survivor
    { id = "police",            name = "Civil Protection",   model = "models/player/police.mdl",              price = 1200, rarity = "uncommon", classes = { "Assault", "Survivor" } },
    { id = "police_fem",        name = "Civil Protection (F)", model = "models/player/police_fem.mdl",        price = 1200, rarity = "uncommon", classes = { "Assault", "Survivor" } },
    { id = "combine_soldier",   name = "Overwatch Soldier",  model = "models/player/combine_soldier.mdl",     price = 1800, rarity = "rare", classes = { "Assault", "Heavy" } },
    { id = "combine_guard",     name = "Prison Guard",       model = "models/player/combine_soldier_prisonguard.mdl", price = 1800, rarity = "rare", classes = { "Assault", "Heavy" } },
    { id = "combine_elite",     name = "Overwatch Elite",    model = "models/player/combine_super_soldier.mdl", price = 4000, rarity = "legendary", classes = { "Heavy" } },
    { id = "soldier_stripped",  name = "Stripped Soldier",   model = "models/player/soldier_stripped.mdl",    price = 1500, rarity = "uncommon", classes = { "Heavy", "Berserker" } },
    { id = "barney",            name = "Barney Calhoun",     model = "models/player/barney.mdl",              price = 2200, rarity = "rare" },

    -- Counter-Strike style (Ghost / Demolition / Assault)
    { id = "css_swat",          name = "S.W.A.T.",           model = "models/player/swat.mdl",     price = 1400, rarity = "uncommon", classes = { "Assault", "Ghost" } },
    { id = "css_urban",         name = "Urban Operator",     model = "models/player/urban.mdl",    price = 1400, rarity = "uncommon", classes = { "Assault", "Ghost" } },
    { id = "css_gasmask",       name = "Gasmask Operator",   model = "models/player/gasmask.mdl",  price = 1600, rarity = "uncommon", classes = { "Demolition", "Cremator" } },
    { id = "css_riot",          name = "Riot Control",       model = "models/player/riot.mdl",     price = 1600, rarity = "uncommon", classes = { "Heavy", "Warden" } },
    { id = "css_arctic",        name = "Arctic Avenger",     model = "models/player/arctic.mdl",   price = 1300, rarity = "uncommon", classes = { "Ghost" } },
    { id = "css_leet",          name = "Elite Crew",         model = "models/player/leet.mdl",     price = 1300, rarity = "uncommon", classes = { "Demolition", "Berserker" } },
    { id = "css_phoenix",       name = "Phoenix Connexion",  model = "models/player/phoenix.mdl",  price = 1300, rarity = "uncommon", classes = { "Demolition", "Cremator" } },
    { id = "css_guerilla",      name = "Guerilla Warfare",   model = "models/player/guerilla.mdl", price = 1300, rarity = "uncommon", classes = { "Survivor", "Berserker" } },
    { id = "dod_american",      name = "GI",                 model = "models/player/dod_american.mdl", price = 1700, rarity = "rare", classes = { "Assault", "Engineer" } },
    { id = "dod_german",        name = "Wehrmacht",          model = "models/player/dod_german.mdl",   price = 1700, rarity = "rare", classes = { "Assault", "Engineer" } },

    -- Characters (any class)
    { id = "alyx",              name = "Alyx Vance",         model = "models/player/alyx.mdl",       price = 3000, rarity = "rare" },
    { id = "eli",               name = "Eli Vance",          model = "models/player/eli.mdl",        price = 2500, rarity = "rare", classes = { "Engineer", "Warden" } },
    { id = "odessa",            name = "Odessa Cubbage",     model = "models/player/odessa.mdl",     price = 2500, rarity = "rare" },
    { id = "monk",              name = "Father Grigori",     model = "models/player/monk.mdl",       price = 3500, rarity = "legendary", classes = { "Survivor", "Berserker" } },
    { id = "magnusson",         name = "Dr. Magnusson",      model = "models/player/magnusson.mdl",  price = 3000, rarity = "rare", classes = { "Engineer" } },
    { id = "breen",             name = "Dr. Breen",          model = "models/player/breen.mdl",      price = 3500, rarity = "legendary" },
    { id = "gman",              name = "G-Man",              model = "models/player/gman_high.mdl",  price = 5000, rarity = "legendary" },
    { id = "chell",             name = "Chell",              model = "models/player/p2_chell.mdl",   price = 3000, rarity = "rare", classes = { "Ghost", "Survivor" } },

    -- Undead (Cremator / Warden / Berserker flavour)
    { id = "zombie_classic",    name = "Shambler",           model = "models/player/zombie_classic.mdl", price = 2000, rarity = "rare", classes = { "Berserker" } },
    { id = "zombie_fast",       name = "Fast Zombie",        model = "models/player/zombie_fast.mdl",    price = 2000, rarity = "rare", classes = { "Berserker", "Ghost" } },
    { id = "zombie_soldier",    name = "Zombine",            model = "models/player/zombie_soldier.mdl", price = 2400, rarity = "rare", classes = { "Heavy", "Warden" } },
    { id = "charple",           name = "Charple",            model = "models/player/charple.mdl",        price = 2600, rarity = "rare", classes = { "Cremator" } },
    { id = "corpse",            name = "Corpse",             model = "models/player/corpse1.mdl",        price = 2200, rarity = "rare", classes = { "Warden", "Cremator" } },
    { id = "skeleton",          name = "Skeleton",           model = "models/player/skeleton.mdl",       price = 4500, rarity = "legendary" },
}
