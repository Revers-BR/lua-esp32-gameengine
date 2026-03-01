-- ==========================================
-- MINECRAFT COM SISTEMA DE CHUNKS
-- ==========================================

math.randomseed(1337)

local SCREEN_W, SCREEN_H = lge.get_canvas_size()

lge.set_3d_camera(280, 240)
lge.set_3d_light(0.3, 1, -0.5, 0.35, 0.85)

-- ==========================================
-- CUBE MODEL
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

local function block_instance(color)
    local colors = {}
    for i=1,12 do colors[i]=color end
    return lge.create_3d_instance(model, colors)
end

local grass = block_instance("#3cb043")
local dirt  = block_instance("#8b5a2b")
local stone = block_instance("#777777")

-- ==========================================
-- CHUNK CONFIG
-- ==========================================

local CHUNK_SIZE = 16
local VIEW_DISTANCE = 2   -- chunks ao redor
local MAX_HEIGHT = 8
local CELL = 14
local WORLD_Z = 400

local chunks = {}

-- ==========================================
-- GERAÇÃO DE CHUNK
-- ==========================================

local function generate_chunk(cx, cz)

    if not chunks[cx] then chunks[cx] = {} end
    if chunks[cx][cz] then return end

    local chunk = {}
    chunk.blocks = {}

    for x=0,CHUNK_SIZE-1 do
        for z=0,CHUNK_SIZE-1 do

            local wx = cx*CHUNK_SIZE + x
            local wz = cz*CHUNK_SIZE + z

            local height = math.floor(
                (math.sin(wx*0.2)+math.cos(wz*0.2))*2 + MAX_HEIGHT/2
            )

            for y=0,height do
                local block_type =
                    (y==height and "grass") or
                    (y>height-3 and "dirt") or
                    "stone"

                table.insert(chunk.blocks,{
                    x=wx,
                    y=y,
                    z=wz,
                    type=block_type
                })
            end
        end
    end

    chunks[cx][cz] = chunk
end

-- ==========================================
-- CAMERA ORBIT (simula player posição)
-- ==========================================

local orbit = 0
local ORBIT_RADIUS = 120

local function get_camera_chunk()
    local px = math.floor(math.cos(orbit)*2)
    local pz = math.floor(math.sin(orbit)*2)
    return px, pz
end

-- ==========================================
-- RENDER LOOP
-- ==========================================

while true do

    lge.clear_canvas("#87ceeb")

    orbit = orbit + 0.01

    local offset_x = math.cos(orbit)*ORBIT_RADIUS
    local offset_z = math.sin(orbit)*ORBIT_RADIUS

    local cam_chunk_x, cam_chunk_z = get_camera_chunk()

    -- gerar e renderizar apenas chunks visíveis
    for cx = cam_chunk_x - VIEW_DISTANCE,
             cam_chunk_x + VIEW_DISTANCE do

        for cz = cam_chunk_z - VIEW_DISTANCE,
                 cam_chunk_z + VIEW_DISTANCE do

            generate_chunk(cx, cz)

            local chunk = chunks[cx][cz]

            for i=1,#chunk.blocks do
                local b = chunk.blocks[i]

                local instance =
                    (b.type=="grass" and grass) or
                    (b.type=="dirt" and dirt) or
                    stone

                lge.draw_3d_instance(
                    instance,
                    b.x*CELL + offset_x,
                    b.y*CELL,
                    WORLD_Z + b.z*CELL + offset_z,
                    CELL*0.9,
                    0.6,
                    orbit,
                    0
                )
            end
        end
    end

    local fps = math.floor(lge.fps()*100)/100
    lge.draw_text(10,10,"MINECRAFT CHUNK SYSTEM","#000000")
    lge.draw_text(10,30,"FPS: "..fps,"#000000")
    lge.draw_text(10,50,"Chunks carregados: "..((VIEW_DISTANCE*2+1)^2),"#000000")

    lge.present()
    lge.delay(1)
end