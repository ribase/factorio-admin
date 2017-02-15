require "util"
require "story"

script.on_init(function()
  global.story = story_init()
  game.players[1].disable_recipe_groups()
  game.players[1].disable_recipe_subgroups()
  game.players[1].minimap_enabled = false
  game.players[1].force.disable_all_prototypes()
  game.players[1].force.disable_research()
  game.map_settings.pollution.enabled = false
  game.map_settings.enemy_expansion.enabled = false
  game.evolution_factor = 0
  game.map_settings.enemy_evolution.enabled = false

  local recipe_list = game.players[1].force.recipes
  recipe_list["iron-plate"].enabled = true
  recipe_list["copper-plate"].enabled = true
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
  recipe_list["light-armor"].enabled = true

  local character = game.players[1].character
  character.insert{name = "iron-plate", count = 20}
  character.insert{name = "copper-plate", count = 15}
  character.insert{name = "coal", count = 20}
  character.insert{name = "transport-belt", count = 50}
  character.insert{name = "electric-mining-drill", count = 2}
  character.insert{name = "inserter", count = 10}
  character.insert{name = "stone-furnace", count = 10}
  character.insert{name = "pistol", count = 1}
  character.insert{name = "firearm-magazine", count = 20}
  character.insert{name = "iron-axe", count = 1}

  global.mining_drill = game.get_entity_by_tag("mining-drill")
  global.steam_engine = game.get_entity_by_tag("steam-engine")
  global.boiler1 = game.get_entity_by_tag("boiler1")
  global.boiler2 = game.get_entity_by_tag("boiler2")
  global.boiler3 = game.get_entity_by_tag("boiler3")
  global.introentities = {}
  entities = global.introentities
  entities[#entities + 1] = global.mining_drill
  entities[#entities + 1] = global.steam_engine
  entities[#entities + 1] = global.boiler1
  entities[#entities + 1] = global.boiler2
  entities[#entities + 1] = global.boiler3
  for index, entity in ipairs(entities) do
    entity.minable = false
    entity.destructible = false
  end
end)

story_table =
{
  {
    {
      condition = story_elapsed_check(3),
      action =
      function()
        game.players[1].print({"think-find-ship"})
      end
    },
    {
      condition = story_elapsed_check(5),
      action =
      function()
        game.players[1].print({"think-use-radar"})
      end
    },
    {
      condition = story_elapsed_check(5),
      action =
      function()
        game.players[1].print({"think-simple-setup"})
      end
    },
    {
     condition = story_elapsed_check(3),
     action =
     function()
      game.players[1].force.recipes["offshore-pump"].enabled = true
     end
    },
    {
     init =
     function()
       if global.pump == nil or not global.pump.valid then
         game.players[1].set_goal_description({"goal-build-pump"})
       else
         return true
       end
     end,
     condition =
     function(event)
        if event.name == defines.events.on_built_entity and
           event.created_entity.name == "offshore-pump" then
          return true
        end
        return false
      end
    },
    {
      condition = story_elapsed_check(1),
      action =
      function()
        if (not global.steam_engine.fluidbox[1] or
            global.steam_engine.fluidbox[1].amount < 0.01) then
          game.players[1].set_goal_description({"goal-connect-boiler-to-water"})
        end
      end,
    },
    {
      condition = function() return
        global.steam_engine.fluidbox[1] and
        global.steam_engine.fluidbox[1].amount > 0 end,
      action = function()
          game.players[1].set_goal_description("")
      end
    },
    {
      condition = story_elapsed_check(2),
      action = function()
        if (global.steam_engine.energy <= 0.1) then
          game.show_message_dialog{text={"msg-cold-water"},
                                 point_to={type="entity", entity=global.steam_engine}}
        end
      end
    },
    {
      condition = story_elapsed_check(3),
      init=
      function()
        if (global.steam_engine.energy <= 0.1) then
          game.players[1].set_goal_description({"goal-fuel-into-boiler"})
        end
      end,
    },
    {
      condition = function() return global.steam_engine.energy > 0.1 end,
      action = function()
          game.players[1].set_goal_description("")
      end
    },
    {
      condition = story_elapsed_check(3),
      action = function() end
    },
    {
      condition = function() return not game.players[1].opened end,
      action =
      function()
        game.show_message_dialog{text={"msg-electricity-setup"},
                               point_to={type="entity", entity=global.steam_engine}}
        game.show_message_dialog{text={"msg-steam-engine-effectivity"},
                               point_to={type="entity", entity=global.steam_engine}}
        game.show_message_dialog{text={"msg-steam-engine-introduction-1"},
                               image="steam-engine-setup-1.png",
                               point_to={type="entity", entity=global.steam_engine}}
        game.show_message_dialog{text={"msg-steam-engine-introduction-2"},
                               image="steam-engine-setup-2.png",
                               point_to={type="entity", entity=global.steam_engine}}
      end
    },
    {
      condition = story_elapsed_check(3),
      action =
      function()
        local recipe_list = game.players[1].force.recipes
        recipe_list["small-electric-pole"].enabled = true
        recipe_list["electric-mining-drill"].enabled = true
        recipe_list["inserter"].enabled = true
        game.players[1].set_goal_description({"goal-power-electric-mining-drill"})
      end
    },
    {
      condition = function() return global.mining_drill.energy > 0 end,
      action =
      function()
        game.players[1].set_goal_description("")
      end
    },
    {
      condition = story_elapsed_check(3),
      action =
      function()
        game.players[1].print({"think-piece-of-cake"})
      end
    },

    {
      condition = story_elapsed_check(7),
      action =
      function()
        game.show_message_dialog{text = {"msg-factory-instruction-1"}}
        for index, entity in ipairs(global.introentities) do
          entity.minable = true
          entity.destructible = true
        end
        local recipe_list = game.players[1].force.recipes
        recipe_list["assembling-machine-1"].enabled = true
      end
    },
    {
      action =
      function()
        game.show_message_dialog{text = {"msg-factory-instruction-2"}}
        game.show_message_dialog{text = {"msg-factory-instruction-3"}}
      end
    },
    {
      action =
      function()
        game.players[1].print({"think-get-to-work"})
      end
    },
    {
      condition = story_elapsed_check(5),
      action =
      function()
        game.players[1].print({"think-beware-of-creepers"})
      end
    },
    {
      update =
      (function()
        local onlyupdate = false
        return function(event)
          local ironplatecount = game.players[1].character.get_item_count("iron-plate")
          local copperplatecount = game.players[1].character.get_item_count("copper-plate")
          game.players[1].set_goal_description({"goal-get-resources",
                                          ironplatecount,
                                          75,
                                          copperplatecount,
                                          30},
                                         onlyupdate)
          onlyupdate = true
        end
      end) (),
      condition =
      function()
        return game.players[1].character.get_item_count("iron-plate") >= 75 and
               game.players[1].character.get_item_count("copper-plate") >= 30
      end,
      action =
      function()
        game.players[1].print({"think-resources-collected"})
        game.players[1].set_goal_description("")
      end
    },
    {
      condition = story_elapsed_check(5),
      action =
      function()
        game.show_message_dialog{text = {"msg-start-with-radars-1"}}
        game.show_message_dialog{text = {"msg-start-with-radars-2"}}
      end
    },
    {
      action = function()
        if global.gun_turret_gained == nil then
          global.gun_turret_gained = true
          game.players[1].force.recipes["gun-turret"].enabled = true
        end
        game.show_message_dialog{text = {"msg-protect-radars"}}
      end
    },
    {
      condition = story_elapsed_check(5),
      action =
      function()
        global.sectors_scanned = 0;
        local recipe_list = game.players[1].force.recipes
        recipe_list["radar"].enabled = true
      end
    },
    {
      update =
      (function()
        local first_run = true
        return function(event)
          scanned = (event.name == defines.events.on_sector_scanned)
          if scanned then
            global.sectors_scanned = global.sectors_scanned + 1
          end
          if first_run or scanned then
            game.players[1].set_goal_description({"goal-radar-progress",
                                            global.sectors_scanned,
                                            50})
          end
          first_run = false
        end
      end)(),
      condition =
      function()
        return global.sectors_scanned >= 50
      end,
      action =
      function()
        game.show_message_dialog{text = {"msg-sector-scan-completed"}}
        game.show_message_dialog{text = {"msg-ship-wreck-located"}}
      end
    },
    {
      condition = story_elapsed_check(5),
      action =
      function()
        game.players[1].print({"think-explore-ship-wreck"})
      end
    },
    {
      condition = story_elapsed_check(5),
      action =
      function()
      end
    }
  }
}

story_init_helpers(story_table)

function manage_attacks(tick)
  -- set default value of last_attack_at, it contains tick of the last attack
  if global.last_attack_at == nil then
    global.last_attack_at = 0
  end
  -- set default value of attack count
  if global.attack_count == nil then
    global.attack_count = 2
  end
  -- set default of attack_frequency, it specifies how many seconds between attacks
  if global.attack_frequency == nil then
    global.attack_frequency = 180
  end
  if tick - global.last_attack_at > 60 * global.attack_frequency then
    global.last_attack_at = tick
    game.players[1].surface.set_multi_command{command = {type=defines.command.attack,
                                                     target=game.players[1].character,
                                                     distraction=defines.distraction.by_enemy},
                                          unit_count = global.attack_count}
    global.attack_count = global.attack_count + 0.49

    -- Give the player submachine gun when 3 creepers start to attack
    if global.attack_count > 3 and global.submachine_gained == nil then
      global.submachine_gained = true
      game.show_message_dialog{text = {"msg-need-better-weapon"}}
      local recipe_list = game.players[1].force.recipes
      recipe_list["submachine-gun"].enabled = true
      return
    end

    -- Give the player turret when 4 creepers start to attack
    if global.attack_count > 4 and global.gun_turret_gained == nil then
     global.gun_turret_gained = true
      game.show_message_dialog{text = {"msg-need-better-defense"}}
      local recipe_list = game.players[1].force.recipes
      recipe_list["gun-turret"].enabled = true
    end
  end
end

-- Gives lamp to the player when it gets dark
function check_light()
  if game.surfaces['nauvis'].darkness > 0.5 and
     global.lampallowed == nil then
    global.lampallowed = true
    game.show_message_dialog{text = {"msg-need-light"}}
    local recipe_list = game.players[1].force.recipes
    recipe_list["small-lamp"].enabled = true
  end
end

function check_machine_gun()
  if global.submachine_gained and
     global.submachine_built == nil and
     game.players[1].character.get_item_count("submachine-gun") > 0 then
    global.submachine_built = true
    game.show_message_dialog{text = {"msg-active-gun"}}
    return
  end

  if global.submachine_built and
     global.submachine_equipped == nil and
     game.players[1].character.get_inventory(defines.inventory.player_guns).get_item_count("submachine-gun") > 0 then
    global.submachine_equipped = true
    game.show_message_dialog{text = {"msg-change-active-gun"}}
  end
end

function on_win()
  local epilogue_key
  if game.is_demo() then
    epilogue_key = "epilogue"
  else
    epilogue_key = "epilogue-no-demo"
  end
  game.players[1].set_ending_screen_data({epilogue_key}, "factorio-theme-2.png")
end

script.on_event(defines.events, function(event)
  if game.players[1].character then
    manage_attacks(event.tick)
    check_light()
    check_machine_gun()
    story_update(global.story, event, "", on_win)
  end
end)
