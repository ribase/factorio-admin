function calculate_task_item_multiplayer(number_of_tasks)
  return math.ceil(10 / number_of_tasks)
end

function setup_config()
  global.ticks_to_generate_entities = 20
  global.minimum_teams = 2
  global.players_per_team = 1
  global.points_per_win = 20
  global.recent_round_count = 5
  global.start_round_tick = 60 * 60 --first round starts in 60 seconds
  global.distance_between_areas = 6
  global.afk_time = 60*60*3.5 -- 3 and a half minutes
  global.inventory_probabilities =
  {
    {probability = 4, value = "small"},
    {probability = 12, value = "medium"},
    {probability = 8, value = "large"}
  }

  global.equipment_probabilities =
  {
    {probability = 6, value = "none"},
    {probability = 4, value = "small"}
  }

  global.challange_type_probabilities =
  {
    {probability = 14, value = "production"},
    {probability = 2, value = "research"},
    {probability = 14, value = "shopping_list"},
    {probability = 8, value = "input_output"},
  }

  global.max_count_of_production_tasks = 3

  -- With one tasks, the result amount is from 2*count up to 10*count
  -- With two tasks, the result amount is from 2*count up to 5*count
  -- With three tasks, the result amount is from 2*count up to 3*count
  global.item_list =
  {
    {name = "copper-cable", count = 1000},
    {name = "iron-stick", count = 1000},
    {name = "iron-plate", count = 400},
    {name = "copper-plate", count = 400},
    {name = "pipe", count = 300},
    {name = "transport-belt", count = 250},
    {name = "iron-gear-wheel", count = 200},
    {name = "electronic-circuit", count = 150},
    {name = "stone-furnace", count = 100},
    {name = "stone-brick", count = 200},
    {name = "medium-electric-pole", count = 100},
    {name = "red-wire", count = 200},
    {name = "green-wire", count = 200},
    {name = "boiler", count = 100},
    {name = "repair-pack", count = 250},
    {name = "firearm-magazine", count = 200},
    {name = "shotgun-shell", count = 200},
    {name = "burner-mining-drill", count = 100},
    {name = "concrete", count = 500},
    {name = "assembling-machine-1", count = 50},
    {name = "splitter", count = 50},
    {name = "iron-axe", count = 50},
    {name = "steel-plate", count = 50},
    {name = "rail", count = 100},
    {name = "fast-inserter", count = 150},
    {name = "long-handed-inserter", count = 150},
    {name = "empty-barrel", count = 150},
    {name = "rail-signal", count = 100},
    {name = "train-stop", count = 50},
    {name = "arithmetic-combinator", count = 50},
    {name = "steel-chest", count = 25},
    {name = "small-lamp", count = 150},
    {name = "lab", count = 50},
    {name = "train-stop", count = 50},
    {name = "fast-transport-belt", count = 100},
    {name = "landfill", count = 50},
    {name = "stone-wall", count = 100},
    {name = "gate", count = 50},
    {name = "radar", count = 50},
    {name = "light-armor", count = 50},
    {name = "heavy-armor", count = 10},
    {name = "piercing-rounds-magazine", count = 50},
    {name = "assembling-machine-2", count = 50},
    {name = "steel-axe", count = 25},
    {name = "defender-capsule", count = 50},
    {name = "electric-mining-drill", count = 50},
    {name = "steam-engine", count = 50},
    {name = "steel-furnace", count = 25},
    {name = "engine-unit", count = 25},
    {name = "big-electric-pole", count = 25},
    {name = "gun-turret", count = 25},
    {name = "solar-panel", count = 25},
    {name = "chemical-plant", count = 20},
    {name = "filter-inserter", count = 50},
    {name = "fast-splitter", count = 25},
    {name = "diesel-locomotive", count = 10},
    {name = "car", count = 10},
    {name = "fast-underground-belt", count = 25}
  }
  
  global.input_task_items = 
  {
    {name = "advanced-circuit", count = 400, input = "plastic-bar"},  
    {name = "copper-cable", count = 2000, input = "copper-plate"},
    {name = "engine-unit", count = 50, input = "steel-plate"},
    {name = "battery", count = 150, input = "sulfur"},
    {name = "explosives", count = 150, input = "sulfur"},
    {name = "alien-science-pack", count = 1500, input = "alien-artifact"},
    {name = "roboport", count = 5, input = "advanced-circuit"},
    {name = "landfill", count = 1500, input = "stone"},
    {name = "small-pump", count = 150, input = "electric-engine-unit"},
    {name = "accumulator", count = 400, input = "battery"},
    {name = "accumulator", count = 50, input = "sulfur"},
    {name = "electric-furnace", count = 25, input = "advanced-circuit"},
  }

  global.force_list =
  {
    {name = "Red", color = {0.9, 0.1, 0.1, 0.8}},
    {name = "Green", color = {0.1, 0.8, 0.1, 0.8}},
    {name = "Blue", color = {0.2, 0.2, 0.8, 0.7}},
    {name = "Orange", color = {0.8, 0.4, 0.0, 0.8}},
    {name = "Yellow", color = {0.8, 0.8, 0.0, 0.6}},
    {name = "Pink", color = {0.8, 0.2, 0.8, 0.2}},
    {name = "Purple", color = {0.8, 0.2, 0.8, 0.9}},
    {name = "White", color = {0.8, 0.8, 0.8, 0.5}},
    {name = "Black", color = {0.1, 0.1, 0.1, 0.8}},
    {name = "Gray", color = {0.6, 0.6, 0.6, 0.8}},
    {name = "Brown", color = {0.5, 0.3, 0.1, 0.8}},
    {name = "Cyan", color = {0.1, 0.9, 0.9, 0.8}}
  }

  global.starting_inventories =
  {
    ["small"] =
    {
      {name = "iron-plate", count = 20},
      {name = "copper-plate", count = 10},
      {name = "steel-axe", count=2},
      {name = "transport-belt", count=100},
      {name = "inserter", count=20},
      {name = "small-electric-pole", count=40},
      {name = "burner-mining-drill", count=16},
      {name = "stone-furnace", count=12},
      {name = "burner-inserter", count=30},
      {name = "assembling-machine-1", count=8},
      {name = "electric-mining-drill", count=2},
    },
    ["medium"] =
    {
      {name = "iron-plate", count = 50},
      {name = "iron-gear-wheel", count = 50},
      {name = "copper-plate", count = 50},
      {name = "electronic-circuit", count = 50},
      {name = "transport-belt", count = 150},
      {name = "inserter", count = 60},
      {name = "small-electric-pole", count=40},
      {name = "fast-inserter", count = 20},
      {name = "burner-inserter", count=50},
      {name = "burner-mining-drill", count=20},
      {name = "electric-mining-drill", count=8},
      {name = "stone-furnace", count=20},
      {name = "steel-furnace", count=8},
      {name = "speed-module-2", count = 8},
      {name = "assembling-machine-1", count=20},
      {name = "assembling-machine-2", count=8},
      {name = "steel-axe", count=2},
    },
    ["large"] =
    {
      {name = "iron-plate", count = 50},
      {name = "copper-plate", count = 50},
      {name = "iron-gear-wheel", count = 50},
      {name = "transport-belt", count = 250},
      {name = "inserter", count = 50},
      {name = "burner-inserter", count=50},
      {name = "small-electric-pole", count=50},
      {name = "burner-mining-drill", count=50},
      {name = "electric-mining-drill", count=20},
      {name = "stone-furnace", count=35},
      {name = "steel-furnace", count=20},
      {name = "electric-furnace", count=8},
      {name = "steel-axe", count=3},
      {name = "assembling-machine-1", count = 50},
      {name = "assembling-machine-2", count = 20},
      {name = "assembling-machine-3", count = 8},
      {name = "speed-module-3", count = 8},
      {name = "speed-module-2", count = 20},
      {name = "electronic-circuit", count = 50},
      {name = "fast-inserter", count = 30},
      {name = "medium-electric-pole", count = 30},
      {name = "substation", count = 8},
    }
  }

  global.disabled_items =
  {
    "submachine-gun",
    "pistol",
    "shotgun",
    "combat-shotgun",
    "rocket-launcher",
    "grenade",
    "land-mine",
    "poison-capsule",
    "slowdown-capsule",
    "flame-thrower",
    "distractor-capsule",
    "destroyer-capsule",
    "rocket",
    "flame-thrower-ammo",
    "laser-turret",
    "night-vision-equipment",
    "solar-panel-equipment",
    "energy-shield-equipment",
    "battery-equipment"
  }
end
