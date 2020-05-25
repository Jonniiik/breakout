-- Мы будем наследоваться только от Dependencies. А Dependencies будет наследовать от всех остальных классов
require 'src/Dependencies'

function love.load()
  love.graphics.setDefaultFilter('nearest', 'nearest')

  math.randomseed(os.time())

  love.window.setTitle('Breakout')
  -- Инициализация шрифтов
  gFonts = {
          ['small'] = love.graphics.newFont('fonts/font.ttf', 8),
          ['medium'] = love.graphics.newFont('fonts/font.ttf', 16),
          ['large'] = love.graphics.newFont('fonts/font.ttf', 32)}
  love.graphics.setFont(gFonts['small'])

  --инициализация Текстур
  gTextures = {
      ['background'] = love.graphics.newImage('graphics/background.png'),
      ['main'] = love.graphics.newImage('graphics/breakout.png'),
      ['arrows'] = love.graphics.newImage('graphics/arrows.png'),
      ['hearts'] = love.graphics.newImage('graphics/hearts.png'),
      ['particle'] = love.graphics.newImage('graphics/particle.png')
    }
-- Формируем фреймы для текстур
  gFrames = {
        ['paddles'] = GenerateQuadsPaddles(gTextures['main']),-- нижний прямоугольник
        ['balls'] = GenerateQuadsBalls(gTextures['main']), -- шар
        ['bricks'] = GenerateQuadsBricks(gTextures['main']), -- верхние блоки
        ['hearts'] = GenerateQuads(gTextures['hearts'], 10, 9), -- здоровье
        ['arrows'] = GenerateQuads(gTextures['arrows'], 24, 24)
   }
-- переменные VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT мы храним в src/constants
  push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
      vsync = true,
      fullscreen = false,
      resizable = true
  })
  --инициализация музыки
  gSounds = {
        ['paddle-hit'] = love.audio.newSource('sounds/paddle_hit.wav'),
        ['score'] = love.audio.newSource('sounds/score.wav'),
        ['wall-hit'] = love.audio.newSource('sounds/wall_hit.wav'),
        ['confirm'] = love.audio.newSource('sounds/confirm.wav'),
        ['select'] = love.audio.newSource('sounds/select.wav'),
        ['no-select'] = love.audio.newSource('sounds/no-select.wav'),
        ['brick-hit-1'] = love.audio.newSource('sounds/brick-hit-1.wav'),
        ['brick-hit-2'] = love.audio.newSource('sounds/brick-hit-2.wav'),
        ['hurt'] = love.audio.newSource('sounds/hurt.wav'),
        ['victory'] = love.audio.newSource('sounds/victory.wav'),
        ['recover'] = love.audio.newSource('sounds/recover.wav'),
        ['high-score'] = love.audio.newSource('sounds/high_score.wav'),
        ['pause'] = love.audio.newSource('sounds/pause.wav'),

        ['music'] = love.audio.newSource('sounds/music.wav')
    }
    --Игра имеет следующие состояния(статусы)
    -- 1. "start" (начало игры, где нам говорят нажать клавишу Enter)
    -- 2. 'paddle-select' (где мы можем выбрать цвет нашего весла)
    -- 3. "serve" (ожидание нажатия клавиши для подачи мяча)
    -- 4. "play" (мяч находится в игре, подпрыгивая между лопастями)
    -- 5. "victory "(текущий уровень закончен, с победным звоном)
    -- 6. "game-over "(игрок проиграл; показать счет и разрешить перезапуск)
    gStateMachine = StateMachine {
        ['start'] = function() return StartState() end,
        ['play'] = function() return PlayState() end,
        ['serve'] = function() return ServeState() end,
        ['game-over'] = function() return GameOverState() end,
        ['victory'] = function() return VictoryState() end,
        ['high-scores'] = function() return HighScoreState() end,
        ['enter-high-score'] = function() return EnterHighScoreState() end,
        ['paddle-select'] = function() return PaddleSelectState() end
    }
    gStateMachine:change('start', {
        highScores = loadHighScores()
    })
    --таблица для клавишь
    love.keyboard.keysPressed = {}
end

function love.resize(w, h)
    push:resize(w, h)
end

function love.update(dt)
    gStateMachine:update(dt)


    -- обнуляем
    love.keyboard.keysPressed = {}
end

function love.keypressed(key)
    love.keyboard.keysPressed[key] = true
end

function love.keyboard.wasPressed(key)
    if love.keyboard.keysPressed[key] then
        return true
    else
        return false
    end
end

function love.draw()
    push:apply('start')

    -- получаем размеры фона
    local backgroundWidth = gTextures['background']:getWidth()
    local backgroundHeight = gTextures['background']:getHeight()

    love.graphics.draw(gTextures['background'],
        -- координаты
        0, 0,
        -- нет поворота
        0,
        -- полное заполнение экрана
        VIRTUAL_WIDTH / (backgroundWidth - 1), VIRTUAL_HEIGHT / (backgroundHeight - 1))

    gStateMachine:render()

    displayFPS()

    push:apply('end')
end

function loadHighScores()
    love.filesystem.setIdentity('breakout')

    -- Если файо не существует инициализируем его
    if not love.filesystem.exists('breakout.lst') then
        local scores = ''
        for i = 10, 1, -1 do
            scores = scores .. 'CTO\n'
            scores = scores .. tostring(i * 1000) .. '\n'
        end

        love.filesystem.write('breakout.lst', scores)
    end

    -- Читаем мы имя или нет
    local name = true
    local currentName = nil
    local counter = 1

    -- инициализируем таблицу рекордов как минимум 10 пустых записей
    local scores = {}

    for i = 1, 10 do
        -- Пустая таблица, каждый будет содержать имя и счет
        scores[i] = {
            name = nil,
            score = nil
        }
    end

    -- Повторяем каждую строку файла, заполняя имя и счет
    for line in love.filesystem.lines('breakout.lst') do
        if name then
            scores[counter].name = string.sub(line, 1, 3)
        else
            scores[counter].score = tonumber(line)
            counter = counter + 1
        end

        -- повернем флаг имени
        name = not name
    end

    return scores
end

function renderHealth(health)
    local healthX = VIRTUAL_WIDTH - 100

    for i = 1, health do
        love.graphics.draw(gTextures['hearts'], gFrames['hearts'][1], healthX, 4)
        healthX = healthX + 11
    end

    for i = 1, 3 - health do
        love.graphics.draw(gTextures['hearts'], gFrames['hearts'][2], healthX, 4)
        healthX = healthX + 11
    end
end

function displayFPS()
    love.graphics.setFont(gFonts['small'])
    love.graphics.setColor(0, 255, 0, 255)
    love.graphics.print('FPS: ' .. tostring(love.timer.getFPS()), 5, 5)
end

function renderScore(score)
    love.graphics.setFont(gFonts['small'])
    love.graphics.print('Score:', VIRTUAL_WIDTH - 60, 5)
    love.graphics.printf(tostring(score), VIRTUAL_WIDTH - 50, 5, 40, 'right')
end
