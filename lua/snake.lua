-- ==========================================
-- SNAKE 2.5D COM PAREDES 3D
-- ==========================================

math.randomseed(os.time())

local SCREEN_W, SCREEN_H = lge.get_canvas_size()

-- =============================
-- CÂMERA
-- =============================
local FOV = 240
local CAM_DISTANCE = 200
lge.set_3d_camera(FOV, CAM_DISTANCE)

-- Luz vindo de cima
lge.set_3d_light(0.3, 1, -0.4, 0.3, 0.8)

-- =============================
-- MODELO CUBO
-- =============================
local vertices = {
    -0.5,-0.5, 0.5,  0.5,-0.5, 0.5,  0.5, 0.5, 0.5, -0.5, 0.5, 0.5,
    -0.5,-0.5,-0.5,  0.5,-0.5,-0.5,  0.5, 0.5,-0.5, -0.5, 0.5,-0.5,
}

local faces = {
    1,2,3, 1,3,4,
    5,7,6, 5,8,7,
    5,1,4, 5,4,8,
    2,6,7, 2,7,3,
    4,3,7, 4,7,8,
    5,6,2, 5,2,1,
}

local model = lge.create_3d_model(vertices, faces)

-- Snake verde
local snake_colors = {}
for i=1,12 do snake_colors[i] = "#00ff00" end
local snake_cube = lge.create_3d_instance(model, snake_colors)

-- Comida vermelha
local food_colors = {}
for i=1,12 do food_colors[i] = "#ff3333" end
local food_cube = lge.create_3d_instance(model, food_colors)

-- Paredes azuis
local wall_colors = {}
for i=1,12 do wall_colors[i] = "#3355ff" end
local wall_cube = lge.create_3d_instance(model, wall_colors)

-- =============================
-- CONFIG DO MUNDO
-- =============================
local GRID = 8
local CELL = 18
local MOVE_DELAY = 150
local WORLD_Z = 220

local snake = {
    {x=0,y=0},
    {x=-1,y=0},
    {x=-2,y=0},
}

local dir = {x=1,y=0}
local score = 0
local game_over = false

local food = {x=0,y=0}

local function spawn_food()
    food.x = math.random(-GRID+1, GRID-1)
    food.y = math.random(-GRID+1, GRID-1)
end

spawn_food()

-- =============================
-- INPUT (clique gira)
-- =============================
local function handle_input()
    local button, mx, my = lge.get_mouse_click()
    if not mx then return end

    if game_over then
        snake = {
            {x=0,y=0},
            {x=-1,y=0},
            {x=-2,y=0},
        }
        dir = {x=1,y=0}
        score = 0
        game_over = false
        spawn_food()
        return
    end

    if mx < SCREEN_W/2 then
        dir = {x=-dir.y, y=dir.x}
    else
        dir = {x=dir.y, y=-dir.x}
    end
end

-- =============================
-- UPDATE
-- =============================
local function update()
    if game_over then return end

    local head = snake[1]
    local new_head = {
        x = head.x + dir.x,
        y = head.y + dir.y,
    }

    -- colisão com parede
    if math.abs(new_head.x) >= GRID or
       math.abs(new_head.y) >= GRID then
        game_over = true
        return
    end

    -- colisão corpo
    for i=1,#snake do
        if snake[i].x==new_head.x and
           snake[i].y==new_head.y then
            game_over = true
            return
        end
    end

    table.insert(snake,1,new_head)

    if new_head.x==food.x and new_head.y==food.y then
        score = score + 1
        spawn_food()
    else
        table.remove(snake)
    end
end

-- =============================
-- DESENHAR PAREDES
-- =============================
local function draw_walls()
    for x=-GRID, GRID do
        for y=-GRID, GRID do
            if math.abs(x)==GRID or math.abs(y)==GRID then
                lge.draw_3d_instance(
                    wall_cube,
                    x*CELL,
                    y*CELL,
                    WORLD_Z,
                    CELL*0.9,
                    0,0,0
                )
            end
        end
    end
end

-- =============================
-- RENDER
-- =============================
local function draw()
    lge.clear_canvas("#0f1220")

    -- inclinação leve para 2.5D
    local tilt_x = 0.5
    local tilt_y = 0.7

    draw_walls()

    -- cobra
    for i=1,#snake do
        local s = snake[i]
        lge.draw_3d_instance(
            snake_cube,
            s.x*CELL,
            s.y*CELL,
            WORLD_Z,
            CELL*0.8,
            tilt_x,
            tilt_y,
            0
        )
    end

    -- comida
    lge.draw_3d_instance(
        food_cube,
        food.x*CELL,
        food.y*CELL,
        WORLD_Z,
        CELL*0.8,
        tilt_x,
        tilt_y,
        0
    )

    lge.draw_text(10,10,"Score: "..score,"#ffffff")

    if game_over then
        lge.draw_text(
            SCREEN_W/2-80,
            SCREEN_H/2,
            "GAME OVER - Clique para reiniciar",
            "#ff4444"
        )
    end

    lge.present()
end

-- =============================
-- LOOP
-- =============================
local accumulator = 0
local last_time = os.clock()*1000

while true do
    local now = os.clock()*1000
    local dt = now - last_time
    last_time = now
    accumulator = accumulator + dt

    handle_input()

    if accumulator >= MOVE_DELAY then
        update()
        accumulator = 0
    end

    draw()
    lge.delay(1)
end