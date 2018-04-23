once = false
nextTile = 2

function update(eid, delta)
    --- test code for path finding ---
    doOnce(eid)
    local epos = entities:get_component(enemyMove, component.position)

    -- if epos.y < -2 then
    --     local newVel = entities:get_component(enemyMove, component.velocity)
    --     newVel.vx = -1
    -- end

    --print

    for k,v in ipairs(level1_path_logic) do
        --for k2,v2 in pairs(v) do
            --print(k2..v2)
            if k == nextTile then
              local newVel = entities:get_component(enemyMove, component.velocity)
                local speed = entities:get_component(enemyMove, component.speed)
                local x = v.x
                local y = v.y
                local dx = x - epos.x
                local dy = y - epos.y
                local dist = math.sqrt(dx*dx + dy*dy) -- speed.speedness
              --  print(speed.speedness)
                newVel.vx = dx*speed.speedness / dist
                newVel.vy = dy*speed.speedness / dist
                if dist < 0.0625  then
                    nextTile = nextTile + 1
                end
            end
        --end
    end
end

function doOnce(eid)
    if not once then
        enemyMove = entities:create_entity()
        local animation = component.animation.new()
        local speed = component.speed.new()
        speed.speedness = 5
        local epos = entities:get_component(eid, component.position)
        epos.x = 9
        epos.y = 0
        --local vx,vy = normalize_dimension((enemy_pos.x-pos.x),(enemy_pos.y-pos.y))
        evel = component.velocity.new()
        evel.vx = 0
        evel.vy = -1
        animation.name = "enemy"
        animation.cycle = "walk"
        entities:create_component(enemyMove, epos)
        entities:create_component(enemyMove, evel)
        entities:create_component(enemyMove, speed)
        -- entities:create_component(enemyMove, aabb)
        entities:create_component(enemyMove, animation)
        --print("hey")
        -- print (level1_path_logic)
        -- for k,v in ipairs(level1_path_logic) do
        --     for k2,v2 in pairs(v) do
        --         print(k..v2)
        --     end
        -- end

        once = true
    end

end
