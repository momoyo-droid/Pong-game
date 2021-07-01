push = require 'push' -- library to emulate virtual resolution.
Class = require 'class'
require 'Paddle'
require 'Ball'

-- set actual screen size.
window_width = 1280
window_height = 720

-- trying to emulate screen with push. 
virtual_w = 432
virtual_h = 243

-- speed at which we will move our paddle.
paddle_speed = 200

-- function used for initializing our game state at the very beginning of program execution.
function love.load()
    
    -- sets the default scaling filters used with Images, Canvases, and Fonts.
    love.graphics.setDefaultFilter('nearest','nearest')

    -- set the title of our application window
    love.window.setTitle('Pong')
    
    -- returns the time in system seconds. os.time() 
    -- is very useful in conjunction with math.randomseed(), 
    -- since time will always be different each time it is used 
    -- (essentially guaranteeing a unique seed value).
    math.randomseed(os.time())

    -- font object.
    smallFont = love.graphics.newFont('font/font.ttf', 8)
    scoreFont = love.graphics.newFont('font/font.ttf', 16)
    largeFont = love.graphics.newFont('font/font.ttf', 32)
    
    -- love2d active font to the smallFont object.
    love.graphics.setFont(smallFont)
    
    -- initialize windows with virtual resolution.
    push: setupScreen(virtual_w, virtual_h, window_width, window_height, {fullscreen = false, 
    resizable = false, vsync = true})

    -- paddle positions
    player1 = Paddle(5, 30, 5, 20)
    player2 = Paddle(virtual_w - 10, virtual_h - 30, 5, 20)
    
    -- places the ball in the middle of the screen
    ballGame = Ball(virtual_w / 2-2, virtual_h / 2-2, 4, 4)
    
    -- initialize score variables of players
    player1_score = 0 
    player2_score = 0

    -- either going to be 1 or 2; whomever is scored on gets to serve the
    -- following turn
    servingPlayer = 1

    -- player who won the game; not set to a proper value until we reach
    -- that state in the game
    winningPlayer = 0

    ballGame.dx = math.random(2) == 1 and 150 or -150
    ballGame.dy = math.random(-75, 75) * 1.15
    -- gameState is a variable used to transition between different parts of the game
    -- we will use this to determine  behavior during render and update
    gameState = 'start'

end

-- function called eache frame by LOVE; dt will be elapsed time in seconds since the last frame
-- and we can use this to scale any changes in our game for even behavior across frame rates.
function love.update(dt)
    if gameState == 'serve' then
        -- before switching to play, initialize ball's velocity based
        -- on player who last scored
        ballGame.dy = math.random(-50, 50)
        if servingPlayer == 1 then
            ballGame.dx = math.random(140,200)
        else
            ballGame.dx = -math.random(140,200)
        end
    -- update our ball based on its DX and DY only if we are in play state.
    -- scale the velocity by dt so movement is frame rate independent
    elseif gameState == 'play' then
         -- if we reach the left or right edge of the screen go back to start and update score
        if ballGame.x < 0 then
            servingPlayer = 2
            player2_score = player2_score + 1
            -- sounds
            -- if we reached a score of 10
            if player2_score == 5 then
                winningPlayer = 2
                gameState = 'done'
            else 
                gameState = 'serve'
                ballGame: reset()
            end
        end

        if ballGame.x > virtual_w then
            servingPlayer = 1
            player1_score = player1_score + 1
            -- sounds
            -- if we reached a score of 10
            if player1_score == 5 then
                winningPlayer = 1
                gameState = 'done'
            else 
                gameState = 'serve'
                ballGame: reset()
            end
        end

        -- player 1 movement
        if love.keyboard.isDown('w') then
            -- add negative paddle speed to current Y scaled by deltaTime(dt).
            player1.dy = -paddle_speed
            elseif love.keyboard.isDown('s') then
            -- add positive paddle speed to current Y scaled by deltaTime(dt).
            player1.dy = paddle_speed
            else
            player1.dy = 0
        end

        -- player 2 movement 
        if love.keyboard.isDown('up') then
            -- add negative paddle speed to current Y scaled by deltaTime(dt).
            player2.dy = -paddle_speed
            elseif love.keyboard.isDown('down') then
            -- add positive paddle speed to current Y scaled by deltaTime(dt).
            player2.dy = paddle_speed
            else
            player2.dy = 0
        end

        if gameState == 'play' then
            ballGame: update(dt)
        end

        -- detect ball collision with paddles
        if ballGame: collides(player1) then
            ballGame.dx = -ballGame.dx * 1.03
            ballGame.x = player1.x + 5

            -- keep velocity doing in the same direction, but randomize it 
            if ballGame.dy < 0 then
                ballGame.dy = -math.random(10,150)
            else
                ballGame.dy = math.random(10,150)
            end
            -- sounds
        end
        if ballGame: collides(player2) then
            ballGame.dx = -ballGame.dx * 1.03
            ballGame.x = player2.x - 4

            -- keep velocity doing in the same direction, but randomize it 
            if ballGame.dy < 0 then
                ballGame.dy = -math.random(10,150)
            else
                ballGame.dy = math.random(10,150)
            end
            -- sounds
        end

        -- detect upper and lower screen boundary collision and reverse if collide
        if ballGame.y <= 0 then
            ballGame.y = 0
            ballGame.dy = -ballGame.dy
            -- sounds
        end
        -- -4 if to account for the ball size
        if ballGame.y >= virtual_h - 4 then
            ballGame.y = virtual_h - 4
            ballGame.dy = -ballGame.dy
            -- sounds
        end
       
    end
    
    player1: update(dt)
    player2: update(dt)
    --ballGame: update(dt)
end

-- execute actions
function love.keypressed(key)
    -- `key` will be whatever key this callback detected as pressed
    if key == 'escape' then
        -- the function LÖVE2D uses to quit the application
        love.event.quit()
    -- if we press enter during either the start or serve phase, it should
    -- transition to the next appropriate state
    elseif key == 'enter' or key == 'return' then
        if gameState == 'start' then
            gameState = 'serve'
        elseif gameState == 'serve' then
            gameState = 'play'
        elseif gameState == 'done' then
            -- game is simply in a restart phase here, but will set the serving
            -- player to the opponent of whomever won for fairness!
            gameState = 'serve'

            ballGame:reset()

            -- reset scores to 0
            player1_score = 0
            player2_score = 0

            -- decide serving player as the opposite of who won
            if winningPlayer == 1 then
                servingPlayer = 1
            else
                servingPlayer = 2
            end
        end
    end
end

-- function called each frame by LOVE after update for drawing things to the screen once they've 
--changed.
function love.draw()
    push: start()

    -- background color
    love.graphics.clear(40/255, 45/255, 52/255, 255/255)
    
    -- render different things depending on which part of the game we're in
    if gameState == 'start' then
        -- UI messages
        love.graphics.setFont(smallFont)
        love.graphics.printf('Welcome to Pong!', 0, 10, virtual_w, 'center')
        love.graphics.printf('Press Enter to begin!', 0, 20, virtual_w, 'center')
    elseif gameState == 'serve' then
        -- UI messages
        love.graphics.setFont(smallFont)
        love.graphics.printf('Player ' .. tostring(servingPlayer) .. "'s serve!", 
            0, 10, virtual_w, 'center')
        love.graphics.printf('Press Enter to serve!', 0, 20, virtual_w, 'center')
    elseif gameState == 'play' then
        -- no UI messages to display in play
    elseif gameState == 'done' then
        -- UI messages
        love.graphics.setFont(largeFont)
        love.graphics.printf('Player ' .. tostring(winningPlayer) .. ' wins!',
            0, 10, virtual_w, 'center')
        love.graphics.setFont(smallFont)
        love.graphics.printf('Press Enter to restart!', 0, 60, virtual_w, 'center')
    end
    
    -- display score
    displayScore()

    -- render first paddle left side.
    player1: render()

    -- render second paddle right side.
    player2: render()

    -- render the ball (center).
    ballGame: render()
    
    -- display FPS
    displayFPS()

    push: finish()
end


-- Simple function for rendering the scores.
function displayScore()
    -- score display
    love.graphics.setFont(scoreFont)
    love.graphics.print(tostring(player1_score), virtual_w / 2 - 50, virtual_h / 3)
    love.graphics.print(tostring(player2_score), virtual_w / 2 + 30, virtual_h / 3)
end


-- display FPS
function displayFPS()
    -- simple FPS display across all states
    love.graphics.setFont(smallFont)
    love.graphics.setColor(0/255, 255/255, 0/255, 255/255)
    love.graphics.print('FPS: ' .. tostring(love.timer.getFPS()), 10, 10)
end
