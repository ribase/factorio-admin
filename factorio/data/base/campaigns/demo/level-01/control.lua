require "util"
require "story"

script.on_init(function()
  global.story = story_init()
  game.disable_tips_and_tricks()
  game.players[1].disable_recipe_groups()
  game.players[1].disable_recipe_subgroups()
  game.players[1].minimap_enabled = false
  game.players[1].character.disable_flashlight()
  game.players[1].force.disable_all_prototypes() -- Only let the player have stuff we explicitly allowed
  game.players[1].force.disable_research()
  game.map_settings.pollution.enabled = false
  game.players[1].surface.daytime = 0.5

  global.starting_player_position = game.players[1].position

  local recipelist = game.players[1].force.recipes
  recipelist["iron-plate"].enabled = true
  recipelist["copper-plate"].enabled = true
  recipelist["iron-stick"].enabled = true
  recipelist["iron-axe"].enabled = true
  global.wreck = game.get_entity_by_tag("wreck")
end)

-- Definition of the level behaviour, it is used by the story module
story_table =
{
  -- Functions that can be registered to check something regardless of the position in the story
  ["update-functions"]=
  {
    ["check-furnace"]=
    function(event, story)
    if not global.furnace.valid then
        story_jump_to(story, "rebuild-accidentally-mined-furnace")
      end
    end,
    ["check-miner"]=
    function(event, story)
      if not global.miner.valid then
        if global.arrow ~= nil and global.arrow.valid then
          global.arrow.destroy()
        end
        story_jump_to(story, "rebuild-accidentally-mined-miner")
        return true
      elseif global.miner.drop_target ~= nil and global.arrow ~= nil and global.arrow.valid then
          global.arrow.destroy()
          game.players[1].clear_gui_arrow()
          story_jump_to(story, "wait-for-chest")
          return true
      elseif global.arrow ~= nil and global.arrow.valid then
          global.arrow.teleport(global.miner.drop_position)
      end
      return false
    end,
    ["check-chest"]=
    function(event, story)
    if not global.chest.valid then
        story_jump_to(story, "rebuild-accidentally-mined-chest")
      end
    end,
    ["check-that-iron-axe-is-buildable"]=
    function(event, story)
      if game.players[1].get_item_count("iron-plate") == 0 and game.players[1].get_item_count("iron-stick") >= 6 then
        game.players[1].insert{name="iron-plate", count=3}
        game.players[1].remove_item{name="iron-stick", count=6}
        game.show_message_dialog{text = {"more-iron"}}
      end
    end
  },
  -- The story contents
  {
    {
      update =
      function()
        game.players[1].surface.daytime = game.players[1].surface.daytime + 0.0004
      end,
      condition = function() return game.players[1].surface.darkness == 0 end,
      action = function() game.players[1].surface.always_day = true end
    },
    {
      condition = story_elapsed_check(1),
      action =
      function()
        game.players[1].print({"think-introduction"})
      end
    },
    {
      condition = story_elapsed_check(5),
      action =
      function()
        game.show_message_dialog{text={"msg-intro"}, point_to= {type = "entity", entity=game.players[1].character}}
      end,
    },
    {
      condition = story_elapsed_check(3),
      action =
      function()
        game.players[1].set_goal_description({"goal-intro"})
        game.show_message_dialog{text={"msg-goal-in-top-left"}, point_to={type = "goal"}}
      end
    },
    {
      condition = story_elapsed_check(4),
      action =
        function()
          game.players[1].set_goal_description("")
        end
    },
    {
      condition = story_elapsed_check(3),
      action =
      function()
        game.players[1].set_goal_description({"goal-movement"})
      end,
    },
    {
      condition = function() return util.distance(global.starting_player_position, game.players[1].position) > 5 end,
      action =
      function()
        game.players[1].set_goal_description("")
        if global.wreck.get_item_count("iron-plate") ~= 0 then
          game.players[1].print({"think-search-wreck"})
        end
      end,
    },
    {
      condition = story_elapsed_check(4) or global.wreck.get_item_count("iron-plate") == 0,
      action =
      function(event, story)
        if global.wreck.get_item_count("iron-plate") ~= 0 then
          game.players[1].set_goal_description({"goal-search-wreck"})
        else
          story_jump_to(story, "iron-axe-making")
        end
      end,
    },

    {
      condition = function() return global.wreck == game.players[1].opened end
    },
    {
      condition = story_elapsed_check(0.1),
      action =
      function()
        game.show_message_dialog{text={"msg-inventory-introduction"}, point_to= {type="active_window"}}
        game.players[1].set_goal_description("")
      end,
    },
    {
      condition = story_elapsed_check(0.1),
      action =
      function()
        if game.players[1].get_item_count("iron-plate") == 0 or
          (game.players[1].cursor_stack.valid_for_read and
           game.players[1].cursor_stack.count >= 8) then
           game.players[1].set_goal_description({"goal-take-iron-from-wreck"})
         end
      end
    },
    {
      condition =
      function()
        return game.players[1].get_item_count("iron-plate") == 8 and
        (game.players[1].cursor_stack.valid_for_read == false or
         game.players[1].cursor_stack.count < 8 or
         game.players[1].cursor_stack.name ~= "iron-plate")
      end,
      action =
      function()
        game.players[1].set_goal_description({"goal-close-screen"})
      end,
    },    {
      condition = story_elapsed_check(5) and function() return game.players[1].opened == nil end,
      action =
      function()
        game.players[1].set_goal_description("")
        game.players[1].print({"think-nothing-more"})
      end,
    },
    {
      name = "iron-axe-making",
      condition = story_elapsed_check(5),
      action =
      function(event, story)
        if game.players[1].get_item_count("iron-axe") == 0 then
          game.players[1].set_goal_description({"goal-open-character-screen-1"})
        else
          story_jump_to(story, "iron-ore-gathering")
        end
      end,
    },
    {
      condition = function() return game.players[1].opened_self end
    },
    {
      condition = story_elapsed_check(0.4),
      action =
      function()
        game.players[1].set_goal_description("")
        game.show_message_dialog{text={"msg-recipes-info-1"}, point_to= {type="active_window"}}
        game.show_message_dialog{text={"msg-recipes-info-2"}, point_to= {type="active_window"}}
        game.show_message_dialog{text={"msg-recipes-info-3"}, point_to= {type="active_window"}}
        game.players[1].set_goal_description({"goal-craft-iron-axe"})
      end,
    },
    {
      init = function(event, story) story_add_update(story, "check-that-iron-axe-is-buildable") end,
      condition =
      function(event, story)
        if game.players[1].get_item_count("iron-axe") > 0 then
          story_jump_to(story, "iron-ore-gathering")
          return false
        end
        return game.players[1].crafting_queue_size > 0
      end,
      action =
      function (event, story)
        game.show_message_dialog{text={"msg-crafting-queue-1"},
                               point_to={type = "crafting_queue",
                               crafting_queueindex = game.players[1].crafting_queue_size - 1}}
      end
    },
    {
      condition = function() return not game.players[1].get_inventory(defines.inventory.player_tools).is_empty() end,
      action =
      function(event, story)
        story_remove_update(story, "check-that-iron-axe-is-buildable")
        game.players[1].set_goal_description("")
        game.show_message_dialog{text={"msg-iron-axe-equipped"},
                               point_to={type = "item_stack",
                                        inventory_index = defines.inventory.player_tools,
                                        item_stack_index = 0,
                                        source="player"}}
      end
    },
    {
      condition = story_elapsed_check(2),
      action =
      function()
        if game.players[1].opened_self then game.players[1].set_goal_description({"goal-close-character-screen"}) end
      end,
    },
    {
      condition = function() return not game.players[1].opened_self end,
      action = function()
        game.players[1].set_goal_description("")
      end
    },
    {
      name = "iron-ore-gathering",
      condition = story_elapsed_check(3),
      action =

      function()
        game.players[1].print({"think-see-iron-ore"})
      end
    },
    {
      condition = story_elapsed_check(5),
      action = function()
        game.players[1].set_goal_description({"goal-mine-iron-ore"})
        game.players[1].set_gui_arrow({type="position", position={-15.5,-3.5}})
      end
    },
    {
      condition =
      function()
        local selectedentity = game.players[1].selected
        return selectedentity ~= nil and selectedentity.name == "iron-ore" and game.players[1].can_reach_entity(selectedentity)
      end
    },
    {
      -- this is to make sure the entity info actually exists
      condition = story_elapsed_check(0.05)
    },
    {
      condition =
      function()
        local selectedentity = game.players[1].selected
        return selectedentity ~= nil and selectedentity.name == "iron-ore" and game.players[1].can_reach_entity(selectedentity)
      end,
      action =
      function()
        game.players[1].clear_gui_arrow()
        game.show_message_dialog{text={"msg-entity-info"},
                               point_to={type = "entity_info"}}
      end
    },
    {
      update =
      (function()
        local only_update = false
        return function()
          local iron_ore_count = game.players[1].get_item_count("iron-ore")
          game.players[1].set_goal_description({"goal-mine-iron-ore-precise", iron_ore_count, 4}, only_update)
          only_update = true
        end
      end) (),
      condition =
      function()
        return game.players[1].get_item_count("iron-ore") >= 4
      end,
      action =
      function()
        game.players[1].set_goal_description("")
        game.players[1].print({"think-smelt-iron"})
      end
    },
    {
      condition = story_elapsed_check(5),
      action =
      function()
        game.players[1].set_goal_description({"goal-craft-furnace"})
        local recipelist = game.players[1].force.recipes
        recipelist["stone-brick"].enabled = true
        recipelist["stone-furnace"].enabled = true
      end
    },
    {
      condition =
      function()
        return game.players[1].get_item_count("stone-furnace") >= 1
      end,
      action =
      function()
        game.show_message_dialog{text={"msg-quickbar-introduction"},
                               point_to={type = "item_stack",
                               inventory_index = defines.inventory.player_quickbar,
                               item_stack_index = 0,
                               source="player"}}
      end
    },
    {
      action =
      function()
        game.players[1].set_goal_description({"goal-build-furnace"})
      end
    },
    {
      name = "wait-for-furnace",
      condition =
      function(event)
        if event.name == defines.events.on_built_entity and
          event.created_entity.name == "stone-furnace" then
          global.furnace = event.created_entity
          return true
        end
        return false
      end,
      action =
      function(event, story)
        game.players[1].set_goal_description({"goal-open-furnace"})
        story_add_update(story, "check-furnace")
      end
    },
    {
      condition =
      function()
        return game.players[1].opened ~= nil and
        game.players[1].opened.name == "stone-furnace"
      end,
      action =
      function()
        game.players[1].set_goal_description({"goal-insert-iron-into-furnace"})
      end
    },
    {
      condition =
      function()
        return global.furnace.get_item_count("iron-ore") > 0
      end,
      action =
      function()
        game.players[1].set_goal_description({"goal-insert-fuel-into-furnace"})
      end
    },
    {
      condition =
      function()
        return global.furnace.energy > 0 and
               -- furnace gui is opened
               ((game.players[1].opened and game.players[1].opened == global.furnace) or
               -- no gui is opened
                (not game.players[1].opened and not game.players[1].opened_self))
      end,
      action = function()
      if game.players[1].opened == global.furnace then
        game.show_message_dialog{text={"msg-furnace-working"},
                               point_to={type="active_window"}}
      else
        game.show_message_dialog{text={"msg-furnace-working"},
                               point_to={type="entity", entity=global.furnace}}
      end
      game.players[1].set_goal_description("")
      end,
    },
    {
      condition = story_elapsed_check(3),
      action =
      function()
        game.players[1].print({"think-furnace-useful"})
      end
    },
    {
      condition =
      function()
        return global.furnace.get_item_count("iron-plate") > 0  and
               global.furnace.get_item_count("iron-ore") == 0 or
               global.furnace.get_item_count("iron-plate") > 1
      end,
      action =
      function()
        game.players[1].set_goal_description({"goal-get-iron-plates-from-furnace"})
      end
    },
    {
      condition =
      function()
        return global.furnace.get_item_count("iron-plate") == 0
      end,
      action =
      function(event, story)
        story_remove_update(story, "check-furnace")
        game.players[1].set_goal_description("")
        game.players[1].print({"think-tired"})
      end
    },
    {
      condition = story_elapsed_check(5),
      action =
      function()
        game.players[1].set_goal_description({"goal-craft-burner-miner"})
        local recipelist = game.players[1].force.recipes
        recipelist["iron-gear-wheel"].enabled = true
        recipelist["burner-mining-drill"].enabled = true
      end
    },
    {
      condition =
      function()
        return game.players[1].get_item_count("burner-mining-drill") > 0
      end,
      action =
      function()
        game.players[1].set_goal_description({"goal-place-burner-miner"})
      end
    },
    {
      name = "wait-for-miner",
      condition =
        function(event)
          if event.name == defines.events.on_built_entity and
            event.created_entity.name == "burner-mining-drill" then
              global.miner = event.created_entity
              return true
          end
        return false
      end,
      action =
      function(event, story)
        game.players[1].set_goal_description({"goal-insert-fuel-into-burner-miner"})
        story_add_update(story, "check-miner")
      end
    },
    {
      condition = function() return global.miner.energy > 0 end,
      action =
      function(event, story)
        game.players[1].print({"think-burner-miner-working"})
        game.players[1].set_goal_description("")
        if global.miner.drop_target ~= nil then
          story_jump_to(story, "wait-for-chest")
        end
      end
    },
    {
      condition = story_elapsed_check(5),
      action =
      function()
        game.players[1].set_goal_description("")
        game.show_message_dialog{text={"msg-burner-miner-resources-placement"},
                               point_to={type="position", position=global.miner.drop_position}}
      end
    },
    {
      action =
      function()
        game.players[1].set_goal_description({"goal-pick-mined-item"})
        global.arrow = game.players[1].surface.create_entity{name="orange-arrow-with-circle", position = global.miner.drop_position}
      end
    },
    {
      condition =
        function(event) return event.name == defines.events.on_picked_up_item end,
      action =
      function()
          if global.arrow ~= nil and global.arrow.valid then
            global.arrow.destroy()
          end
          game.players[1].set_goal_description("")
          game.players[1].clear_gui_arrow()
          game.players[1].print({"think-storage-needed"})
      end
    },
    {
      condition = story_elapsed_check(5),
      action =
      function()
        game.players[1].set_goal_description({"goal-craft-chest"})
        local recipelist = game.players[1].force.recipes
        recipelist["wood"].enabled = true
        recipelist["wooden-chest"].enabled = true
      end
    },
    {
      condition =  function() return game.players[1].get_item_count("wooden-chest") > 0 end,
      action = function()
        game.players[1].set_goal_description({"goal-put-chest-below-burner-miner"})
      end
    },
    {
      name = "wait-for-chest",
      update = function()
        if not global.last_miner_drop_position or
           global.last_miner_drop_position.x ~= global.miner.drop_position.x or
           global.last_miner_drop_position.y ~= global.miner.drop_position.y then
           global.last_miner_drop_position = global.miner.drop_position
          game.players[1].set_gui_arrow({type="position", position=global.miner.drop_position})
        end
      end,
      condition = function() return global.miner.drop_target ~= nil end,
      action = function(event, story)
        global.chest = global.miner.drop_target
        game.players[1].set_goal_description("")
        game.players[1].clear_gui_arrow()
        game.show_message_dialog{text={"msg-resources-in-container", global.chest.localised_name},
                               point_to={type="entity", entity=global.miner.drop_target}}
        story_add_update(story, "check-chest")
      end
    },
    {
      action =
      function()
        global.original_count = count_items_in_container(global.chest)
        game.players[1].set_goal_description({"goal-collect-in-container",
                                        global.original_count + 2,
                                        global.chest.localised_name})
      end
    },
    {
      condition =  function()
        global.collected_count = count_items_in_container(global.chest)
        return global.collected_count >= global.original_count + 2
      end,
      action = function(event, story)
        game.players[1].set_goal_description({"goal-empty-container", global.chest.localised_name})
        story_remove_update(story, "check-miner")
      end
    },
    {
      condition =  function()
        local collected_count = count_items_in_container(global.chest)
        return global.collected_count >= 2 + collected_count
      end,
      action = function(event, story)
        story_remove_update(story, "check-chest")
        story_remove_update(story, "check-miner")
        game.players[1].print({"think-learned-something"})
        game.players[1].set_goal_description("")
      end
    },
    {
      condition = story_elapsed_check(5),
      action =
      function()
        game.players[1].print({"think-go-around"})
      end
    },
    {
      condition = story_elapsed_check(5)
    },
  },
  {
    {
      init = function(event, story) story_remove_update(story, "check-furnace") end,
      name = "rebuild-accidentally-mined-furnace",
      action =
      function()
        game.show_message_dialog{text={"msg-mined-furnace-instead-of-open"},
                                 point_to={type="entity", entity=game.players[1].character}}
      end
    },
    {
      action =
      function(event, story)
        story_jump_to(story, "wait-for-furnace")
      end,
    }
  },
  {
    {
      init =
      function(event, story)
        story_remove_update(story, "check-miner")
        story_remove_update(story, "check-chest")
      end,
      name = "rebuild-accidentally-mined-miner",
      action =
      function()
        game.players[1].clear_gui_arrow()
        game.show_message_dialog{text={"msg-mined-burner-miner-instead-of-open"},
                               point_to={type="entity", entity=game.players[1].character}}
      end
    },
    {
      action =
      function(event, story)
        story_jump_to(story, "wait-for-miner")
      end,
    }
  },
  {
    {
      action =
      function(event, story)
        game.players[1].set_goal_description({"goal-mine-burner-miner"})
      end,
    },
    {
      condition =
      function(event)
        return event.name == defines.events.on_player_mined_item and
               event.item_stack.name == "burner-mining-drill"
      end,
      action =
      function(event, story)
        story_jump_to(story, "wait-for-miner")
      end,
    }
  },
  {
    {
      init = function(event, story) story_remove_update(story, "check-chest") end,
      name = "rebuild-accidentally-mined-chest",
      action =
      function()
        game.show_message_dialog{text={"msg-mined-chest-instead-of-open"},
                               point_to={type="entity", entity=game.players[1].character}}
        local recipelist = game.players[1].force.recipes
        recipelist["wood"].enabled = true
        recipelist["wooden-chest"].enabled = true
      end
    },
    {
      action =
      function(event, story)
        story_jump_to(story, "wait-for-chest")
      end,
    }
  }
}

story_init_helpers(story_table)

function count_items_in_container(container)
  return container.get_item_count("coal") +
         container.get_item_count("iron-ore") +
         container.get_item_count("stone") +
         container.get_item_count("iron-plate") +
         container.get_item_count("stone-brick")
end

script.on_event(defines.events, function(event)
  story_update(global.story, event, "level-02")
end)
