Brick = Class{}

--Некие цвета в нашей политре

paletteColors = {
    -- Синий
    [1] = {
        ['r'] = 99,
        ['g'] = 155,
        ['b'] = 255
    },
    -- Зеленый
    [2] = {
        ['r'] = 106,
        ['g'] = 190,
        ['b'] = 47
    },
    -- Красный
    [3] = {
        ['r'] = 217,
        ['g'] = 87,
        ['b'] = 99
    },
    -- Фиолетовый
    [4] = {
        ['r'] = 215,
        ['g'] = 123,
        ['b'] = 186
    },
    -- Золотой
    [5] = {
        ['r'] = 251,
        ['g'] = 242,
        ['b'] = 54
    }
}

function Brick:init(x, y)
    self.tier = 0
    self.color = 1

    self.x = x
    self.y = y
    self.width = 32
    self.height = 16

    self.inPlay = true

    --Система частиц используется при попадании в кирпич
    self.psystem = love.graphics.newParticleSystem(gTextures['particle'], 64)

    --Длится от 0.5 до 1 секунды
    self.psystem:setParticleLifetime(0.5, 1)

    --Даем ускорение между X1, Y1 и X2 b Y2(0,0) и (80,80)
    --отдает в основном вниз
    self.psystem:setLinearAcceleration(-15, 0, 15, 80)

    --Рспространение частиц. Выглядит более естественно, чем равномерное распределение, которое является комом
    --числа являются велечиной стандартого отклонения от оси  X and Y
    self.psystem:setAreaSpread('normal', 10, 10)
end

function Brick:hit()
  --При столкновении. Если мы находимся на более высоком уровне цвета, чем базовый, нужно спустится на один уровень
  --Если мы на базовом цвете, все остальные идут вниз. Исчезая до 0 в течение всего срока службы частицы (второй цвет)
  self.psystem:setColors(
          paletteColors[self.color].r,
          paletteColors[self.color].g,
          paletteColors[self.color].b,
          55 * (self.tier + 1),
          paletteColors[self.color].r,
          paletteColors[self.color].g,
          paletteColors[self.color].b,
          0
      )
      self.psystem:emit(64)

      --Установим систему частиц для интерпритации между двумя цветами. В этом случае мы даем ей self.color, но с изменением альфы
      --Ярче чем более высокий уровень.
      gSounds['brick-hit-2']:stop()
      gSounds['brick-hit-2']:play()

  if self.tier > 0 then
        if self.color == 1 then
            self.tier = self.tier - 1
            self.color = 5
        else
            self.color = self.color - 1
        end
    else
      --Если мы на базовом цвете, тогда убираем кирпич
      if self.color == 1 then
            self.inPlay = false
        else
            self.color = self.color - 1
        end
    end

    --Врспроизведение второго слоя, если кирпич разрушен
    if not self.inPlay then
        gSounds['brick-hit-1']:stop()
        gSounds['brick-hit-1']:play()
    end
end

function Brick:update(dt)
    self.psystem:update(dt)
end

function Brick:render()
    if self.inPlay then
        love.graphics.draw(gTextures['main'],
        gFrames['bricks'][1 + ((self.color - 1) * 4) + self.tier], self.x, self.y)
    end
end
function Brick:renderParticles()
    love.graphics.draw(self.psystem, self.x + 16, self.y + 8)
end
