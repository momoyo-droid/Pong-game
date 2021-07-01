Ball = Class {}

function Ball: init(x, y, width, height)
    self.x = x
    self.y = y
    self.width = width
    self.height = height

    -- these variables are for keeping track of our velocity on both the x and y
    -- axis, since the Ball can move in two dimensions.
    self.dy = 0
    self.dx = 0
end

function Ball: collides(paddle)
    -- first, check to see if  the left edge of either is farther to the right than the right edge
    -- of the other
    if self.x > paddle.x + paddle.width or paddle.x > self.x + self.width then
        return false
    end

    -- then check to see if the bottom edge of either is higher than the top
    -- edge of the other 
    if self.y > paddle.y + paddle.height or paddle.y > self.y + self.height then
        return false
    end

    -- if the above arent true, they are overlapping
    return true

end

-- places the Ball in the middle of the screen, with a initial random velocity on both axes.
function Ball: reset()
    self.x = virtual_w / 2 - 2
    self.y = virtual_h / 2 - 2
    self.dx = 0
    self.dy = 0
end

-- simply applies velocity to position, scaled by dt.
function Ball: update(dt)
    self.x = self.x + self.dx * dt
    self.y = self.y + self.dy * dt
end

function Ball: render()
    love.graphics.rectangle('fill', self.x, self.y, self.width, self.height)
end