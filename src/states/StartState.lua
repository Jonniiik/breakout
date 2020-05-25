StartState = Class{__includes = BaseState}
--переменная для выбора между "Start" и "High Score"
local highlighted = 1

function StartState:enter(params)
    self.highScores = params.highScores
end

function StartState:update(dt)
  --Алгоритм который выбирает между "Start" и "High Score" через клавиши
    if love.keyboard.wasPressed('up') or love.keyboard.wasPressed('down') then
        highlighted = highlighted == 1 and 2 or 1
        gSounds['paddle-hit']:play()
    end
  --Вход по Enter
  if love.keyboard.wasPressed('enter') or love.keyboard.wasPressed('return') then
          gSounds['confirm']:play()

          if highlighted == 1 then
              gStateMachine:change('paddle-select', {
                  highScores = self.highScores
              })
          else
              gStateMachine:change('high-scores', {
                  highScores = self.highScores
              })
          end
      end

    if love.keyboard.wasPressed('escape') then
      love.event.quit()
    end
end

function StartState:render()
  --Заголовок
  love.graphics.setFont(gFonts['large'])
  love.graphics.printf("BREAKOUT", 0, VIRTUAL_HEIGHT / 3, VIRTUAL_WIDTH, 'center')
  --Меню, положение игры
  love.graphics.setFont(gFonts['medium'])
  --Присваиваем цвет
  if highlighted == 1 then
    love.graphics.setColor(103, 255, 255, 255)
  end
  --Выводим "START"
  love.graphics.printf("START", 0, VIRTUAL_HEIGHT / 2 + 70, VIRTUAL_WIDTH, 'center')
  --возвращаем цвет
  love.graphics.setColor(255, 255, 255, 255)
  --Присваиваем цвет
  if highlighted == 2 then
    love.graphics.setColor(103, 255, 255, 255)
  end
  --Выводим "HIGH SCORE"
  love.graphics.printf("HIGH SCORE", 0, VIRTUAL_HEIGHT / 2 + 90, VIRTUAL_WIDTH, 'center')
  -- Обновляем цвет
  love.graphics.setColor(255, 255, 255, 255)
end
