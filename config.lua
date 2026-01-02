Config = {}

-- Database mapping: adjust to match your schema
Config.DB = {
    table            = 'user_characters',   -- your character table
    identifierColumn = 'charid',            -- we look up by current character id
    jobColumn        = 'active_department'  -- this is what gets updated
}
Config.UseAzFrameworkCharacter = true

-- Cooldown between job changes (seconds). Set to 0 to disable.
Config.JobChangeCooldown = 300 -- 5 minutes


-- Enable / disable world NPC access points for the Job Center
Config.EnableJobCenterNPCs = true

-- Show blips for Job Center NPCs on the map
Config.EnableJobCenterBlips = true

-- Default blip settings (can be overridden per-NPC)
Config.JobCenterBlip = {
    sprite = 407,   -- briefcase / business-style icon
    color  = 3,     -- light blue
    scale  = 0.9
}

-- NPC locations for Job Center (clipboard animation + E to open)
Config.JobCenterNPCs = {
    {
        enabled = true,
        label = "Job Center - Sandy Shores",
        model = "cs_bankman",
        coords = vec3(1853.15, 3689.45, 34.27),
        heading = 210.0,
        interactDistance = 2.0,
        icon = "briefcase",

        blipSprite = 407,
        blipColour = 3,
        blipScale  = 0.9,
        blipLabel  = "Job Center"
    },
    {
        enabled = true,
        label = "Job Center - Paleto Bay",
        model = "cs_bankman",
        coords = vec3(-276.12, 6230.72, 31.70), -- Paleto
        heading = 135.0,
        interactDistance = 2.0,
        icon = "briefcase"
    },
    {
        enabled = true,
        label = "Job Center - Los Santos",
        model = "cs_bankman",
        coords = vec3(-265.0, -963.6, 31.22), -- LS city area (near job center-ish)
        heading = 205.0,
        interactDistance = 2.0,
        icon = "briefcase"
    }
}



-- GTA-style job definitions
Config.Jobs = {
    {
        id = 'unemployed',
        label = 'Unemployed',
        category = 'Civilian',
        description = 'Take your time to explore Los Santos, pick up side gigs, and decide your future career.',
        icon = 'fa-user',
        color = '#b0bec5',
        salary = 0,
        duties = {
            'Free roam the city',
            'No fixed responsibilities',
            'Try out activities before committing'
        }
    },
    {
        id = 'police',
        label = 'Police Officer',
        category = 'Emergency Services',
        description = 'Protect and serve the people of Los Santos. Respond to calls, chase suspects, and keep the streets safe.',
        icon = 'fa-shield-halved',
        color = '#00b4ff',
        salary = 750,
        duties = {
            'Respond to 911 calls',
            'Conduct traffic stops and patrol',
            'Assist other emergency services'
        }
    },

        {
        id = 'gopostal',
        label = 'gopostal',
        category = 'GoPostal Services',
        description = 'Protect and serve the people of Los Santos. Respond to calls, chase suspects, and keep the streets safe.',
        icon = 'fa-shield-halved',
        color = '#84ff00ff',
        salary = 750,
        duties = {
            'Respond to 911 calls',
            'Conduct traffic stops and patrol',
            'Assist other emergency services'
        }
    },
    {
        id = 'ems',
        label = 'ems',
        category = 'Emergency Services',
        description = 'Race against time to save lives. Stabilize patients, transport to hospital, and support police & fire.',
        icon = 'fa-heart-pulse',
        color = '#ff5673',
        salary = 700,
        duties = {
            'Respond to medical emergencies',
            'Provide first aid and transport',
            'Support fire and police operations'
        }
    },
{
    id = 'fire',
    label = 'fire',
    category = 'Emergency Services',
    description = 'Answer the alarm and protect the city. Suppress structure & vehicle fires, perform rescue operations, and support EMS & police during major incidents.',
    icon = 'fa-fire-extinguisher',
    color = '#ff6a00',
    salary = 700,
    duties = {
        'Respond to fire and rescue callouts',
        'Suppress structure, vehicle, and wildland fires',
        'Conduct search & rescue and ventilation',
        'Provide scene safety and support EMS & police'
    }
},

    {
        id = 'mechanic',
        label = 'Mechanic',
        category = 'Services',
        description = 'Keep Los Santos in motion. Repair, upgrade, and customize vehicles for players.',
        icon = 'fa-wrench',
        color = '#ffb300',
        salary = 600,
        duties = {
            'Repair damaged vehicles',
            'Install performance & cosmetic upgrades',
            'Tow disabled vehicles when needed'
        }
    },
    {
        id = 'taxi',
        label = 'Taxi Driver',
        category = 'Transport',
        description = 'Pick up and drop off customers around the city. The meter is running – drive smart and fast.',
        icon = 'fa-taxi',
        color = '#f5c542',
        salary = 550,
        duties = {
            'Accept taxi calls from players',
            'Drive safely but efficiently',
            'Earn tips for good service'
        }
    },
    {
        id = 'trucker',
        label = 'Trucker',
        category = 'Logistics',
        description = 'Deliver cargo across San Andreas. Long hauls, tight deadlines, and solid pay.',
        icon = 'fa-truck',
        color = '#6dce5b',
        salary = 580,
        duties = {
            'Pick up loads from depots',
            'Deliver on time and undamaged',
            'Respect road safety and traffic'
        }
    },
    -- ✅ Replace your current GoPostal block with this:
{
    id = 'gopostal',
    label = 'GoPostal Courier',
    category = 'Logistics',
    description = 'Deliver mail across San Andreas. Hit mailbox stops, stay on route, and get paid per delivery.',
    icon = 'fa-envelopes-bulk',
    color = '#84ff00',
    salary = 520,
    duties = {
        'Start a delivery route',
        'Drop mail at marked mailboxes',
        'Get paid per successful stop'
    }
},

-- ✅ Add these NEW jobs:

{
    id = 'miner',
    label = 'Quarry Miner',
    category = 'Industry',
    description = 'Work the quarry and collect minerals. Store them in your minerals bag and sell for cash.',
    icon = 'fa-hammer',
    color = '#9aa4ad',
    salary = 560,
    duties = {
        'Mine at the quarry locations',
        'Collect minerals into your bag',
        'Sell minerals at the sell point'
    }
},

{
    id = 'farmer',
    label = 'Grapeseed Farmer',
    category = 'Agriculture',
    description = 'Harvest crops around Grapeseed, fill your produce bag, and sell your haul for profit.',
    icon = 'fa-seedling',
    color = '#6dce5b',
    salary = 540,
    duties = {
        'Harvest at field locations',
        'Collect produce into your bag',
        'Sell produce at the sell point'
    }
},

{
    id = 'hunter',
    label = 'Hunter',
    category = 'Outdoors',
    description = 'Hunt wildlife for rewards. Each kill gives a randomized size/weight payout with an animal image popup.',
    icon = 'fa-crosshairs',
    color = '#ff6a00',
    salary = 0,
    duties = {
        'Track and hunt wildlife',
        'Earn randomized rewards per kill',
        'Receive a reward popup with animal info'
    }
},

{
    id = 'moneytruck',
    label = 'Money Transport (Gruppe6)',
    category = 'Security',
    description = 'Transport cash bank-to-bank in an armored truck. Your truck is visible to everyone — expect attacks.',
    icon = 'fa-shield',
    color = '#ff3b3b',
    salary = 780,
    duties = {
        'Drive the armored truck to each bank stop',
        'Pickup / drop-off cash at locations',
        'Stay alert: other players can track you'
    }
}

}
