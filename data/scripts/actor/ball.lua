
ball_states = {}

function ball_states.none(eid, ball, delta)
    ball.state = "swing"
    ball.marker = entities:create_entity()

    local pos = component.position.new(entities:get_component(eid, component.position))

    ball.reset_x = pos.x
    ball.reset_y = pos.y

    local anim = component.animation.new()
    anim.name = "arrow"
    anim.cycle = "arrow"
    anim.offset_x = -0.5
    anim.offset_y = 0.5
    anim.rot = -math.pi/4

    entities:create_component(ball.marker, pos)
    entities:create_component(ball.marker, anim)
end

function ball_states.swing(eid, ball, delta)
    if input.left then
        ball.angle_vel = math.min(1, ball.angle_vel + delta * 10)
        ball.angle = ball.angle + math.pi/2 * delta * 2 * ball.angle_vel
        if ball.angle > math.pi/2 then
            ball.angle = math.pi/2
        end
    end
    if input.right then
        ball.angle_vel = math.min(1, ball.angle_vel + delta * 10)
        ball.angle = ball.angle - math.pi/2 * delta * 2 * ball.angle_vel
        if ball.angle < -math.pi/2 then
            ball.angle = -math.pi/2
        end
    end

    if not input.left and not input.right then
        ball.angle_vel = 0
    end

    local anim = entities:get_component(ball.marker, component.animation)
    anim.rot = -math.pi/4 + ball.angle

    if input.shoot_pressed then
        ball.state = "shoot"
    end
end

function ball_states.shoot(eid, ball, delta)
    local power = get_powermeter()
    power = power + delta

    set_powermeter(power)

    if input.shoot_pressed and power > 0 or power > 1 then
        local pos = entities:get_component(eid, component.position)
        ball.land_x = pos.x + power * 16.7 * math.cos(ball.angle + math.pi/2)
        ball.land_y = pos.y + power * 16.7 * math.sin(ball.angle + math.pi/2)
        local vel = component.velocity.new()
        local dx = ball.land_x - pos.x
        local dy = ball.land_y - pos.y
        local dist = math.sqrt(dx^2 + dy^2)
        vel.vx = 10 * dx / dist
        vel.vy = 10 * dy / dist
        ball.state = "flying"
        set_last_power(power)
        set_powermeter(0)
        entities:create_component(eid, vel)
        entities:create_component(ball.marker, component.death_timer.new())
    end
end

function ball_states.flying(eid, ball, delta)
    local pos = entities:get_component(eid, component.position)
    local vel = entities:get_component(eid, component.velocity)
    local dx = pos.x - ball.reset_x
    local dy = pos.y - ball.reset_y
    local rdx = ball.land_x - ball.reset_x
    local rdy = ball.land_y - ball.reset_y

    local target_dist = math.sqrt(rdx^2 + rdy^2)
    local ball_dist = math.sqrt(dx^2 + dy^2)

    local bposx = pos.x
    local bposy = pos.y

    local height = 1 + math.floor(math.max(0, math.min(2, 3 - 3 * math.abs(ball_dist / target_dist * 2 - 1))))

    local anim = entities:get_component(eid, component.animation)
    anim.cycle = "height_"..height

    if target_dist <= ball_dist then
        local tposx = math.floor(ball.land_x+0.5)
        local tposy = math.floor(-ball.land_y+0.5)
        local location = get_tile_at(tposx,tposy)
        ball.state = "none"
        pos.x = ball.reset_x
        pos.y = ball.reset_y
        vel.vx = 0
        vel.vy = 0
        if location == 7 then
            local ents = get_entities_at(tposx, -tposy, 0.5)
            local build = true
            for _,e in ipairs(ents) do
                if entities:has_component(e, component.tower) then
                    build = false
                    break
                end
            end
            if build then
              play_sfx("towerbuild")
                local tower_eid = entity_from_json(get_selected_tower())
                local tpos = component.position.new()
                tpos.x = tposx
                tpos.y = -tposy
                entities:create_component(tower_eid, tpos)
            else
                spawn_dedball(bposx, bposy)
            end
        else
            spawn_dedball(bposx, bposy)
        end
    end
end

function spawn_dedball(x, y)
    local dedball = entities:create_entity()
    local tpos = component.position.new()
    tpos.x = x
    tpos.y = y
    local tanim = component.animation.new()
    tanim.name = "ball"
    tanim.cycle = "height_1"
    local timer = component.death_timer.new()
    timer.time = 10
    entities:create_component(dedball, tpos)
    entities:create_component(dedball, tanim)
    entities:create_component(dedball, timer)
    play_sfx("ballmiss")
end

function update(eid, delta)
    local ball = entities:get_component(eid, component.ball)
    ball_states[ball.state](eid, ball, delta)
end
