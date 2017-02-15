
function transport_belt_madness_init(levels)
  local result = {}
  result.levels = levels
  -- Part of the level data that needs to be serialised to preserve game state
  result.current_level = 1
  -- Warning, there can be holes in these arrays, don't use for each, # or sort
  result.input_chest = {}
  result.output_chest = {}
  result.input_inserter = {}
  result.output_inserter = {}
  return result
end

function transport_belt_madness_init_level(this)
  local level = levels[this.current_level]
  local chests = level.chests
  local chest_count = #chests
  local level_width = level.level_width
  local chest_starting_position = {x = -math.ceil(level_width / 2), y = -math.ceil(chest_count / 2)}
  local chest_ending_position = {x = math.ceil(level_width / 2), y = -math.ceil(chest_count / 2)}
  for index, item in pairs(chests) do
    local chest_input_position;
    if item.input_position == nil then
      chest_input_position = {chest_starting_position.x, chest_starting_position.y + item.input}
     else
      chest_input_position = item.input_position[1]
    end
    local input_chest = game.players[1].surface.create_entity{name="steel-chest",
                                                         position=chest_input_position,
                                                         force = game.forces.player}
    this.input_chest[item.input] = input_chest
    input_chest.operable = false
    input_chest.minable = false

    local inserter_input_direction
    local inserter_input_position
    if item.input_position == nil then
      inserter_input_position = {chest_starting_position.x + 1, chest_starting_position.y + item.input}
      inserter_input_direction = defines.direction.east
    else
      inserter_input_position = util.moveposition(item.input_position[1], item.input_position[2], 1)
      inserter_input_direction = item.input_position[2]
    end

    local input_inserter = game.players[1].surface.create_entity{name = "inserter",
                                                            position = inserter_input_position,
                                                            direction = util.oppositedirection(inserter_input_direction),
                                                            force = game.forces.player}
    this.input_inserter[item.input] = input_inserter
    input_inserter.operable = false
    input_inserter.minable = false
    input_inserter.rotatable = false
    input_inserter.active = false


    local chest_output_position;
    if item.output_position == nil then
      chest_output_position = {chest_ending_position.x, chest_starting_position.y + item.output}
     else
      chest_output_position = item.output_position[1]
    end
    local output_chest = game.players[1].surface.create_entity{name = "logistic-chest-passive-provider",
                                                          position = chest_output_position,
                                                          force = game.forces.player}
    this.output_chest[item.output] = output_chest
    output_chest.operable = false
    output_chest.minable = false

    local inserter_output_direction
    local inserter_output_position
    if item.output_position == nil then
      inserter_output_position = {chest_output_position[1] - 1, chest_output_position[2]}
      inserter_output_direction = defines.direction.west
    else
      inserter_output_position = util.moveposition(chest_output_position, item.output_position[2], 1)
      inserter_output_direction = item.output_position[2]
    end

    local output_inserter = game.players[1].surface.create_entity{name = "fast-inserter",
                                                             position = inserter_output_position,
                                                             direction = inserter_output_direction,
                                                             force = game.players[1].force}
    this.output_inserter[item.output] = output_inserter
    output_inserter.operable = false
    output_inserter.minable = false
    output_inserter.rotatable = false
    output_inserter.active = false
  end
  local character = game.players[1].character
  if character then character.destroy() end
  game.players[1].set_controller({type=defines.controllers.god})
  game.players[1].teleport(level.starting_location)
  for index, item in pairs(level.resources) do
    game.players[1].insert{name = item.name, count=item.count}
  end
  game.players[1].force.disable_all_prototypes()
  game.players[1].cheat_mode = true
  local recipeList = game.players[1].force.recipes
  for index, item in pairs(level.recipes) do
    recipeList[item].enabled = true
  end
  if level.show_rules ~= nil then
    game.show_message_dialog{text={"welcome"}}
    game.show_message_dialog{text={"rules1"}}
    game.show_message_dialog{text={"rules2"}}
  end
  transport_belt_madness_fill_chests(this)
end

function  transport_belt_madness_fill_chests(this)
  local level = levels[this.current_level]
  local chests = level.chests
  local chest_count = #chests
  local level_width = level.level_width
  for index, item in pairs(chests) do
    local input_chest = this.input_chest[item.input]
    local input_chestinventory = input_chest.get_inventory(defines.inventory.chest)
    input_chestinventory.insert({name=item.item, count="20"})

    local output_chest = this.output_chest[item.output]
    local output_chestinventory = output_chest.get_inventory(defines.inventory.chest)
    output_chestinventory.insert({name=item.item, count="1"})
  end
  game.players[1].gui.top.direction = "vertical"
  game.players[1].gui.top.add{type="button", name="start", caption={"start"}}
  game.players[1].gui.top.add{type="button", name="clear", caption={"clear"}}
end

function  transport_belt_madness_start_level(this)
  game.save("before-run")
  game.players[1].gui.top.start.destroy()
  game.players[1].gui.top.clear.destroy()
  game.players[1].gui.top.add{type="button", name="back", caption={"back"}}
  game.players[1].set_controller{type=defines.controllers.ghost}
  local level = levels[this.current_level]
  game.players[1].print({"round-started"})
  for index, item in pairs(this.input_inserter) do
    item.active = true
  end
  for index, item in pairs(this.output_inserter) do
    item.active = true
  end
end

function transport_belt_madness_show_level_description(this)
  local level = levels[this.current_level]
  if level.description ~= nil then
    game.show_message_dialog{text={level.description}}
  end
end

function transport_belt_madness_check_level(this, event)
  if event.name == defines.events.on_gui_click and event.element.name == "back" then
    game.load("before-run")
    return ""
  end

  local level = levels[this.current_level]
  local chests = level.chests
  local allfull = true
  for index, item in pairs(chests) do
    local chest = this.output_chest[item.output]
    if chest == nil then
      return "Wrong chest"
    end
    local item_count = chest.get_item_count()
    if item_count ~= chest.get_item_count(item.item) then
      return {"failed", item.item}
    end
    if item_count ~= 21 then
      allfull = false
    end
  end
  if allfull then
    game.players[1].gui.top.back.destroy()
    return "finished"
  end
  return ""
end

function transport_belt_madness_next_level(this)
  this.current_level = this.current_level + 1
end

function transport_belt_madness_clear_level(this)
  local level = levels[this.current_level]
  local entities = game.players[1].surface.find_entities(level.area)
  for _, entity in ipairs(entities) do
    if entity.name == "item-on-ground" or
       entity.force == game.players[1].force and
       entity.name ~= "player" then
      entity.destroy()
    end
  end

  this.output_chest = {}
  this.input_chest = {}
  this.input_inserter = {}
  this.output_inserter = {}
  game.players[1].clear_items_inside()
end

function transport_belt_madness_contains_next_level(this)
  return (this.current_level <= #this.levels)
end


story_table =
{
  {
    {
      action = function()
        game.players[1].disable_recipe_groups()
        game.players[1].disable_recipe_subgroups()
        game.players[1].minimap_enabled = false
        game.map_settings.pollution.enabled = false
        transport_belt_madness_init_level(global.transport_belt_madness)
        global.transport_belt_madness.startup = true
      end
    },
    {
      action = function()
        transport_belt_madness_show_level_description(global.transport_belt_madness)
      end
    },
    {
      name= "start-level",
      action = function()
        if not global.transport_belt_madness.startup then transport_belt_madness_init_level(global.transport_belt_madness) end
        global.transport_belt_madness.startup = false
      end
    },
    {
      condition =
      function(event, story)
        if event.name == defines.events.on_gui_click and event.element.name == "clear" then
          transport_belt_madness_clear_level(global.transport_belt_madness)
          game.players[1].gui.top.start.destroy()
          game.players[1].gui.top.clear.destroy()
          story_jump_to(story, "start-level")
          return false
        end
        return event.name == defines.events.on_gui_click and event.element.name == "start"
      end,
      action =
      function()
        transport_belt_madness_start_level(global.transport_belt_madness)
      end
    },
    {
      condition =
      function(event, story)
        result = transport_belt_madness_check_level(global.transport_belt_madness, event)
        if result == "" then
          return false
        end
        if result == "finished" then
          return true
        end
        game.players[1].print(result)
        story_jump_to(story, "level-failed")
      end,
      action =
      function(event, story)
        transport_belt_madness_clear_level(global.transport_belt_madness)
        transport_belt_madness_next_level(global.transport_belt_madness)
        if transport_belt_madness_contains_next_level(global.transport_belt_madness) then
          story_jump_to(story, "start-level")
        end
      end
    }
  },
  {
    {
      name = "level-failed"
    },
    {
      condition = story_elapsed_check(6),
      action = function()
        game.set_game_state{game_finished=true, player_won=false}
      end
    }
  }
}

story_init_helpers(story_table)
