--глобальные шаблоны (используются для придания всей карте определенной формы)
NONE = 1
SINGLE_PYRAMID = 2
MULTI_PYRAMID = 3

SOLID = 1           -- все цвета одинаковы в этом ряду
ALTERNATE = 2       -- Альтернативные цвета
SKIP = 3            -- Пропустить все остальные блоки
NONE = 4            -- Нет блоков в этом ряду

LevelMaker = Class{}

function LevelMaker.createMap(level)
    local bricks = {}

    --случайным образом выбираем количество строк
    local numRows = math.random(1, 5)

    --случайным образом выберите количество столбцов, гарантируя нечетное
    local numCols = math.random(7, 13)
    numCols = numCols % 2 == 0 and (numCols + 1) or numCols

    -- Самый большой уровень поражения кирпича, не больше трех
    local highestTier = math.min(3, math.floor(level / 5))

    -- Самый высокий цвет самого высокого уровня
    local highestColor = math.min(5, level % 5 + 3)

    --Выкладываем кирпичи, что бы они касались друг друга и заполняли пространство
    for y = 1, numRows do
        --Возможность включить пропуск в этой строке
        local skipPattern = math.random(1, 2) == 1 and true or false

        --Возможно включить чередование в этой строке
        local alternatePattern = math.random(1, 2) == 1 and true or false

        --Выбираем два цвета, что бы чередовать его
        local alternateColor1 = math.random(1, highestColor)
        local alternateColor2 = math.random(1, highestColor)
        local alternateTier1 = math.random(0, highestTier)
        local alternateTier2 = math.random(0, highestTier)

        --Используем когда мы хотим пропустить блок
        local skipFlag = math.random(2) == 1 and true or false

        --Используем когда хотим чередовать блок
        local alternateFlag = math.random(2) == 1 and true or false

        --Будем использовать один цвет, если не будем чередовать
        local solidColor = math.random(1, highestColor)
        local solidTier = math.random(0, highestTier)

        for x = 1, numCols do
            --Если пропуск включонб и мы находимся на итерации пропуска
            if skipPattern and skipFlag then
                --Включаем пропуск для следующей итерации
                skipFlag = not skipFlag

                -- Lua не может продолжать отчет, так что это временное решение
                goto continue
            else
                -- Сменить флаг на true во время итерации если мы его не используем
                skipFlag = not skipFlag
            end

            b = Brick(
                -- x
                (x-1)                   -- Уменьшаем х на 1б поскольку таблицы индексируются на 1, координата равна 0
                * 32                    -- умножаем на 32б ширина кирпича
                + 8                     -- экран должен иметь 8 пикселей отступа; мы можем разместить 13 колов + 16 пикселей всего
                + (13 - numCols) * 16,  -- левостороннее заполнение для тех случаев, когда имеется менее 13 столбцов

                -- y
                y * 16                  -- используйте y * 16, так как нам все равно нужна верхняя обивка
            )

            -- Если мы чередуем, нужно понимать на каком цвете и уровне мы находимся
            if alternatePattern and alternateFlag then
                b.color = alternateColor1
                b.tier = alternateTier1
                alternateFlag = not alternateFlag
            else
                b.color = alternateColor2
                b.tier = alternateTier2
                alternateFlag = not alternateFlag
            end

            -- Если не чередуем, то используем сплошной цвет
            if not alternatePattern then
                b.color = solidColor
                b.tier = solidTier
            end

            table.insert(bricks, b)

            ::continue::
        end
    end
    --Если мы не создали кирпичей, пробуем еще раз
    if #bricks == 0 then
        return self.createMap(level)
    else
        return bricks
    end
end
