-- Configuração inicial
local SCREEN_W, SCREEN_H = lge.get_canvas_size()
local QUAD_SIZE = 20
local delay_time = 500 -- tempo de espera em ms para gerar próximo quadrado automaticamente

-- Estado inicial
local squares = {}
local max_x = 0
local max_y = 0
local current_x = 0
local current_y = 0
local last_click_time = os.clock() * 1000

-- Função para adicionar quadrado
local function add_square()
    -- Adiciona quadrado na posição atual
    table.insert(squares, {x=current_x, y=current_y})
    max_x = math.max(max_x, current_x)
    max_y = math.max(max_y, current_y)

    -- Calcula próxima posição
    current_x = current_x + QUAD_SIZE
    if current_x + QUAD_SIZE > SCREEN_W then
        -- Próxima linha
        current_x = 0
        current_y = current_y + QUAD_SIZE
        if current_y + QUAD_SIZE > SCREEN_H then
            -- Reseta para topo se passar do limite
            current_y = 0
        end
    end
end

-- Adiciona o quadrado inicial
add_square()

-- Loop principal
while true do
    lge.clear_canvas("#000000")

    -- Desenha todos os quadrados
    for _, sq in ipairs(squares) do
        lge.draw_rectangle(sq.x, sq.y, QUAD_SIZE, QUAD_SIZE, "#ff0000")
    end

    -- Exibe posição máxima no canto superior esquerdo
    lge.draw_text(5, 5, max_x..","..max_y, "#ffffff")

    -- Verifica clique
    local button, mx, my = lge.get_mouse_click()
    if mx then
        add_square()
        last_click_time = os.clock() * 1000
    end

    -- Se passou tempo sem clique, gera quadrado automaticamente no início da linha
    local current_time = os.clock() * 1000
    if current_time - last_click_time >= delay_time then
        -- Reseta coluna para início da linha
        current_x = 0
        current_y = current_y + QUAD_SIZE
        if current_y + QUAD_SIZE > SCREEN_H then
            current_y = 0
        end
        add_square()
        last_click_time = current_time
    end

    lge.present()
    lge.delay(1)
end