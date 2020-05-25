push = require 'lib/push'

Class = require 'lib/class'
--Хранит глобальные переменные
require 'src/constants'

require 'src/Ball'
require 'src/Brick'
require 'src/LevelMaker'
require 'src/Paddle'
--Класс определяет состояние приложения
require 'src/StateMachine'
--Класс Для вывода Quads
require 'src/Util'
--Классы для статусов
require 'src/states/BaseState'
require 'src/states/EnterHighScoreState'
require 'src/states/PaddleSelectState'
require 'src/states/GameOverState'
require 'src/states/HighScoreState'
require 'src/states/PlayState'
require 'src/states/ServeState'
require 'src/states/StartState'
require 'src/states/VictoryState'
