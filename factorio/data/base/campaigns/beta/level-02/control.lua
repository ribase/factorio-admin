require "util"
require "story"

function check_supplies(name, count)
  local has = game.players[1].get_item_count(name)
  if game.players[1].vehicle ~= nil then
    has = has + game.players[1].vehicle.get_item_count(name)
  end
  game.players[1].gui.left.objectives.table.add{type="label", caption=game.item_prototypes[name].localised_name}
  if has < count then
    local label = game.players[1].gui.left.objectives.table.add{type="label", caption=has .. "/" .. count}
    label.style.font_color = {r = 1, g = 0.2, b = 0.2}
  else
    local label = game.players[1].gui.left.objectives.table.add{type="label", caption=count .. "/" .. count, style="caption_label_style"}
    label.style.font_color = {r = 0.3, g = 0.9, b = 0.3}
  end
  return  has >= count
end

script.on_init(function()
  global.story = story_init()
  game.players[1].force.reset_recipes() --Fix some 0.12->0.13 migration issue
  game.players[1].force.disable_all_prototypes()
  game.map_settings.enemy_expansion.enabled = false
  game.evolution_factor = 0
  game.map_settings.enemy_evolution.enabled = false
  local recipe_list = game.players[1].force.recipes
  recipe_list["iron-plate"].enabled = true
  recipe_list["copper-plate"].enabled = true
  recipe_list["stone-brick"].enabled = true
  recipe_list["wood"].enabled = true
  recipe_list["stone-furnace"].enabled = true
  recipe_list["iron-stick"].enabled = true
  recipe_list["iron-axe"].enabled = true
  recipe_list["wooden-chest"].enabled = true
  recipe_list["iron-gear-wheel"].enabled = true
  recipe_list["burner-mining-drill"].enabled = true
  recipe_list["transport-belt"].enabled = true
  recipe_list["burner-inserter"].enabled = true
  recipe_list["pipe"].enabled = true
  recipe_list["pipe-to-ground"].enabled = true
  recipe_list["boiler"].enabled = true
  recipe_list["steam-engine"].enabled = true
  recipe_list["electronic-circuit"].enabled = true
  recipe_list["copper-cable"].enabled = true
  recipe_list["pistol"].enabled = true
  recipe_list["firearm-magazine"].enabled = true
  recipe_list["offshore-pump"].enabled = true
  recipe_list["small-electric-pole"].enabled = true
  recipe_list["electric-mining-drill"].enabled = true
  recipe_list["inserter"].enabled = true
  recipe_list["radar"].enabled = true
  recipe_list["lab"].enabled = true
  recipe_list["science-pack-1"].enabled = true
  recipe_list["science-pack-2"].enabled = true
  recipe_list["stone-wall"].enabled = true
  recipe_list["repair-pack"].enabled = true

  local technologies = game.players[1].force.technologies
  technologies["automation"].researched = true
  technologies["logistics"].researched = true
  technologies["logistics-2"].enabled = true
  technologies["automobilism"].researched = true
  technologies["military"].researched = true
  technologies["military-2"].enabled = true
  technologies["optics"].researched = true
  technologies["steel-processing"].researched = true
  technologies["automation-2"].enabled = true
  technologies["turrets"].researched = true
  technologies["armor-making"].enabled = true
  technologies["armor-making-2"].enabled = true
  technologies["railway"].enabled = true
  technologies["automated-rail-transportation"].enabled = true
  technologies["electric-energy-distribution-1"].enabled = true
  technologies["bullet-damage-1"].researched = true
  technologies["bullet-damage-2"].enabled = true
  technologies["bullet-damage-3"].enabled = true
  technologies["bullet-speed-1"].researched = true
  technologies["bullet-speed-2"].enabled = true
  technologies["bullet-speed-3"].enabled = true
  technologies["advanced-material-processing"].enabled = true
  technologies["electronics"].enabled = true
  technologies["solar-energy"].enabled = true
  technologies["engine"].enabled = true
  technologies["rail-signals"].enabled = true
  technologies["advanced-electronics"].enabled = true
  technologies["stone-walls"].researched = true
  technologies["gates"].enabled = true

  local character = game.players[1].character
  character.insert{name = "iron-plate", count = 200}
  character.insert{name = "copper-plate", count = 100}
  character.insert{name = "coal", count = 40}
  character.insert{name = "small-lamp", count = 20}
  character.insert{name = "transport-belt", count = 50}
  character.insert{name = "inserter", count = 20}
  character.insert{name = "small-electric-pole", count = 20}
  character.insert{name = "long-handed-inserter", count = 10}
  character.insert{name = "electric-mining-drill", count = 5}
  character.insert{name = "submachine-gun", count = 1}
  character.insert{name = "firearm-magazine", count = 20}
  character.insert{name = "iron-axe", count = 1}
  character.insert{name = "electronic-circuit", count = 100}
  character.insert{name = "assembling-machine-1", count = 10}
  character.insert{name = "lab", count = 5}
  character.insert{name = "stone", count = 200}
  character.insert{name = "raw-wood", count = 50}
  character.insert{name = "iron-gear-wheel", count = 50}
  character.insert{name = "pipe", count = 40}
end)

story_table =
{
  {
    {
      action =
      function()
        game.players[1].set_goal_description("")
        game.show_message_dialog{text = {"msg-came-too-late"}}
        game.show_message_dialog{text = {"msg-everyone-dead"}}
        game.show_message_dialog{text = {"msg-biters-are-dangerous"}}
        game.show_message_dialog{text = {"msg-recover-base"}}
        game.show_message_dialog{text = {"msg-rails"}}
      end
    },
    {
      condition = story_elapsed_check(3),
      action =
      function()
        game.players[1].set_goal_description({"goal-recover-base-and-research-railway"})
      end
    },
    {
      condition =
      function(event)
        return event.name == defines.events.on_research_finished and
               event.research.name == "automated-rail-transportation"
      end,
      action =
      function()
        game.players[1].set_goal_description("")
        game.players[1].print({"think-recover-railway"})
      end
    },
    {
      condition = story_elapsed_check(6),
      action =
      function()
        game.players[1].set_goal_description({"goal-get-supplies"})
        game.players[1].set_goal_description("")
      end
    },
    {
      init =
      function()
        local objectives = game.players[1].gui.left.add{type="frame", name="objectives", caption = {"goal-title"}, direction = "vertical"}
        objectives.add{type="label", caption = {"goal-get-supplies"}}
        objectives.add{type="label", caption = {"car-contents-counting-logic"}}
        objectives.add{type="table", colspan=2, name="table"}
      end,
      condition =
      function()
        local result = true
        game.players[1].gui.left.objectives.table.destroy()
        game.players[1].gui.left.objectives.add{type="table", colspan=2, name="table"}
        result = check_supplies("piercing-rounds-magazine", 2500) and result
        result = check_supplies("steel-plate", 1500) and result
        result = check_supplies("iron-plate", 3000) and result
        result = check_supplies("copper-plate", 3000) and result
        result = check_supplies("solar-panel", 50) and result
        return result
      end,
      action =
      function()
        game.players[1].set_goal_description("")
        game.show_message_dialog{text = {"msg-ready-to-go"}}
      end
    },
    {}
  }
}

story_init_helpers(story_table)

script.on_event(defines.events, function(event)
  story_update(global.story, event, "level-03")
end)

