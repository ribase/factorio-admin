require "util"
require "story"

script.on_init(function()
  global.story = story_init()
  game.disable_tips_and_tricks()
  game.players[1].disable_recipe_groups()
  game.players[1].disable_recipe_subgroups()
  game.players[1].minimap_enabled = false
  game.players[1].force.disable_all_prototypes()
  game.players[1].force.disable_research()
  game.players[1].surface.always_day = true -- Don't bother the player with night in this early mission
  game.map_settings.pollution.enabled = false

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
  game.players[1].character.insert{name = "iron-axe", count = 1}
  game.players[1].character.insert{name = "coal", count = 20}
  global.inserter_chest = game.get_entity_by_tag("inserter-chest")
  assert(global.inserter_chest)
  global.inserter_chestposition = global.inserter_chest.position

  global.inserter_furnace = game.get_entity_by_tag("inserter-furnace")
  assert(global.inserter_furnace)
  global.inserter_furnace_position = global.inserter_furnace.position
end)

story_table =
{
  ["update-functions"]=
  {
   ["check-inserter-1"]=
   function(event, story)
     if not global.inserter_chest.valid then
       story_jump_to(story, "build-the-accidentally-mined-inserter")
     end
   end,
   ["check-inserter-2"]=
   function(event, story)
     if not global.inserter_furnace.valid then
       story_jump_to(story, "build-the-accidentally-mined-inserter-2")
     end
   end
  },
  {
    {
      init = function(event, story) story_add_update(story, "check-inserter-1") end,
      condition = story_elapsed_check(3),
      action = function()
        game.players[1].print({"think-found-mining-site"})
      end
    },
    {
      condition = story_elapsed_check(4),
      action = function()
        game.players[1].print({"think-robotic-arm"})
      end
    },
    {
      condition = story_elapsed_check(4.6),
      action =
      function()
         game.show_message_dialog{text={"msg-inserter-no-power"},
                                point_to={type="entity", entity=global.inserter_chest}}
      end
    },
    {
      condition = story_elapsed_check(1),
      action =
      function()
        game.players[1].set_goal_description({"goal-open-machine-gui"})
        game.players[1].set_gui_arrow({type="entity", entity=global.inserter_chest})
      end
    },
    {
      name = "wait-to-open-inserter-1",
      condition = function() return global.inserter_chest == game.players[1].opened end,
      action =
      function()
        game.players[1].set_goal_description({"goal-insert-fuel-into-inserter-1"})
        game.players[1].clear_gui_arrow()
      end,
    },
    {
      condition = function() return global.inserter_chest.energy > 0 end,
      action =
      function()
        game.players[1].set_goal_description("")
        if game.players[1].opened == global.inserter_chest then
          game.show_message_dialog{text={"msg-inserter-introduction-1"},
                                 image = "inserter-explanation.png",
                                 point_to={type="active_window"}}
        else
          game.show_message_dialog{text={"msg-inserter-introduction-1"},
                                 image = "inserter-explanation.png",
                                 point_to={type="entity", entity=global.inserter_chest}}
        end
      end
    },
    {
      action =
      function(event, story)
        if game.players[1].opened == global.inserter_chest then
          game.show_message_dialog{text={"msg-inserter-introduction-2"},
                                 image = "inserter-usage-explanation.png",
                                 point_to={type="active_window"}}
        else
          game.show_message_dialog{text={"msg-inserter-introduction-2"},
                                 image = "inserter-usage-explanation.png",
                                 point_to={type="entity", entity=global.inserter_chest}}
        end
        story_remove_update(story, "check-inserter-1")
      end
    },
    {
      condition = story_elapsed_check(5),
      action = function()
        game.players[1].set_goal_description({"goal-inspect-chest"})
      end
    },
    {
      condition = function() return game.players[1].character.get_item_count("pistol") > 0 and
                                    game.players[1].character.get_item_count("firearm-magazine") > 0 end,
      action = function()
        game.players[1].print({"think-chest-content-useful"})
        game.players[1].set_goal_description("")
      end
    },
    {
      condition = story_elapsed_check(2),
      action = function()
        if game.players[1].character.get_inventory(defines.inventory.player_guns).get_item_count("pistol") == 0 then
          game.show_message_dialog{text={"msg-gun-equipment"},
                                 point_to={type = "item_stack",
                                          inventory_index = defines.inventory.player_guns,
                                          item_stack_index = 0,
                                          source="player"}}
        end
      end
    },
    {
      condition = story_elapsed_check(0.5),
      action = function()
        if game.players[1].character.get_inventory(defines.inventory.player_guns).get_item_count("pistol") == 0 then
          game.players[1].set_goal_description({"goal-equip-gun"})
          game.players[1].set_gui_arrow{type = "item_stack", inventory_index = defines.inventory.player_guns, item_stack_index = 0, source="player"}
        end
      end
    },
    {
      condition = function() return game.players[1].character.get_inventory(defines.inventory.player_guns).get_item_count("pistol") > 0 end,
      action = function()
        if game.players[1].character.get_inventory(defines.inventory.player_ammo).get_item_count("firearm-magazine") == 0 then
          game.players[1].set_goal_description({"goal-equip-ammo"})
          game.players[1].set_gui_arrow{type = "item_stack", inventory_index = defines.inventory.player_ammo, item_stack_index = 0, source="player"}
        end
      end
    },
    {
      condition = function() return game.players[1].character.get_inventory(defines.inventory.player_ammo).get_item_count("firearm-magazine") > 0 end,
      action = function()
        game.players[1].set_goal_description("")
        game.players[1].character.clear_gui_arrow()
        game.players[1].surface.set_multi_command{command= {type=defines.command.attack,
                                                        target=game.players[1].character,
                                                        distraction=defines.distraction.none},
                                              unit_count = 2}
      end
    },
    {
      condition = story_elapsed_check(2),
      action =
      function()
        game.players[1].print({"think-creepers-coming"})
        game.players[1].character.clear_gui_arrow()
      end
    },
    {
      condition = story_elapsed_check(3),
      action = function()
        game.show_message_dialog{text={"msg-shooting"},
                                 point_to={type="entity", entity=game.players[1].character}}
        global.creeperskilled = 0
      end
    },
    {
      condition = story_elapsed_check(1.5),
      action = function()
        game.players[1].set_goal_description({"kill-creepers"})
      end
    },
    {
      update =
      function(event)
        if event.name == defines.events.on_entity_died and
           event.entity.name == "small-biter" then
          global.creeperskilled = global.creeperskilled + 1
        end
      end,
      condition = function() return global.creeperskilled >= 2 end,
      action = function()
        game.players[1].set_goal_description("")
        game.players[1].print({"think-creepers-dead"})
      end
    },
    {
      condition = story_elapsed_check(3),
      action = function()
        game.players[1].set_goal_description("")
        game.players[1].print({"think-prepare"})
      end
    },
    {
      init = function(event, story) story_add_update(story, "check-inserter-2") end,
      condition = story_elapsed_check(5),
      action = function()
        game.show_message_dialog{text={"msg-inserter-2-reversed"},
                               point_to={type="entity", entity=global.inserter_furnace}}
      end
    },
    {
      condition = story_elapsed_check(0.5),
      action =
      function()
        game.players[1].set_gui_arrow({type="entity", entity=global.inserter_furnace})
        game.players[1].set_goal_description({"goal-rotate-inserter-2"})
      end
    },
    {
      name = "wait-to-rotate-inserter-2",
      condition =
        function()
          return global.inserter_furnace.drop_target ~= nil and
                 global.inserter_furnace.drop_target.name == "stone-furnace"
        end,
      action =
      function(event, story)
        game.players[1].set_goal_description("")
        game.players[1].clear_gui_arrow()
        game.players[1].print({"think-inserter2-working"})
        story_remove_update(story, "check-inserter-2")
      end
    },
    {
      condition = story_elapsed_check(3),
      action =
      function()
        game.players[1].clear_gui_arrow()
        game.show_message_dialog{text={"msg-rotations-explained"},
                               point_to={type="entity", entity=game.players[1].character}}
      end
    },
    {
      condition = story_elapsed_check(3),
      action =
      function()
      game.players[1].print({"think-need-more-machines"})
      end
    },
    {
      condition = story_elapsed_check(4),
    },
    {
      init = function() global.mined_stone_count = 0 end,
      condition = story_elapsed_check(4),
      update =
      (function()
        local only_update = false
        return function(event)
          progress = event.name == defines.events.on_built_entity and
                     (event.created_entity.name == "burner-mining-drill" or
                      event.created_entity.name == "stone-furnace")
          if event.name == defines.events.on_player_mined_item and
             event.item_stack.name == "stone" then
             global.mined_stone_count = global.mined_stone_count + 1
          end
          if global.mined_stone_count >= 5 and global.advicetominestone == nil then
             game.show_message_dialog{text={"hint-to-automated-stone-mining"},
                                    point_to={type="entity", entity=game.players[1].character}}
             global.advicetominestone = true
          end

            game.players[1].set_goal_description({"goal-build-machines",
                                            game.players[1].force.get_entity_count("burner-mining-drill"),
                                            10,
                                            game.players[1].force.get_entity_count("stone-furnace"),
                                            5},
                                           only_update and not progress)
          only_update = true
        end
      end) (),
      condition =
      function()
        return game.players[1].force.get_entity_count("burner-mining-drill") >= 10 and
               game.players[1].force.get_entity_count("stone-furnace") >= 5
      end,
      action =
      function()
        game.players[1].print({"think-got-machines"})
        game.players[1].set_goal_description("")
      end
    },
    {
      condition = story_elapsed_check(5),
      action =
      function()
      game.players[1].print({"think-need-more-resources"})
      end
    },
    {
      update =
      (function()
        local only_update = false
        return function(event)
          local iron_plate_count = game.players[1].character.get_item_count("iron-plate")
          local copperplatecount = game.players[1].character.get_item_count("copper-plate")
          local coal_count = game.players[1].character.get_item_count("coal")
          game.players[1].set_goal_description({"goal-get-resources",
                                          iron_plate_count,
                                          150,
                                          copperplatecount,
                                          50,
                                          coal_count,
                                          75},
                                        only_update)
          only_update = true
        end
      end) (),
      condition =
      function()
        return game.players[1].character.get_item_count("iron-plate") >= 150 and
               game.players[1].character.get_item_count("copper-plate") >= 50 and
               game.players[1].character.get_item_count("coal") >= 75
      end,
      action =
      function()
        game.players[1].print({"think-got-resources-1"})
        game.players[1].set_goal_description("")
      end
    },
    {
      condition = story_elapsed_check(5),
      action = function()
        game.players[1].print({"think-time-to-move-on"})
      end
    },
    {
      condition = story_elapsed_check(5),
    },
  },
  {
    {
     name = "build-the-accidentally-mined-inserter",
     init =
     function(event, story)
       story_remove_update(story, "check-inserter-1")
     end,
     action =
     function()
       game.show_message_dialog{text={"msg-mined-inserter-instead-of-open"},
                                point_to={type="position", position=global.inserter_chestposition}}
     end
    },
    {
      action =
      function()
        game.players[1].set_goal_description({"goal-build-inserter-back"})
      end,
    },
    {
      condition =
      function(event)
        if event.name == defines.events.on_built_entity and
           event.created_entity.name == "burner-inserter" then
          if not table.compare(event.created_entity.position, global.inserter_chestposition) then
          game.show_message_dialog{text={"msg-inserter-1-wrong-position"},
                                 point_to={type="entity", entity=event.created_entity}}
          return false
          end
          global.inserter_chest = event.created_entity
          return true
        end
      end,
      action =
      function(event, story)
        story_jump_to(story, "wait-to-open-inserter-1")
        story_add_update(story, "check-inserter-1")
      end,
    }
  },
  {
    {
     name = "build-the-accidentally-mined-inserter-2",
     init =
     function(event, story)
       story_remove_update(story, "check-inserter-2")
     end,
     action =
     function()
       game.show_message_dialog{text={"msg-mined-inserter-instead-of-open"},
                                point_to={type="position", position=global.inserter_furnace_position}}
     end
    },
    {
      action =
      function()
        game.players[1].set_goal_description({"goal-build-inserter-back"})
      end,
    },
    {
      condition =
      function(event)
        if event.name == defines.events.on_built_entity and
           event.created_entity.name == "burner-inserter" then
          if not table.compare(event.created_entity.position, global.inserter_furnace_position) then
          game.players[1].print("Inserter built on wrong position")
          return false
          end
          global.inserter_furnace = event.created_entity
          return true
        end
      end,
      action =
      function(event, story)
        story_jump_to(story, "wait-to-rotate-inserter-2")
        story_add_update(story, "check-inserter-2")
      end,
    }
  }
}

story_init_helpers(story_table)

script.on_event(defines.events, function(event)
  if game.players[1].character then
    story_update(global.story, event, "level-03")
  end
end)
