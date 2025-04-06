Config = {} -- Don't touch this line

-- Weapon configurations
Config.GiveLEOWeapons = true -- If you want to give weapons to the players who go on duty as LEO
Config.LEOWeapons = {
    "WEAPON_COMBATPISTOL",
    "WEAPON_STUNGUN",
    "WEAPON_NIGHTSTICK",
    "WEAPON_FLASHLIGHT",
    "WEAPON_CARBINERIFLE",
    "WEAPON_FIREEXTINGUISHER",
    "WEAPON_PUMPSHOTGUN"
}

Config.GiveFIREWeapons = true -- If you want to give weapons to the players who go on duty as FIRE
Config.FIREWeapons = {
    "WEAPON_FIREEXTINGUISHER",
}

-- Blip configurations
Config.Showblips = true -- If you want to show blips for people with the same job
Config.ShowBlipsOnlyInVehicles = true -- If true, blips will only be visible when players are in vehicles
Config.AllowBlipsToggle = true -- If true, players can toggle blips visibility with /blips command

Config.Departments = {
    LEO = {
        -- Format: {Department, Color, Name}
        -- https://docs.fivem.net/docs/game-references/blips/
        {code = "BSO", color = 3, name = "Broward Sheriff's Office"},
        {code = "FHP", color = 2, name = "Florida Highway Patrol"},
        {code = "FWC", color = 5, name = "Fish & Wildlife Conservation"},
        {code = "MPD", color = 38, name = "Miami Police Department"},
        {code = "USMS", color = 40, name = "US Marshals Service"}
    },
    
    FIRE = {
        {code = "BCFR", color = 1, name = "Broward County Fire Rescue"}
    }
}

-- Default blip colors if department not found
Config.DefaultBlipColors = {
    LEO = 3,
    FIRE = 1
}

-- Webhook configuration
Config.SendWebhook = false -- If you want to send a webhook when someone goes on/off duty
Config.WebhookURL = "WEBHOOK URL HERE" -- Webhook URL
