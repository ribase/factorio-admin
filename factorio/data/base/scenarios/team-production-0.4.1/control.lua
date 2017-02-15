require("map_sets")
require("map_scripts")
require("points")
require("config")

script.on_event(defines.events.on_tick, function(event)
  check_end_of_round()
  check_chests()
  check_input_chests()
  check_clear_areas()
  check_set_areas()
  check_start_setting_entities()
  check_start_set_areas()
  check_start_round()
  update_gui()
  try_to_check_victory()
end)

--So people don't place entities/ghosts outside their area
script.on_event(defines.events.on_built_entity, function(event)
  local entity = event.created_entity
  local position = entity.position
  local force = entity.force
  local origin = force.get_spawn_position(entity.surface)
  local max_distance = map_sets[global.current_map_index].map_set_tiles[0]
  if origin.x + max_distance < position.x or
     origin.x - max_distance > position.x or
     origin.y + max_distance < position.y or
     origin.y - max_distance > position.y then
    entity.destroy()
  end
end)

script.on_event(defines.events.on_gui_click, function(event)
  local player = game.players[event.player_index]
  local gui = event.element
  
  if gui.name == "spectate_button" then
    if player.force.name == "spectators" then
      player.force = game.forces.player
      player.print({"left-spectators"})
      gui.caption = {"", {"spectate"}, ""}
    else
      player.force = game.forces.spectators
      player.print({"joined-spectators"})
      gui.caption = {"", {"unspectate"}, ""}
    end
    update_begin_timer(player)
    return
  end
  
  if gui.name == "join-game" then
    table.insert(global.online_players, player)
    set_player(player, #global.online_players)
    give_starting_inventory(player)
    player.gui.center.center_splash.destroy()
    set_gui_flow_table(player)
    return
  end
  
  if gui.name == "remain-spectate" then
    player.force = game.forces.spectators
    player.gui.center.center_splash.destroy()
    set_gui_flow_table(player)
    return
  end
  
end)

script.on_event(defines.events.on_player_created, function(event)
  local player = game.players[event.player_index]
  set_gui_flow_table(player)
  set_spectator(player)
  update_end_timer(player)
  update_begin_timer(player)
end)

script.on_event(defines.events.on_player_joined_game, function(event)
  local player = game.players[event.player_index]
  
  if global.start_round_tick then
    set_spectator(player)
  else
    local player_on_team = false
    for k, check_player in pairs (global.online_players) do
      if player == check_player then
        player_on_team = true
        break
      end
    end

    if not player_on_team then
      player.force = game.forces.spectators
      set_spectator(player)
      create_joined_game_gui(player)
    end
  end
  set_gui_flow_table(player)
  update_end_timer(player)
  update_begin_timer(player)
  if global.end_round_tick then
    update_winners_list(player)
  end
end)

script.on_event(defines.events.on_player_left_game, function(event)
  local player = game.players[event.player_index]
  if player.gui.left.top_flow then
    player.gui.left.top_flow.destroy()
  end
end)


script.on_init(function ()
  setup_config()
  global.online_players = {}
  global.winners = {}
  global.points = {}
  global.recent_points = {}
  global.chests = {}
  global.input_chests = {}
  global.round_number = 0
  global.recent_round_number = 0
  generate_technology_list()
  create_teams()
  fill_leaderboard()
  game.surfaces[1].always_day = true
  game.disable_replay()
  game.map_settings.pollution.enabled = false
end)

function select_from_probability_table(probability_table)
  local roll_max = 0
  for _, item in pairs(probability_table) do
    roll_max = roll_max + item.probability
  end

  local roll_value = math.random(0, roll_max - 1)
  for _, item in pairs(probability_table) do
    roll_value = roll_value - item.probability
    if (roll_value < 0) then
      return item.value
    end
  end
end

function select_inventory() return select_from_probability_table(global.inventory_probabilities) end
function select_equipment() return select_from_probability_table(global.equipment_probabilities) end
function select_challange_type() return select_from_probability_table(global.challange_type_probabilities) end

function save_round_statistics()

  local round_data = "\nRound "..global.round_number.."\n  Time: "..format_time(game.tick - global.round_timer_value).."\n  Type: "..global.challenge_type.."\n  Inventory: "..global.round_inventory.."\n  Equipment: "..global.round_equipment.."\n  Players per team: "..global.players_per_team.."\n  Number of players: "..#global.online_players.."\n  Tasks:"

  if global.challenge_type ~= "research" then
    for k, item in pairs (global.task_items) do
      round_data = round_data.."\n    "..item.name..": "..item.count
    end
  else
    for k, technology in pairs (global.research_task) do
      round_data = round_data.."\n    "..technology
    end
  end
  
  if global.winners then
    round_data = round_data.."\n  Number of winning teams: "..#global.winners
    for k, force in pairs (global.winners) do
      round_data = round_data.."\n    "..force.name..": "
      for j, player in pairs (force.players) do
        if j == 1 then
          round_data = round_data..player.name
        else
          round_data = round_data..", "..player.name
        end
      end
    end
  end
  
  round_data = round_data.."\n"
  game.write_file("round_statistics.txt", round_data, true, 0)
  
end

function start_challenge()
  global.round_number = global.round_number + 1
  if global.recent_round_number == global.recent_round_count then
    global.recent_round_number = 0
    global.recent_points = {}
  end
  global.recent_round_number = global.recent_round_number + 1
  global.round_timer_value = game.tick
  global.winners = {}
  global.force_points = {}

  global.round_inventory = select_inventory()
  global.round_equipment = select_equipment()
  global.challenge_type = select_challange_type()
  
  set_teams()

  if global.challenge_type == "production" then
    generate_production_task()
    return
  end
  
  if global.challenge_type == "input_output" then
    generate_production_task()
    fill_input_chests()
    return
  end
  
  if global.challenge_type == "research" then
    generate_research_task()
    return
  end
  
  if global.challenge_type == "shopping_list" then
    generate_shopping_list_task()
    return
  end
  
end

function create_teams()
  for k, force in pairs(global.force_list) do
    if not game.forces[force.name] then
      game.create_force(force.name)
    end
  end
  for k, force in pairs (game.forces) do
    for j, friend in pairs (game.forces) do
      if force.name ~= friend.name then
        force.set_cease_fire(friend, true)
      end
    end
  end
  if not game.forces["spectators"] then
    game.create_force("spectators")
  end
end

function set_areas(i)
  shuffle_table(global.force_list)
  if not global.previous_map_size then 
    global.previous_map_size = 5
  else
    global.previous_map_size = map_sets[global.current_map_index].map_set_tiles[0]
  end
  global.current_map_index = i
  if not map_sets[i] then return end
  if not global.placement_grid then
    create_grid()
  end
  for k, player in pairs (game.players) do
    set_spectator(player)
  end
  global.clear_areas_tick = game.tick + #global.force_list + 1
end

function decide_player_team(player)
  if not global.online_players then return end
  if not player.connected then 
    player.force = game.forces.spectators
    return
  end
  if player.force.name == "spectators" then return end
  if player.afk_time >= global.afk_time then player.force = game.forces.spectators return end
  table.insert(global.online_players, player)
end

function set_teams()
  global.online_players = {}
  for k, player in pairs(game.players) do
    decide_player_team(player)
  end
  if #global.online_players > 0 then
    global.players_per_team = math.floor((#global.online_players)^0.5)
  else
    global.players_per_team = 1
  end
  shuffle_table(global.online_players)
  for k, player in pairs (global.online_players) do
    set_player(player, k)
  end
  for k, player in pairs (global.online_players) do
    --We have to do this after all teams are assigned.
    give_starting_inventory(player)
  end

end

function refresh_leaderboard(player)
  if not player.connected then return end
  if not player.gui.left.top_flow then return end
  local gui = player.gui.left.top_flow
  
  if gui.leaderboard then
    gui.leaderboard.destroy()
  end
  
  if gui.recent_leaderboard then
    gui.recent_leaderboard.destroy()
  end
  
  local frame = gui.add{type = "frame", name = "leaderboard", caption = {""}, direction = "vertical"}
  frame.add{type = "label", name = global_points, caption = {"all-time"}}
  local leaderboard_table = frame.add{type = "table", colspan = 3, name = "leaderboard_table"}
  local count = 1
  for name, points in spairs(global.points, function(t, a, b) return t[b] < t[a] end) do
    if count <= 5 then
      local this = leaderboard_table.add{type = "label", name = name.."count", caption = {"", "#", count, ""}}
      this.style.font_color = {r = 1, g = 1, b = 0.2}
      local that = leaderboard_table.add{type = "label", name = name.."name", caption = name}
      if name == player.name then
        that.style.font_color = {r = 1, g = 0.6, b = 0.1}
        player.tag = "<#"..count.."/"..points..">"
      end

      leaderboard_table.add{type = "label", name = name.."points", caption = points}
      count = count + 1
    else
      count = count + 1
      if name == player.name then
        local this = leaderboard_table.add{type = "label", name = name.."count", caption = {"", "#", count, ""}}
        this.style.font_color = {r = 1, g = 1, b = 0.2}
        local that = leaderboard_table.add{type = "label", name = name.."name", caption = name}
        if name == player.name then
          that.style.font_color = {r = 1, g = 0.6, b = 0.1}
          player.tag = "<#"..count.."/"..points..">"
        end
        leaderboard_table.add{type = "label", name = name.."points", caption = points}
        break
      end
    end
  end
  local frame = gui.add{type = "frame", name = "recent_leaderboard", caption = {""}, direction = "vertical"}
  frame.add{type = "label", name = global_points, caption = {"recent"}}
  local leaderboard_table = frame.add{type = "table", colspan = 3, name = "leaderboard_table"}
  local count = 1
  for name, points in spairs(global.recent_points, function(t, a, b) return t[b] < t[a] end) do
    if count <= 5 then
      local this = leaderboard_table.add{type = "label", name = name.."count", caption = {"", "#", count, ""}}
      this.style.font_color = {r = 1, g = 1, b = 0.2}
      local that = leaderboard_table.add{type = "label", name = name.."name", caption = name}
      if name == player.name then
        that.style.font_color = {r = 1, g = 0.6, b = 0.1}
      end
      leaderboard_table.add{type = "label", name = name.."recent_points", caption = points}
      count = count + 1
    else
      count = count + 1
      if name == player.name then
        local this = leaderboard_table.add{type = "label", name = name.."count", caption = {"", "#", count, ""}}
        this.style.font_color = {r = 1, g = 1, b = 0.2}
        local that = leaderboard_table.add{type = "label", name = name.."name", caption = name}
        if name == player.name then
          that.style.font_color = {r = 1, g = 0.6, b = 0.1}
        end
        leaderboard_table.add{type = "label", name = name.."points", caption = points}
        return
      end
    end
  end
end

function set_player(player, k)
  set_spectator(player)
  local index = math.ceil(k/global.players_per_team)
  ::redo::
  if not global.force_list[index] then
    index = k % global.players_per_team
    goto redo
  end
  
  player.force = global.force_list[index].name
  set_character(player, player.force)
  local c = global.force_list[index].color
  player.color = {r = c[1], g = c[2], b = c[3], a = c[4]}
  give_equipment(player)

end

function generate_technology_list()
  global.task_technologies = {}
  local force = game.forces.player
  for k, technology in pairs (force.technologies) do
    local include = true
    for j, ingredient in pairs (technology.research_unit_ingredients) do
      if ingredient.name == "science-pack-3" or ingredient.name == "alien-science-pack" then
      include = false
      break
      end
    end
    if technology.upgrade then
      include = false
    end
    if include then
      local name = technology.name
      table.insert(global.task_technologies, name)
    end
  end
end

function generate_research_task()

  global.research_task = {}
  shuffle_table(global.task_technologies)
  local number_of_techs = math.random(1, 3)
  for k = 1, number_of_techs do
    global.research_task[k] = global.task_technologies[k]
  end
  
  global.progress = {}
  for j, force in pairs (game.forces) do
    global.progress[force.name] = {}
    for k, tech in pairs (global.research_task) do
      global.progress[force.name][tech] = 0
    end
    setup_unlocks(force)
  end
end

function setup_unlocks(force)
  if not force.valid then return end
  local challenge_type = global.challenge_type 
  for k, technology in pairs (force.technologies) do
    technology.enabled = false
  end
  
  for i, name in pairs (global.task_technologies) do
    local technology = force.technologies[name]
    technology.enabled = true
    technology.researched = true
  end 
    
  if challenge_type == "research" then
    local technologies_to_research = {}
    for _, research_task in pairs (global.research_task) do
      technologies_to_research[research_task] = true
    end
    
    for _, research_task in pairs (global.research_task) do
      local technology = force.technologies[research_task]
      technology.researched = false
      for _, prerequisite in pairs(technology.prerequisites) do
        if not technologies_to_research[prerequisite.name] then
          prerequisite.researched = true
          prerequisite.enabled = true
        end
      end
    end
  end

  for k, recipe in pairs (force.recipes) do
    for j, disallowed in pairs (global.disabled_items) do
      if recipe.name == disallowed then
        recipe.enabled = false
      end
    end
  end
  force.set_ammo_damage_modifier("bullet", -1)
  force.set_ammo_damage_modifier("flame-thrower", -1)
  force.set_ammo_damage_modifier("capsule", -1)
  force.set_ammo_damage_modifier("cannon-shell", -1)
  force.set_ammo_damage_modifier("grenade", -1)
  force.set_ammo_damage_modifier("electric", -1)
  force.worker_robots_speed_modifier = 3
end


function check_technology_progress(force)
  for k, technology in pairs (global.research_task) do
    if force.technologies[technology].researched == false then

      local tech = force.current_research
      if tech then
        if tech.name == technology then
          global.progress[force.name][technology] = force.research_progress
        end
      end
    else
    global.progress[force.name][technology] = 100
    end
  end
end

function generate_production_task()

  local items_to_choose
  local number_of_items
  local type = global.challenge_type 
  if type == "input_output" then
    number_of_items = 1
    items_to_choose = global.input_task_items
  end  
  
  if type == "production" then
    number_of_items = math.random(1, global.max_count_of_production_tasks)
    items_to_choose = global.item_list
  end
  
  shuffle_table(items_to_choose)
  global.task_items = {}
  local max_count = calculate_task_item_multiplayer(number_of_items)
  for k = 1, number_of_items do
    global.task_items[k] = {}
    global.task_items[k].name = items_to_choose[k].name
    global.task_items[k].count = math.random(2, max_count)*items_to_choose[k].count
    if type == "input_output" then
      global.round_input = items_to_choose[k].input
    end
  end
  
  global.progress = {}
  for j, force in pairs (game.forces) do
    global.progress[force.name] = {}
    for k, item in pairs (global.task_items) do
      global.progress[force.name][item.name] = 0
    end
    setup_unlocks(force)
  end
 
end


function generate_shopping_list_task()
  shuffle_table(global.item_list)
  local multiplier = math.ceil((#global.online_players)/global.players_per_team)
  local number_of_items = math.random(1, global.max_count_of_production_tasks)
  local max_count = calculate_task_item_multiplayer(number_of_items)
  global.task_items = {}
  for k = 1, number_of_items do
    global.task_items[k] = {}
    global.task_items[k].name = global.item_list[k].name
    global.task_items[k].count = math.random(2, max_count)*global.item_list[k].count*multiplier
    global.task_items[k].remaining = global.task_items[k].count
  end
  global.progress = {}
  for j, force in pairs (game.forces) do
    global.progress[force.name] = {}
    for k, item in pairs (global.task_items) do
      global.progress[force.name][item.name] = 0
    end
    setup_unlocks(force)
  end
end


function set_gui_flow_table(player)
--This will destory everything, and make it again all in the proper order and stuff. 
  local gui = player.gui.left
  
  if gui.top_flow then 
    gui.top_flow.destroy() 
  end
  
  local top_flow = gui.add{type = "table", name = "top_flow", colspan = 5}
  top_flow.style.horizontal_spacing = 0
  update_task_gui(player)
  refresh_leaderboard(player)
  update_end_timer(player)
  update_begin_timer(player)
  
end

function check_item_lists()
  for k, item in pairs (global.item_list) do
    if not game.item_prototypes[item.name] then
      game.print(item.name.." BAD INPUT")
    end
  end
  
  for k, item in pairs (global.input_task_items) do
    if not game.item_prototypes[item.name] then
      game.print(item.name.." BAD INPUT")
    end
  end
  
  for k, item in pairs (global.disabled_items) do
    if not game.item_prototypes[item] then
      game.print(item.." BAD INPUT")
    end
  end
  
  for k, item in pairs (global.starting_inventories["small"]) do
    if not game.item_prototypes[item.name] then
      game.print(item.name.." BAD INPUT")
    end
  end
  
  for k, item in pairs (global.starting_inventories["medium"]) do
    if not game.item_prototypes[item.name] then
      game.print(item.name.." BAD INPUT")
    end
  end
  
  for k, item in pairs (global.starting_inventories["large"]) do
    if not game.item_prototypes[item.name] then
      game.print(item.name.." BAD INPUT")
    end
  end
end

function update_task_gui(player)
  if not global.challenge_type then return end
  
  if global.challenge_type == "production" then
    update_production_task_table(player)
    return
  end
  
  if global.challenge_type == "input_output" then
    update_production_task_table(player)
    return
  end
  
  if global.challenge_type == "research" then
    update_research_task_table(player)
    return
  end
  
  if global.challenge_type == "shopping_list" then
    update_shopping_list_task_table(player)
    return
  end
  
end


function check_end_of_round()
  if game.tick ~= global.end_round_tick then return end
  save_round_statistics()
  global.end_round_tick = nil
  global.start_round_tick = game.tick + 60 * 60
  global.chests = nil
  global.input_chests = nil
  global.task_items = nil
  global.progress = nil
  global.research_task = nil
  global.challenge_type = nil

  for k, player in pairs(game.players) do
    end_round_gui_update(player)
  end
end

function end_round_gui_update(player)
  if not player.connected then return end
  if not player.gui.left.top_flow then return end
  update_end_timer(player)
  player.print({"next-round-soon"})
  set_spectator(player)
  update_begin_timer(player)
  if not player.gui.left.top_flow.winners_frame then return end
  player.gui.left.top_flow.winners_frame.caption = {"round-winners"}
end

function try_to_check_victory()
  if game.tick % 60 ~= 0 then return end
  for k, force in pairs (game.forces) do
    check_victory(force)
  end
end

function update_gui()
  if game.tick % 60 ~= 0 then return end
  for k, player in pairs(game.players) do
    update_end_timer(player)
    update_begin_timer(player)
    update_task_gui(player)
  end
end

function check_start_round()
  if game.tick ~= global.start_round_tick then return end
  global.start_round_tick = nil
  global.winners = {}
  start_challenge()
  for k, player in pairs(game.players) do
    set_gui_flow_table(player)
    update_begin_timer(player)
  end
end

function check_start_set_areas()
  if not global.start_round_tick then return end
  --Calculates when to start settings the areas
  if global.start_round_tick - ((#global.force_list) * 2 + ((#global.force_list) * global.ticks_to_generate_entities)) == game.tick then
    set_areas(math.random(#map_sets))
  end
end

function check_start_setting_entities()
  --Start setting the entities
  if not global.set_entities_tick then return end
  local entities = map_sets[global.current_map_index].map_set_entities
  local distance = map_sets[global.current_map_index].map_set_tiles[0]
  local index = math.ceil((global.set_entities_tick - game.tick)/global.ticks_to_generate_entities)
  if index == 0 then
    global.set_entities_tick = nil
    return
  end
  local listed = global.force_list[index]
  if not listed then return end
  
  local grid_position = global.placement_grid[index]
  local force = game.forces[listed.name]
  local offset_x = grid_position[1] * (distance*2 + global.distance_between_areas)
  local offset_y = grid_position[2] * (distance*2 + global.distance_between_areas)
  recreate_entities(entities, offset_x, offset_y, force, global.ticks_to_generate_entities)
  
end

function check_clear_areas()
  if not global.clear_areas_tick then return end
  local index = global.clear_areas_tick - game.tick
  
  if index == 0 then
    global.clear_areas_tick = nil
    global.set_areas_tick = game.tick + #global.force_list
    global.this_round_clear_map_tiles = nil
    return
  end
  
  if not global.this_round_clear_map_tiles then
    global.this_round_clear_map_tiles = {}
    local radius = global.previous_map_size
    global.this_round_clear_map_tiles[0] = radius
    for X = -radius, radius-1 do
      for Y = -radius, radius-1 do
        local tile = "out-of-map"
        table.insert(global.this_round_clear_map_tiles, tile)
      end
    end
  end
  local distance = global.previous_map_size
  local grid_position = global.placement_grid[index]
  local offset_x = grid_position[1] * (distance*2 + global.distance_between_areas)
  local offset_y = grid_position[2] * (distance*2 + global.distance_between_areas)
  create_tiles(global.this_round_clear_map_tiles, offset_x, offset_y, false)
  local area = {{offset_x - distance*2, offset_y - distance*2}, {offset_x + distance*2, offset_y + distance*2}}
  for k, v in pairs (game.surfaces[1].find_entities(area)) do
    v.destroy()
  end
end

function check_set_areas()
  if not global.set_areas_tick then return end
  local tiles = map_sets[global.current_map_index].map_set_tiles
  local distance = tiles[0]
  local index = global.set_areas_tick - game.tick
  
  if index == 0 then
    global.set_areas_tick = nil
    global.set_entities_tick = game.tick + (#global.force_list * global.ticks_to_generate_entities)
    return
  end
  
  local listed = global.force_list[index]
  if not listed then return end
  
  local grid_position = global.placement_grid[index]
  local force = game.forces[listed.name]
  
  if not force then 
    game.print(listed.name.." is not a valid force")
    return
  end
  
  if not force.valid then return end
  local offset_x = grid_position[1] * (distance*2 + global.distance_between_areas)
  local offset_y = grid_position[2] * (distance*2 + global.distance_between_areas)
  create_tiles(tiles, offset_x, offset_y, true)
  force.set_spawn_position({offset_x, offset_y}, game.surfaces[1])
  force.rechart()
end

--Checks 1 at a time
function check_chests()
  if not global.chests then return end

  local index = (game.tick % #global.chests) + 1
  local chest = global.chests[index]
  if not chest then return end

  if not chest.valid then
    table.remove(global.chests, index)
    return
  end
  
  if global.challenge_type == "production" then
    check_chests_production(chest)
    return
  end
  
  if global.challenge_type == "input_output" then
    check_chests_production(chest)
    return
  end
  
  if global.challenge_type == "shopping_list" then
    check_chests_shopping_list(chest)
    return
  end

end

function check_chests_shopping_list(chest)
  if not global.task_items then return end
  for k, item in pairs (global.task_items) do
    local count = chest.get_item_count(item.name)
    if count > item.remaining then
      count = item.remaining
    end
    if count > 0 then
      chest.remove_item({name = item.name, count = count})
      global.progress[chest.force.name][item.name] = global.progress[chest.force.name][item.name] + count
      item.remaining = item.remaining - count
      for k, player in pairs (chest.force.players) do
        update_task_gui(player)
      end
    end
  end
end

function check_chests_production(chest)
  if not global.task_items then return end
  for k, item in pairs (global.task_items) do
    local count = chest.get_item_count(item.name)
    if count + global.progress[chest.force.name][item.name] > item.count then
      count = item.count - global.progress[chest.force.name][item.name]
    end
    if count > 0 then
      chest.remove_item({name = item.name, count = count})
      global.progress[chest.force.name][item.name] = global.progress[chest.force.name][item.name] + count
      for k, player in pairs (chest.force.players) do
        update_task_gui(player)
      end
    end
  end
end

function check_input_chests()
  if not global.input_chests then return end
  if game.tick % 1200 > #global.input_chests then return end

  if global.challenge_type ~= "input_output" then return end
  if not global.round_input then return end
  local index = (game.tick % #global.input_chests) + 1
  local chest = global.input_chests[index]
  if not chest then return end
  
  if not chest.valid then
    table.remove(global.input_chests, index)
    return
  end
  if not game.item_prototypes[global.round_input] then game.print("BAD INPUT ITEM") return end
  chest.insert{name = global.round_input, count = 10000}
end

function fill_input_chests()
  if not global.input_chests then return end
  if global.challenge_type ~= "input_output" then return end
  if not global.round_input then return end
  if not game.item_prototypes[global.round_input] then game.print("BAD INPUT ITEM") return end
  for k, chest in pairs (global.input_chests) do
    if chest.valid then
      chest.insert{name = global.round_input, count = 10000}
    else
      table.remove(global.input_chests, k)
    end
  end
end

function check_victory(force)
  if not global.challenge_type then return end
  if not force.valid then return end
  if not global.winners then return end
  
  for k, winners in pairs (global.winners) do
    if force == winners then
      return
    end
  end

  local challenge_type = global.challenge_type
  
  if challenge_type == "production" then
    local finished_tasks = 0
    for k, item in pairs (global.task_items) do
      if global.progress[force.name][item.name] >= item.count then
      finished_tasks = finished_tasks +1
      end
    end
    if finished_tasks >= #global.task_items then
      team_finished(force)
    end
    return
  end
  
  if challenge_type == "input_output" then
    local finished_tasks = 0
    for k, item in pairs (global.task_items) do
      if global.progress[force.name][item.name] >= item.count then
      finished_tasks = finished_tasks +1
      end
    end
    if finished_tasks >= #global.task_items then
      team_finished(force)
    end
    return
  end
  
  if challenge_type == "research" then
    check_technology_progress(force)
    local finished_tasks = 0
    for k, technology in pairs (global.research_task) do
      if global.progress[force.name][technology] == 100 then
        finished_tasks = finished_tasks + 1
      end
    end
    if finished_tasks >= #global.research_task then
      team_finished(force)
    end
    return
  end
  
  if challenge_type == "shopping_list" then
    if global.winners[1] then return end
    local finished_tasks = 0
    for k, item in pairs (global.task_items) do
      if item.remaining == 0 then
      finished_tasks = finished_tasks +1
      end
    end
    if finished_tasks >= #global.task_items then
      shopping_task_finished()
    end
    return
  end
end

function shopping_task_finished()
  local multiplier = math.ceil((#global.online_players)/global.players_per_team)
  local total_points = global.points_per_win * multiplier
  local points_per_task = total_points/(#global.task_items)
  for k, item in pairs (global.task_items) do
    for j, force in pairs (game.forces) do
      calculate_force_points(force, item, points_per_task)
    end
  end
  
  for name, points in spairs(global.force_points, function(t, a, b) return t[b] < t[a] end) do
    if points > 0 then
      table.insert(global.winners, game.forces[name])
    end
  end
  global.end_round_tick = game.tick + 1
  for k, player in pairs (game.players) do
    update_winners_list(player)
    player_ending_prompt(player)
  end
end

function calculate_force_points(force,item, points)
  if points <= 0 then return end
  if not global.progress then return end
  if not global.progress[force.name] then return end
  if not global.progress[force.name][item.name] then return end
  if not item.count then return end
  if global.progress[force.name][item.name] <= 0 then return end
  local count = global.progress[force.name][item.name]
  local total = item.count
  local awarded_points = math.floor((count/total)*points)
  give_force_players_points(force, awarded_points)
end

function update_research_task_table(player)
  if not player.connected then return end
  if not global.research_task then return end
  if not global.progress[player.force.name] then return end
  if not player.gui.left.top_flow then return end
  local gui = player.gui.left.top_flow
  
  if player.force.name == "spectators" then
  
    if gui.task_frame then 
      gui.task_frame.round_timer.caption = {"", {"elapsed-time"}, ": ", format_time(game.tick - global.round_timer_value), ""}
      return
    end 
    
    local frame = gui.add{name = "task_frame", type = "frame", direction = "vertical", caption = {"", {"round"}, "\n ", global.recent_round_number, " ", {"of"}, " " .. global.recent_round_count .. "\n"}}
    frame.style.minimal_width = 160
    frame.add{type = "label", name = "round_timer", caption = {"", {"elapsed-time"}, ": ", format_time(game.tick - global.round_timer_value), ""}}
    local tech_table = frame.add{type = "table", name = "tech_table", colspan = 1}
    for i, tech in pairs (global.research_task) do
      tech_table.add{type = "label", name = "task"..i, caption = player.force.technologies[tech].localised_name}
    end
    return
  end
  
  if gui.task_frame then
    if not gui.task_frame.tech_table then return end
    gui.task_frame.round_timer.caption = {"", {"elapsed-time"}, ": ", format_time(game.tick - global.round_timer_value), ""}
    for i, tech in pairs (global.research_task) do
      gui.task_frame.tech_table["progress"..i].value=global.progress[player.force.name][tech]
    end
    return
  end
  
  local frame = gui.add{name = "task_frame", type = "frame", direction = "vertical", caption = {"", {"round"}, "\n ", global.recent_round_number, " ", {"of"}, " " .. global.recent_round_count .. "\n"}}
  frame.style.minimal_width = 160
  frame.add{type = "label", name = "round_timer", caption = {"", {"elapsed-time"}, ": ", format_time(game.tick - global.round_timer_value), ""}}
  local tech_table = frame.add{type = "table", name = "tech_table", colspan = 1}
  tech_table.add{type = "label", name = "task_description", caption = {"research-task"}}
  for i, tech in pairs (global.research_task) do
    tech_table.add{type = "label", name = "task"..i, caption = {"", player.force.technologies[tech].localised_name, ": ", ""}}
    tech_table.add{type = "progressbar", name = "progress"..i, size = 100}
  end

end


function update_production_task_table(player)
  if not player.connected then return end
  if not global.task_items then return end
  if not global.progress[player.force.name] then return end
  if not player.gui.left.top_flow then return end
  local gui = player.gui.left.top_flow
  
  if player.force.name == "spectators" then
  
    if gui.task_frame then
      gui.task_frame.round_timer.caption = {"", {"elapsed-time"}, ": ", format_time(game.tick - global.round_timer_value), ""}
      return
    end
    
    local frame = gui.add{name = "task_frame", type = "frame", direction = "vertical", caption = {"", {"round"}, "\n ", global.recent_round_number, " ", {"of"}, " " .. global.recent_round_count .. "\n"}}
    frame.style.minimal_width = 160
    frame.style.right_padding = 0
    frame.add{type = "label", name = "round_timer", caption = {"", {"elapsed-time"}, ": ", format_time(game.tick - global.round_timer_value), ""}}
    local task_table = frame.add{type = "table", colspan = 2, name = "task_table"}
    task_table.add{type = "label", name = "task_description", caption = {"", {"production-task"}, ""}}
    task_table.add{type = "label", name = "task_description_pad", caption = ""}
    for i, item in pairs (global.task_items) do
      task_table.add{type = "label", name = "task"..i, caption = {"", game.item_prototypes[item.name].localised_name, ": "}}
      task_table.add{type = "label", name = "count"..i, caption = item.count}
    end

    return
  end
  
  if gui.task_frame then
    if not gui.task_frame.task_table then return end
    gui.task_frame.round_timer.caption = {"", {"elapsed-time"}, ": ", format_time(game.tick - global.round_timer_value), ""}
    for i, item in pairs (global.task_items) do
      if global.progress[player.force.name][item.name] then
        gui.task_frame.task_table["count"..i].caption = {"", global.progress[player.force.name][item.name], "/", item.count}
      else
        log("Global progress nil error"..player.force.name.."  "..item.name.."  "..item.count)
      end
    end
    return
  end
  
  local frame = gui.add{name = "task_frame", type = "frame", direction = "vertical", caption = {"", {"round"}, "\n ", global.recent_round_number, " ", {"of"}, " " .. global.recent_round_count .. "\n"}}
  frame.style.minimal_width = 160
  frame.add{type = "label", name = "round_timer", caption = {"", {"elapsed-time"}, ": ", format_time(game.tick - global.round_timer_value), ""}}
  local task_table = frame.add{type = "table", colspan = 2, name = "task_table"}
  task_table.add{type = "label", name = "task_description", caption = {"", {"production-task"}, ""}}
  task_table.add{type = "label", name = "task_description_pad", caption = ""}
  for i, item in pairs (global.task_items) do
    task_table.add{type = "label", name = "task"..i, caption = {"", game.item_prototypes[item.name].localised_name, ": "}}
    task_table.add{type = "label", name = "count"..i, caption = {"", global.progress[player.force.name][item.name], "/", item.count}}
  end
end


function update_shopping_list_task_table(player)
  if not player.connected then return end
  if not global.task_items then return end
  if not global.progress[player.force.name] then return end
  if not player.gui.left.top_flow then return end
  local gui = player.gui.left.top_flow
  
  if player.force.name == "spectators" then
  
    if gui.task_frame then
      gui.task_frame.round_timer.caption = {"", {"elapsed-time"}, ": ", format_time(game.tick - global.round_timer_value), ""}
      for i, item in pairs (global.task_items) do
      if global.progress[player.force.name][item.name] then
        gui.task_frame.task_table["count"..i].caption = item.remaining
      end
    end
      return
    end
    
    local frame = gui.add{name = "task_frame", type = "frame", direction = "vertical", caption = {"", {"round"}, "\n ", global.recent_round_number, " ", {"of"}, " " .. global.recent_round_count .. "\n"}}
    frame.style.minimal_width = 160
    frame.style.right_padding = 0
    frame.add{type = "label", name = "round_timer", caption = {"", {"elapsed-time"}, ": ", format_time(game.tick - global.round_timer_value), ""}}
    local task_table = frame.add{type = "table", colspan = 2, name = "task_table"}
    task_table.add{type = "label", name = "task_description", caption = {"", {"shopping-task"}, ""}}
    task_table.add{type = "label", name = "task_description_pad", caption = ""}
    for i, item in pairs (global.task_items) do
      task_table.add{type = "label", name = "task"..i, caption = {"", game.item_prototypes[item.name].localised_name, ": "}}
      task_table.add{type = "label", name = "count"..i, caption = item.remaining}
    end

    return
  end
  
  if gui.task_frame then
    if not gui.task_frame.task_table then return end
    gui.task_frame.round_timer.caption = {"", {"elapsed-time"}, ": ", format_time(game.tick - global.round_timer_value), ""}
    for i, item in pairs (global.task_items) do
      if global.progress[player.force.name][item.name] then
        gui.task_frame.task_table["count"..i].caption = global.progress[player.force.name][item.name].." / "..item.remaining
      else
        log("Global progress nil error"..player.force.name.."  "..item.name.."  "..item.remaining)
      end
    end
    return
  end
  
  local frame = gui.add{name = "task_frame", type = "frame", direction = "vertical", caption = {"", {"round"}, "\n ", global.recent_round_number, " ", {"of"}, " " .. global.recent_round_count .. "\n"}}
  frame.style.minimal_width = 160
  frame.add{type = "label", name = "round_timer", caption = {"", {"elapsed-time"}, ": ", format_time(game.tick - global.round_timer_value), ""}}
  local task_table = frame.add{type = "table", colspan = 2, name = "task_table"}
  task_table.add{type = "label", name = "task_description", caption = {"", {"shopping-task"}, ""}}
  task_table.add{type = "label", name = "task_description_pad", caption = ""}
  for i, item in pairs (global.task_items) do
    task_table.add{type = "label", name = "task"..i, caption = {"", game.item_prototypes[item.name].localised_name, ": "}}
    task_table.add{type = "label", name = "count"..i, caption = global.progress[player.force.name][item.name].." / "..item.remaining}
  end
end

function create_joined_game_gui(player)
  local gui = player.gui.center
  if gui.center_splash then return end
  local frame = gui.add{type = "frame", name = "center_splash",direction = "vertical", caption = {"",{"center-label-welcome"},""}}
  frame.add{type = "label", name = "center_label-1", caption = {"",{"center-label-1"},""}}
  frame.add{type = "label", name = "center_label-2", caption = {"",{"center-label-2"},""}}
  frame.add{type = "label", name = "center_label-3", caption = {"",{"center-label-3"},"                  "}}
  local center_table = frame.add{type = "table", name = "center_table", colspan = 2}
  center_table.add{type = "button", name = "join-game", caption = {"",{"join-game"},""} }
  center_table.add{type = "button", name = "remain-spectate", caption = {"",{"remain-spectate"},""} }
end

function pre_ending_round()
  global.end_round_tick = game.tick + 60*60*2 --2 minutes
  for k, player in pairs(game.players) do
    player_ending_prompt(player)
  end
end

function player_ending_prompt(player)
  if not player.connected then return end
  update_end_timer(player)
  player.set_goal_description("Hi")
  player.set_goal_description("")
end

function update_end_timer(player)
  if not player.connected then return end
  if not global.end_round_tick then return end
  if not player.gui.left.top_flow then return end
  local gui = player.gui.left.top_flow
  if not gui.winners_frame then return end
  gui.winners_frame.caption = {"", {"winners"}, " - ", {"end-round"}, ": ", format_time(global.end_round_tick - game.tick)}
end

function update_begin_timer(player)

  if not player.connected then return end
  if not player.gui.left.top_flow then return end
  local gui = player.gui.left.top_flow
  if not global.start_round_tick then 
    if gui.pre_counter then
        gui.pre_counter.destroy()
    end
    return 
  end

  if gui.pre_counter then
    gui.pre_counter.caption = {"", {"begin-round"}, " - ", format_time(global.start_round_tick - game.tick)}
    return
  end
  
  local frame = gui.add{name = "pre_counter", type = "frame", direction = "horizontal", caption = {"", {"begin-round"}, " - ", format_time(global.start_round_tick - game.tick)}}
  if player.force.name == "spectators" then
    frame.add{type = "button", name = "spectate_button", caption = {"", {"unspectate"}, ""}}
  else
    frame.add{type = "button", name = "spectate_button", caption = {"", {"spectate"}, ""}}
  end
  
   
end

function team_finished(force)
  if not force.valid then return end
  if not global.progress then return end
  if not global.progress[force.name] then return end
  
  table.insert(global.winners, force)
  local points = global.points_per_win
  
  for j, winning_force in pairs (global.winners) do
    if winning_force == force then
      points = math.floor(points/j)
      break
    end
  end
  
  if #global.winners == 1 then
    pre_ending_round()
  end
  give_force_players_points(force, points)
  for k, player in pairs(game.players) do
    if player.force ~= force then 
      player.print({"", force.name, " ", {"finished-task"}, ""})
    else
      player.print({"", {"your-team-win"}, " "..global.force_points[force.name].." ", {"points"}, "."})
      set_spectator(player)
    end
    update_winners_list(player)
    refresh_leaderboard(player)
  end
  save_points_list()
end

function save_points_list()
  local points_lua = "function give_points()\n  return\n  {\n"
  for name, points in pairs (global.points) do
    points_lua = points_lua .. "    [\""..name.."\"] = "..points..", \n";
  end
  points_lua = points_lua .. "  }\nend"
  game.write_file("points.lua", points_lua, false, 0)
end

function give_force_players_points(force, points)
  if not force.valid then return end
  if points <= 0 then return end
  if not global.force_points then global.force_points = {} end
  
  if not global.force_points[force.name] then 
    global.force_points[force.name] = points 
  else
    global.force_points[force.name] = global.force_points[force.name] + points 
  end
  
  for k, player in pairs (force.players) do
    if not global.points[player.name] then
      global.points[player.name] = points
    else
      global.points[player.name] = global.points[player.name] + points
    end
    
    if not global.recent_points[player.name] then
      global.recent_points[player.name] = points
    else
      global.recent_points[player.name] = global.recent_points[player.name] + points
    end
  end
  
end

function update_winners_list(player)
  if not player.connected then return end
  if not player.gui.left.top_flow then return end
  local gui = player.gui.left.top_flow
  if not global.winners then return end
  if #global.winners == 0 then return end
  if not global.force_points then return end
  
  if not gui.winners_frame then
    local frame = gui.add{type = "frame", name = "winners_frame", caption = {"", {"winners"}, " - ", {"end-round"}, ": ", format_time(global.end_round_tick - game.tick)}, direction = "vertical"}
    local winners_table = frame.add{type = "table", name = "winners_table", colspan = 4}
    winners_table.add{type = "label", name = "winners_name", caption = {"name"}}
    winners_table.add{type = "label", name = "winners_players", caption = {"members"} }
    winners_table.add{type = "label", name = "winners_time" , caption = {"time"} }
    winners_table.add{type = "label", name = "winners_points" , caption = {"points"} }
  end

  for k, force in pairs(global.winners) do
    if k > 5 then return end
    if not global.force_points[force.name] then return end
    if gui.winners_frame.winners_table[force.name] then goto skip end
    
    local winners_table = gui.winners_frame.winners_table
    local this = winners_table.add{type = "label", name = force.name, caption = {"", "#", k, " ", force.name, " ", {"team"}}}
    local color = {r = 0.8, g = 0.8, b = 0.8, a = 0.8}
    
    for i, check_force in pairs (global.force_list) do
      if force.name == check_force.name then
        local c = check_force.color
        color = {r = 1 - (1 - c[1]) * 0.5, g = 1 - (1 - c[2]) * 0.5, b = 1 - (1 - c[3]) * 0.5, a = 1}
        break
      end
    end
    
    this.style.font_color = color
    local caption = ""
    local count = 0
    for j, player in pairs(force.players) do
      count = count + 1
      if player.connected then
        if count == 1 then
          caption = caption..player.name
        else
          caption = caption..", "..player.name
        end
      end
    end
    winners_table.add{type = "label", name = force.name.."players", caption = caption}
    winners_table.add{type = "label", name = force.name.."time", caption = format_time(game.tick - global.round_timer_value)}
    winners_table.add{type = "label", name = force.name.."points", caption = global.force_points[force.name]}
    ::skip::
  end
end


function set_spectator(player)
  if not player.connected then return end
  if not player.character then return end
  
  local character = player.character
  player.character = nil
  if character then
    character.destroy()
  end
  player.set_controller{type = defines.controllers.ghost}
end

function set_character(player, force)
  if not player.connected then return end
  if not force.valid then return end
  player.force = force
  local character = player.surface.create_entity{name = "player", position = player.surface.find_non_colliding_position("player", player.force.get_spawn_position(player.surface), 10, 2), force = force}
  player.set_controller{type = defines.controllers.character, character = character}
end

function give_starting_inventory(player)
  if not player.connected then return end
  if not player.character then return end
  if not global.starting_inventories[global.round_inventory] then return end
  for k, item in pairs (global.starting_inventories[global.round_inventory]) do
    local count = math.ceil(item.count*(global.players_per_team/#player.force.players))
    if count > 0 then
      player.insert{name = item.name, count = count}
    end
  end
end

function give_equipment(player)
  if not player.connected then return end
  if not player.character then return end
  if not global.round_equipment then return end

  if global.round_equipment == "small" then
    player.insert{name = "power-armor", count = 1}
    local p_armor = player.get_inventory(5)[1].grid
    p_armor.put({name = "fusion-reactor-equipment"})
    p_armor.put({name = "exoskeleton-equipment"})
    p_armor.put({name = "personal-roboport-equipment"})
    p_armor.put({name = "personal-roboport-equipment"})
    p_armor.put({name = "personal-roboport-equipment"})
    player.insert{name="construction-robot", count = 30}
    player.insert{name="blueprint", count = 3}
    player.insert{name="deconstruction-planner", count = 1}
    return
  end
end

function shuffle_table(t)
  local iterations = #t
  for i = iterations, 2, -1 do
    local j = math.random(i)
    t[i], t[j] = t[j], t[i]
  end
end

function format_time(ticks)
  local seconds = ticks / 60
  local minutes = math.floor((seconds)/60)
  local seconds = math.floor(seconds - 60*minutes)
  return string.format("%d:%02d", minutes, seconds)
end

function spairs(t, order)
    -- collect the keys
    local keys = {}
    for k in pairs(t) do keys[#keys+1] = k end

    -- if order function given, sort by it by passing the table and keys a, b,
    -- otherwise just sort the keys
    if order then
        table.sort(keys, function(a, b) return order(t, a, b) end)
    else
        table.sort(keys)
    end

    -- return the iterator function
    local i = 0
    return function()
        i = i + 1
        if keys[i] then
            return keys[i], t[keys[i]]
        end
    end
end

function fill_leaderboard()
  global.points = give_points()
  global.recent_points = {}
  for k, player in pairs (game.players) do
    refresh_leaderboard(player)
  end
end
