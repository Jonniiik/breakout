
PlayState = Class{__includes = BaseState}

function PlayState:enter(params)
  self.paddle = params.paddle
  self.bricks = params.bricks
  self.health = params.health
  self.score = params.score
  self.highScores = params.highScores
  self.ball = params.ball
  self.level = params.level

    self.ball.dx = math.random(-200, 200)
    self.ball.dy = math.random(-50, -60)
end

function PlayState:update(dt)
    if self.paused then
        if love.keyboard.wasPressed('space') then
            self.paused = false
            gSounds['pause']:play()
        else
            return
        end
    elseif love.keyboard.wasPressed('space') then
        self.paused = true
        gSounds['pause']:play()
        return
    end

    -- Обновление позиции
    self.paddle:update(dt)
    self.ball:update(dt)

    if self.ball:collides(self.paddle) then
      --поднимаем шар над нижним прямоугольником
        self.ball.y = self.paddle.y - 8
        self.ball.dy = -self.ball.dy

        -- Нужно отрегулировать угол отскока, смотря куда поподает шар в нижний прямоугольник

        --Если мы ударим по левому краю во время движение в лево
        if self.ball.x < self.paddle.x + (self.paddle.width / 2) and self.paddle.dx < 0 then
          self.ball.dx = -50 + -(8 * math.abs(self.paddle.x + self.paddle.width / 2 - self.ball.x))

        --Если мы ударим по правому краю во время движения в право
        elseif self.ball.x > self.paddle.x + (self.paddle.width / 2) and self.paddle.dx > 0 then
          self.ball.dx = 50 + (8 * math.abs(self.paddle.x + self.paddle.width / 2 - self.ball.x))
        end

        gSounds['paddle-hit']:play()
    end

    for k, brick in pairs(self.bricks) do

        if brick.inPlay and self.ball:collides(brick) then
          --добавляем счет
          self.score = self.score + (brick.tier * 200 + brick.color * 25)

            brick:hit()
            --идем к экрану победы, если кирпичей больше нет
            if self:checkVictory() then
                gSounds['victory']:play()

                gStateMachine:change('victory', {
                  level = self.level,
                  paddle = self.paddle,
                  health = self.health,
                  score = self.score,
                  highScores = self.highScores,
                  ball = self.ball
                })
            end

            --Код сталкновения для верхних кирпичей
            --Мы посмотрим, движение скорости за пределами кирпича
            --если мы находимся за пределами кирпича, мы сделаем столкновение с той стороной, в противном случае мы будем находится в пределах ширины x
            --Кирпич должен проверить, с какой стороны идет столкновение

            --Левый край, нужно проверить не двигаемся ли мы в право
            if self.ball.x + 2 < brick.x and self.ball.dx > 0 then
              -- Переварачиваем скорость x и сбросить положение вне кирпича
              self.ball.dx = -self.ball.dx
              self.ball.x = brick.x - 8
              --Правый край, нужно проверить движение в лево
            elseif self.ball.x + 6 > brick.x + brick.width and self.ball.dx < 0 then
              --разварачиваем x скорость и сбросить положение вне кирпича
              self.ball.dx = -self.ball.dx
              self.ball.x = brick.x + 32

              --Вверхний край если нет столкновений х проверяем
            elseif self.ball.y < brick.y then
              --Проверяем скорость y сбросим положение вне кирпича
              self.ball.dy = -self.ball.dy
              self.ball.y = brick.y - 8
              --нижний край.
            else
              --развернуть скорость, сбросить положение кирпича
              self.ball.dy = -self.ball.dy
              self.ball.y = brick.y + 16
            end
              --Немного увеличим скорость, что бы ускорить игру
              self.ball.dy = self.ball.dy * 1.02

              -- Разрешим столкновения только с одним кирпичем
              break
        end
    end

    if self.ball.y >= VIRTUAL_HEIGHT then
        self.health = self.health - 1
        gSounds['hurt']:play()

        if self.health == 0 then
          gStateMachine:change('game-over', {
            score = self.score,
            highScores = self.highScores
          })
        else
          gStateMachine:change('serve', {
            paddle = self.paddle,
            bricks = self.bricks,
            health = self.health,
            score = self.score,
            highScores = self.highScores,
            level = self.level
          })
        end
    end

    -- Обновляем взрывы
    for k, brick in pairs(self.bricks) do
      brick:update(dt)
    end

    if love.keyboard.wasPressed('escape') then
        love.event.quit()
    end
end

function PlayState:render()
  -- обновление верхних блоков
    for k, brick in pairs(self.bricks) do
        brick:render()
    end

    -- обновление взрыва
    for k, brick in pairs(self.bricks) do
      brick:renderParticles()
    end

    self.paddle:render()
    self.ball:render()


    renderScore(self.score)
    renderHealth(self.health)

    -- Пауза
    if self.paused then
        love.graphics.setFont(gFonts['large'])
        love.graphics.printf("PAUSED", 0, VIRTUAL_HEIGHT / 2 - 16, VIRTUAL_WIDTH, 'center')
    end
end

function PlayState:checkVictory()
    for k, brick in pairs(self.bricks) do
        if brick.inPlay then
            return false
        end
    end

    return true
end
