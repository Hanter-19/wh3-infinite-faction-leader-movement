local infinite_movement = true;

core:add_ui_created_callback(    
    function()
        if cm:is_new_game() and cm:get_saved_value("hanter_log_refresh") then
            return;
        end

        cm:set_saved_value("hanter_log_refresh", true);

        if not __write_output_to_logfile then
            return;
        end

        local logTimeStamp = os.date("%Y-%m-%d %X");

        local popLog = io.open("hanter_log.txt","w+");
        popLog:write("NEW LOG ["..logTimeStamp.."]\n");
        popLog:flush();
        popLog:close();
    end
);

hanter_iflm = {};

hanter_iflm.logger = {

    log = function(filename,text)
        if not __write_output_to_logfile then
            return;
        end
    
        local logTimeStamp = "["..os.date("%Y-%m-%d %X").."]";
        local logContext = "[IFLM]";
        local logFilename = "["..tostring(filename).."]";
        local logText = " "..tostring(text);
        local popLog = io.open("hanter_log.txt","a");
    
        popLog:write(logTimeStamp..logContext..logFilename..logText.."\n");
        popLog:flush();
        popLog:close();
    end,

    tostring_square_brackets = function(str)
        return "["..tostring(str).."]";
    end,

    -- Produce pretty string for any given string str and its cqi
    tostring_str_and_cqi = function(str,cqi)
        return "["..tostring(str).." | cqi="..tostring(cqi).."]";
    end,

    -- Produce pretty string for x-y coordinates
    tostring_coords = function(x,y)
        return "["..tostring(x)..","..tostring(y).."]";
    end,

    -- Produce pretty string for a character name and their cqi
    tostring_character_name_and_cqi = function(cqi)
        local char = cm:get_character_by_cqi(cqi);
        local name = common.get_localised_string(char:get_forename()).." "..common.get_localised_string(char:get_surname());
        return hanter_iflm.logger.tostring_str_and_cqi(name,cqi);
    end,

    tostring_region_province_coords = function(region,region_cqi,province,x,y)
        return "["..tostring(region).." | cqi="..tostring(region_cqi).."]["..province.."]"..hanter_iflm.logger.tostring_coords(x,y);
    end,

    tostring_region_province_coords_display = function(region,region_cqi,province,x,y,d_x,d_y)
        return "["..tostring(region).." | cqi="..tostring(region_cqi).."]["..province.."]"..hanter_iflm.logger.tostring_coords(x,y)..hanter_iflm.logger.tostring_coords(d_x,d_y);
    end,

    log_cqi_movement = function(cqi)
        local char = cm:get_character_by_cqi(cqi);
        local name_str = hanter_iflm.logger.tostring_character_name_and_cqi(cqi);
        
        local region_key = char:region():name();
        local region_cqi = char:region():cqi();
        local province_str = char:region():province():key();
        
        local l_x = char:logical_position_x();
        local l_y = char:logical_position_y();
    
        local d_x = char:display_position_x();
        local d_y = char:display_position_y();

        local location_str = hanter_iflm.logger.tostring_region_province_coords_display(region_key,region_cqi,province_str,l_x,l_y,d_x,d_y);

        hanter_iflm.logger.log("hanter_iflm.lua",name_str.." has moved to "..location_str);
    end

}



cm:add_first_tick_callback(
    function()
        -- Setup a recursive movement listener for player faction leader
        for i, faction_key in pairs(cm:get_human_factions()) do
            
            local cqi = cm:get_faction(faction_key):faction_leader():command_queue_index();

            -- setup the one time movement notifier for the faction leader that will trigger a recursive custom event
            cm:notify_on_character_halt(
                cqi,
                function()
                    core:trigger_custom_event("ScriptEventCQIFinishedMoving",{["cqi"] = cqi});
                end,
                true
            );
        end

        -- Setup listener to recursively trigger ScriptEventCQIFinishedMoving
        core:add_listener(
            "ScriptEventCQIFinishedMovingListenerPerpetuator",
            "ScriptEventCQIFinishedMoving",
            true,
            function(context)
                local cqi = context:cqi();
                -- log movement
                hanter_iflm.logger.log_cqi_movement(cqi);
                if infinite_movement then
                    cm:replenish_action_points("character_cqi:"..cqi);
                end
                cm:notify_on_character_halt(
                    cqi,
                    function()
                        core:trigger_custom_event("ScriptEventCQIFinishedMoving",{["cqi"] = cqi});
                    end,
                    true
                );
            end,
            true
        );
    end
);