require "util"
require "story"

script.on_init(function()
  global.story = story_init()
  game.players[1].force.disable_all_prototypes()
  game.players[1].force.clear_chart()
  game.map_settings.enemy_expansion.enabled = false
  game.evolution_factor = 0.6

  local recipe_list = game.players[1].force.recipes
  recipe_list["iron-plate"].enabled = true
  recipe_list["copper-plate"].enabled = true
  recipe_list["stone-brick"].enabled = true
  recipe_list["stone-wall"].enabled = true
  recipe_list["gate"].enabled = true
  recipe_list["wood"].enabled = true
  recipe_list["stone-furnace"].enabled = true
  recipe_list["iron-stick"].enabled = true
  recipe_list["iron-axe"].enabled = true
  recipe_list["wooden-chest"].enabled = true
  recipe_list["iron-gear-wheel"].enabled = true
  recipe_list["burner-mining-drill"].enabled = true
  recipe_list["transport-belt"].enabled = true
  recipe_list["burner-inserter"].enabled = true
  recipe_list["offshore-pump"].enabled = true
  recipe_list["pipe"].enabled = true
  recipe_list["pipe-to-ground"].enabled = true
  recipe_list["boiler"].enabled = true
  recipe_list["steam-engine"].enabled = true
  recipe_list["electronic-circuit"].enabled = true
  recipe_list["copper-cable"].enabled = true
  recipe_list["pistol"].enabled = true
  recipe_list["submachine-gun"].enabled = true
  recipe_list["firearm-magazine"].enabled = true
  recipe_list["light-armor"].enabled = true
  recipe_list["electric-mining-drill"].enabled = true
  recipe_list["inserter"].enabled = true
  recipe_list["small-electric-pole"].enabled = true
  recipe_list["lab"].enabled = true
  recipe_list["science-pack-1"].enabled = true
  recipe_list["science-pack-2"].enabled = true
  recipe_list["iron-chest"].enabled = true
  recipe_list["repair-pack"].enabled = true

  local technology_list = game.players[1].force.technologies
  technology_list["laser"].enabled = true
  technology_list["logistics-3"].enabled = true
  technology_list["flame-thrower"].enabled = true
  technology_list["flammables"].enabled = true
  technology_list["modules"].enabled = true
  technology_list["speed-module"].enabled = true
  technology_list["speed-module-2"].enabled = true
  technology_list["effectivity-module"].enabled = true
  technology_list["effectivity-module-2"].enabled = true
  technology_list["productivity-module"].enabled = true
  technology_list["productivity-module-2"].enabled = true
  technology_list["alien-technology"].enabled = true
  technology_list["rocket-speed-1"].enabled = true
  technology_list["rocket-speed-2"].enabled = true
  technology_list["electric-energy-distribution-2"].enabled = true
  technology_list["oil-processing"].enabled = true
  technology_list["fluid-handling"].enabled = true
  technology_list["bullet-speed-3"].enabled = true
  technology_list["bullet-speed-4"].enabled = true
  technology_list["bullet-speed-5"].enabled = true
  technology_list["bullet-damage-3"].enabled = true
  technology_list["bullet-damage-4"].enabled = true
  technology_list["bullet-damage-5"].enabled = true
  technology_list["sulfur-processing"].enabled = true
  technology_list["plastics"].enabled = true
  technology_list["electric-engine"].enabled = true
  technology_list["toolbelt"].enabled = true
  technology_list["advanced-electronics"].enabled = true
  technology_list["explosives"].enabled = true
  technology_list["land-mine"].enabled = true
  technology_list["shotgun-shell-damage-1"].enabled = true
  technology_list["shotgun-shell-damage-2"].enabled = true
  technology_list["shotgun-shell-damage-3"].enabled = true
  technology_list["shotgun-shell-damage-4"].enabled = true
  technology_list["shotgun-shell-damage-5"].enabled = true
  technology_list["shotgun-shell-speed-1"].enabled = true
  technology_list["shotgun-shell-speed-2"].enabled = true
  technology_list["shotgun-shell-speed-3"].enabled = true
  technology_list["shotgun-shell-speed-4"].enabled = true
  technology_list["shotgun-shell-speed-5"].enabled = true
  technology_list["electric-energy-accumulators-1"].enabled = true
  technology_list["automation-3"].enabled = true
  technology_list["laser-turrets"].enabled = true
  technology_list["laser-turret-damage-1"].enabled = true
  technology_list["laser-turret-damage-2"].enabled = true
  technology_list["laser-turret-damage-3"].enabled = true
  technology_list["laser-turret-speed-1"].enabled = true
  technology_list["laser-turret-speed-2"].enabled = true
  technology_list["laser-turret-speed-3"].enabled = true

  technology_list["steel-processing"].researched = true
  technology_list["optics"].researched = true
  technology_list["logistics"].researched = true
  technology_list["logistics-2"].researched = true
  technology_list["automation"].researched = true
  technology_list["automation-2"].researched = true
  technology_list["electronics"].researched = true
  technology_list["military"].researched = true
  technology_list["military-2"].researched = true
  technology_list["military-3"].researched = true
  technology_list["turrets"].researched = true
  technology_list["armor-making"].researched = true
  technology_list["armor-making-2"].researched = true
  technology_list["bullet-damage-1"].researched = true
  technology_list["bullet-damage-2"].researched = true
  technology_list["bullet-speed-1"].researched = true
  technology_list["bullet-speed-2"].researched = true
  technology_list["automobilism"].researched = true
  technology_list["railway"].researched = true
  technology_list["automated-rail-transportation"].researched = true
  technology_list["rail-signals"].researched = true
  technology_list["advanced-material-processing"].researched = true
  technology_list["advanced-material-processing-2"].researched = true
  technology_list["solar-energy"].researched = true
  technology_list["electric-energy-distribution-1"].researched = true
  technology_list["engine"].researched = true
  technology_list["combat-robotics"].researched = true
  technology_list["follower-robot-count-8"].researched = true
  technology_list["battery"].researched = true
  technology_list["rocketry"].researched = true
  technology_list["stone-walls"].researched = true
  technology_list["gates"].researched = true

  local character = game.players[1].character
  character.insert{name = "transport-belt", count = 150}
  character.insert{name = "fast-transport-belt", count = 50}
  character.insert{name = "inserter", count = 40}
  character.insert{name = "fast-inserter", count = 20}
  character.insert{name = "medium-electric-pole", count = 10}
  character.insert{name = "small-electric-pole", count = 15}
  character.insert{name = "electric-mining-drill", count = 20}
  character.insert{name = "underground-belt", count = 20}
  character.insert{name = "long-handed-inserter", count = 20}
  character.insert{name = "assembling-machine-1", count = 5}
  character.insert{name = "assembling-machine-2", count = 5}
  character.insert{name = "stone-wall", count = 100}
  character.insert{name = "gun-turret", count = 20}
  character.insert{name = "pipe", count = 20}
  character.insert{name = "boiler", count = 10}
  character.insert{name = "offshore-pump", count = 2}
  character.insert{name = "electric-furnace", count = 20}
  character.insert{name = "lab", count = 5}
  character.insert{name = "steam-engine", count = 5}
  character.insert{name = "iron-plate", count = 250}
  character.insert{name = "copper-plate", count = 250}
  character.insert{name = "submachine-gun", count = 1}
  character.insert{name = "piercing-rounds-magazine", count = 200}
  character.insert{name = "rocket-launcher", count = 1}
  character.insert{name = "rocket", count = 50}
  character.insert{name = "steel-axe", count = 1}
  character.insert{name = "heavy-armor", count = 2}
  character.insert{name = "small-lamp", count = 20}
  character.insert{name = "alien-artifact", count = 60}
  character.selected_gun_index = 1

  local car = game.get_entity_by_tag("car")
  car.insert{name = "piercing-rounds-magazine", count = 500}
  car.insert{name = "iron-plate", count = 500}
  car.insert{name = "copper-plate", count = 500}
  car.insert{name = "steel-plate", count = 500}
  car.insert{name = "stone-brick", count = 50}
  car.insert{name = "stone-wall", count = 250}
  init_attack_data()
  game.map_settings.pollution.enabled = false
end)

function all_dead(entities)
  for key, entity in pairs(entities) do
    if not entity.valid then
      return false
    end
  end
  return true
end

story_table =
{
  {
    {
      action = function()
        local pos = game.players[1].character.position
        local bb = {{pos.x - 50, pos.y - 50}, {pos.x + 50, pos.y + 50}}
        global.close_enemies = game.players[1].surface.find_entities_filtered({area=bb, type="unit"})
      end
    },
    {
      condition = function() return not global.close_enemies or all_dead(global.close_enemies) end,
    },
    {
      condition = story_elapsed_check(5),
      action = function()
        game.players[1].print({"msg-escaped"})
      end
    },
    {
      condition = story_elapsed_check(5),
      action = function()
        game.players[1].print({"msg-enemy-1"})
      end,
    },
    {
      condition = story_elapsed_check(5),
      action = function()
        game.players[1].print({"msg-escape-1"})
      end
    },
    {
      condition = story_elapsed_check(5),
      action = function()
        game.players[1].print({"msg-build-plane-1"})
      end
    },
    {
      condition = story_elapsed_check(5),
      action = function()
        game.players[1].print({"msg-build-plane-2"})
      end
    },
    {
      condition = story_elapsed_check(5),
      action = function()
        game.players[1].print({"msg-oil-introduction"})
      end
    },
    {
      condition = story_elapsed_check(5),
      action = function()
        game.players[1].set_goal_description({"goal-research-oil-processing"})
      end
    },
    {
      condition =
      function(event)
        return event.name == defines.events.on_research_finished and
               event.research.name == "oil-processing"
      end,
    },
    {
      condition = story_elapsed_check(2),
      action =
      function()
        game.players[1].print({"msg-setup-oil-industry-1"})
      end
    },
    {
      condition = story_elapsed_check(5),
      action =
      function()
        game.players[1].print({"msg-setup-oil-industry-2"})
      end
    },
    {
      condition = story_elapsed_check(5),
      action =
      function()
        game.players[1].print({"msg-setup-oil-industry-3"})
      end
    },
    {
      condition = story_elapsed_check(5),
      action =
      function()
        game.players[1].force.recipes["small-plane"].enabled = true
        game.players[1].set_goal_description({"goal-build-small-plane"})
      end
    },
    {
      condition = story_elapsed_check(5),
      action =
      function()
        game.players[1].print({"msg-setup-oil-industry-4"})
      end
    },
    {
      condition = function() return game.players[1].get_item_count("small-plane") >= 1 end,
    },
    {
      condition = story_elapsed_check(2),
      action =
      function()
        game.players[1].print({"msg-finished"})
      end
    },
    {
      condition = story_elapsed_check(5),
      action =
      function()
        game.players[1].print({"msg-go-away"})
      end
    },
    {
      condition = story_elapsed_check(5),
    }
  }
}

story_init_helpers(story_table)

function on_win()
  game.players[1].set_ending_screen_data({"epilogue"}, "factorio-theme-3.png")
end

function difficulty_number(easy, normal, hard)
  if game.difficulty == defines.difficulty.easy then
    return easy
  elseif game.difficulty == defines.difficulty.normal then
    return normal
  else
    return hard
  end
end

init_attack_data = function()
  global.attack_data = {
    -- volatile data
    attack_count = difficulty_number(10, 15, 20),
    until_next_attack = difficulty_number(3600 * 20, 3600 * 15, 3600 * 10),
    -- persistent data
    attackspacing = difficulty_number(3600 * 15, 3600 * 10, 3600 * 7.5),
    attack_count_increase = difficulty_number(3, 6, 10),
    initialevolution = difficulty_number(0.05, 0.15, 0.25),
    evolutionincrease = difficulty_number(0.01, 0.02, 0.05),
  }
  global.evolution_factor = global.attack_data.initialevolution
end

function handle_attacks()
  global.attack_data.until_next_attack = global.attack_data.until_next_attack - 1
  if game.players[1].character and global.attack_data.until_next_attack <= 0 then
    game.evolution_factor = game.evolution_factor + global.attack_data.evolutionincrease
    if game.evolution_factor > 1 then
      game.evolution_factor = 1
    end
    local unitssent = game.players[1].surface.set_multi_command{command = {type=defines.command.attack,
                                                                       target=game.players[1].character,
                                                                       distraction=defines.distraction.enemy},
                                                            unit_count = global.attack_data.attack_count}
    global.attack_data.attack_count = global.attack_data.attack_count + global.attack_data.attack_count_increase
    global.attack_data.until_next_attack = global.attack_data.attackspacing
  end
end

script.on_event(defines.events, function(event)
  story_update(global.story, event, "", on_win)
  if event.name == defines.events.on_tick then
    handle_attacks()
  end
end)
