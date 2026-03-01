-- ==========================================
-- LGE FULL API BENCHMARK
-- Usa TODOS os recursos da API
-- ==========================================

math.randomseed(os.time())

local SCREEN_W, SCREEN_H = lge.get_canvas_size()

-- ==========================================
-- CONFIG 3D
-- ==========================================
local FOV = 260
local CAM_DISTANCE = 220
lge.set_3d_camera(FOV, CAM_DISTANCE)

lge.set_3d_light(0.3, 1, -0.5, 0.25, 0.85)

-- ==========================================
-- MODELO CUBO
-- ==========================================
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

local function random_color()
    return string.format("#%02x%02x%02x",
        math.random(50,255),
        math.random(50,255),
        math.random(50,255))
end

local tri_colors = {}
for i=1,12 do
    tri_colors[i] = random_color()
end

local cube_instance = lge.create_3d_instance(model, tri_colors)

-- ==========================================
-- ESTADO DO BENCHMARK
-- ==========================================
local num_2d = 10
local num_3d = 10
local angle = 0
local timer = 0

-- ==========================================
-- LOOP
-- ==========================================
while true do

    lge.clear_canvas("#0e0e18")

    local start_time = os.clock()

    -- ======================================
    -- 2D STRESS TEST
    -- ======================================
    for i=1,num_2d do
        local x = math.random(0, SCREEN_W)
        local y = math.random(0, SCREEN_H)

        lge.draw_circle(x, y, 5, random_color())
        lge.draw_rectangle(x, y, 8, 8, random_color())
        lge.draw_triangle(
            x, y,
            x+5, y+10,
            x+10, y,
            random_color()
        )
    end

    -- ======================================
    -- 3D STRESS TEST
    -- ======================================
    angle = angle + 0.01

    for i=1,num_3d do
        local px = math.random(-150,150)
        local py = math.random(-150,150)
        local pz = math.random(120,400)

        lge.draw_3d_instance(
            cube_instance,
            px, py, pz,
            8,
            angle,
            angle*0.7,
            angle*1.3
        )
    end

    -- ======================================
    -- MOUSE TEST
    -- ======================================
    local button, mx, my = lge.get_mouse_position()
    if mx then
        lge.draw_circle(mx, my, 12, "#00ffff")
    end

    local click = lge.get_mouse_click()
    if click then
        -- aumenta carga ao clicar
        num_2d = num_2d + 10
        num_3d = num_3d + 10
    end

    -- ======================================
    -- HUD
    -- ======================================
    local fps = lge.fps()
    fps = math.floor(fps*100)/100

    lge.draw_text(10,10,"LGE FULL BENCHMARK","#ffffff")
    lge.draw_text(10,30,"FPS: "..fps,"#00ff00")
    lge.draw_text(10,50,"2D Objects: "..num_2d,"#aaaaaa")
    lge.draw_text(10,70,"3D Instances: "..num_3d,"#aaaaaa")
    lge.draw_text(10,90,"Clique para aumentar carga","#ffcc00")

    lge.present()
    lge.delay(1)

    -- ======================================
    -- Auto scaling progressivo
    -- ======================================
    timer = timer + 1
    if timer % 300 == 0 then
        num_2d = num_2d + 50
        num_3d = num_3d + 25
    end
end