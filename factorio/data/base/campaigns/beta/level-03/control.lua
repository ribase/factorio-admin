require "util"
require "story"

script.on_init(function()
  global.story = story_init()
  game.players[1].force.disable_all_prototypes()
  game.players[1].force.clear_chart()
  game.players[1].force.chart(game.players[1].surface,{{90,90},{100,100}})
  game.map_settings.enemy_expansion.enabled = false
  game.evolution_factor = 0.45
  game.map_settings.enemy_evolution.enabled = false
  game.players[1].surface.always_day = true

  local recipe_list = game.players[1].force.recipes
  recipe_list["iron-plate"].enabled = true
  recipe_list["copper-plate"].enabled = true
  recipe_list["stone-brick"].enabled = true
  recipe_list["stone-wall"].enabled = true
  recipe_list["wood"].enabled = true
  recipe_list["stone-furnace"].enabled = true
  recipe_list["iron-stick"].enabled = true
  recipe_list["iron-axe"].enabled = true
  recipe_list["wooden-chest"].enabled = true
  recipe_list["iron-gear-wheel"].enabled = true
  recipe_list["transport-belt"].enabled = true
  recipe_list["electronic-circuit"].enabled = true
  recipe_list["copper-cable"].enabled = true
  recipe_list["pistol"].enabled = true
  recipe_list["submachine-gun"].enabled = true
  recipe_list["firearm-magazine"].enabled = true
  recipe_list["electric-mining-drill"].enabled = true
  recipe_list["inserter"].enabled = true
  recipe_list["small-electric-pole"].enabled = true
  recipe_list["solar-panel"].enabled = true
  recipe_list["repair-pack"].enabled = true
  recipe_list["gate"].enabled = true

  local technologylist = game.players[1].force.technologies
  technologylist["steel-processing"].researched = true
  technologylist["optics"].researched = true
  technologylist["logistics"].researched = true
  technologylist["logistics-2"].researched = true
  technologylist["automation"].researched = true
  technologylist["automation-2"].researched = true
  technologylist["flame-thrower"].enabled = true
  technologylist["electronics"].researched = true
  technologylist["advanced-electronics"].researched = true
  technologylist["military"].researched = true
  technologylist["military-2"].researched = true
  technologylist["turrets"].researched = true
  technologylist["armor-making"].researched = true
  technologylist["bullet-damage-1"].researched = true
  technologylist["bullet-damage-2"].researched = true
  technologylist["bullet-speed-1"].researched = true
  technologylist["bullet-speed-2"].researched = true
  technologylist["gates"].researched = true

  local character = game.players[1].character
  character.insert{name = "grenade", count = 10}
  character.insert{name = "fast-transport-belt", count = 150}
  character.insert{name = "fast-inserter", count = 40}
  character.insert{name = "medium-electric-pole", count = 40}
  character.insert{name = "long-handed-inserter", count = 30}
  character.insert{name = "assembling-machine-2", count = 20}
  character.insert{name = "stone-wall", count = 150}
  character.insert{name = "gate", count = 20}
  character.insert{name = "small-lamp", count = 20}
  character.insert{name = "gun-turret", count = 15}
  character.insert{name = "steel-chest", count = 5}
  character.insert{name = "coal", count = 200}
  character.insert{name = "submachine-gun", count = 1}
  character.insert{name = "piercing-rounds-magazine", count = 100}
  character.insert{name = "steel-axe", count = 1}
  character.insert{name = "heavy-armor", count = 1}
  character.insert{name = "solar-panel", count = 50}
  character.insert{name = "repair-pack", count = 50}
  character.insert{name = "iron-plate", count = 500}
  character.insert{name = "copper-plate", count = 500}

  local car = game.get_entity_by_tag("car")
  car.insert{name = "piercing-rounds-magazine", count = 2000}
  car.insert{name = "iron-plate", count = 1500}
  car.insert{name = "copper-plate", count = 1500}
  car.insert{name = "steel-plate", count = 1000}
  car.insert{name = "coal", count = 1000}

  local techwreckage = game.get_entity_by_tag("tech-wreckage")
  techwreckage.insert{name = "explosives", count = 50}
  techwreckage.insert{name = "defender-capsule", count = 15}
  techwreckage.insert{name = "slowdown-capsule", count = 10}

  local bonus_wreckage = game.get_entity_by_tag("bonus-wreckage")
  bonus_wreckage.insert{name = "defender-capsule", count = 25}
  bonus_wreckage.insert{name = "rocket", count = 25}
end)

story_table =
{
  {
    {
      condition = story_elapsed_check(3),
      action =
      function()
        game.players[1].print({"msg-wreck-location"})
      end
    },
    {
      condition = story_elapsed_check(5),
      action =
      function()
        game.players[1].print({"msg-wreck-motivation"})
      end
    },
    {
      condition = story_elapsed_check(5),
      action =
      function()
        game.players[1].print({"msg-wreck-guarded"})
      end
    },
    {
      condition = story_elapsed_check(5),
      action =
      function()
        game.players[1].print({"msg-wrech-technology"})
      end
    },
    {
      condition = story_elapsed_check(5),
      action = function() game.show_message_dialog{text = {"msg-grenade"}} end
    },
    {
      condition = story_elapsed_check(2),
      init =
      function(event)
        game.players[1].set_goal_description({"goal-get-wreckage"})
        game.players[1].set_gui_arrow({type="entity", entity=game.get_entity_by_tag("tech-wreckage")})
      end,
    },
    {
      condition =
      function()
        local wreck = game.get_entity_by_tag("tech-wreckage")
        return game.get_entity_by_tag("tech-wreckage") == game.players[1].opened or
               not wreck.has_items_inside()
      end
    },
    {
      condition = story_elapsed_check(5),
      init =
      function(event)
        game.players[1].clear_gui_arrow()
        game.players[1].set_goal_description("")
        game.show_message_dialog{text = {"msg-could-make-more-1"}}
        game.show_message_dialog{text = {"msg-could-make-more-2"}}
        game.show_message_dialog{text = {"msg-could-make-more-3"}}
        local technologies = game.players[1].force.technologies
        technologies["battery"].researched = true
        technologies["rocketry"].researched = true
        technologies["combat-robotics"].researched = true
        technologies["follower-robot-count-1"].researched = true
        technologies["follower-robot-count-2"].researched = true
        technologies["follower-robot-count-3"].researched = true
        technologies["follower-robot-count-4"].researched = true
        technologies["follower-robot-count-5"].researched = true
        technologies["follower-robot-count-6"].researched = true
      end
    },
    {
      condition = story_elapsed_check(5),
      init =
      function(event)
        game.players[1].set_goal_description({"goal-get-computer"})
      end
    },
    {
      condition = function() return game.players[1].get_item_count("computer") > 0 end,
      action = function()
               game.players[1].print({"msg-got-it"})
             end,
    },
    {
      condition = story_elapsed_check(5)
    }
  }
}

story_init_helpers(story_table)

function difficulty_number(easy, normal, hard)
  if game.difficulty == defines.difficulty.easy then
    return easy
  elseif game.difficulty == defines.difficulty.normal then
    return normal
  else
    return hard
  end
end

function manage_attacks(tick)
  if global.last_attack_at == nil then
    global.last_attack_at = difficulty_number(120, 60, 0)
  end
  if global.attack_count == nil then
    global.attack_count = 3
  end
  -- attack rate is once per 90 seconds, it doesn't change
  if global.attackfrequency == nil then
    global.attackfrequency = difficulty_number(50, 40, 30)
  end
  if tick - global.last_attack_at > 60 * global.attackfrequency then
    global.last_attack_at = tick
    game.players[1].surface.set_multi_command{command = {type=defines.command.attack,
                                                     target=game.players[1].character,
                                                     distraction=defines.distraction.by_enemy},
                                          unit_count = global.attack_count}
    -- every attack is 0.6 aliens bigger
    global.attack_count = global.attack_count + 0.7
  end
end

script.on_event(defines.events, function(event)
  manage_attacks(event.tick)
  story_update(global.story, event, "level-04")
end)
