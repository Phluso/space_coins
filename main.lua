function love.load()

    love.window.setFullscreen(true);

    lar = love.graphics.getWidth();
    alt = love.graphics.getHeight();

    --distorção pela perspectiva
    dist = {}
    dist.x = lar/2;
    dist.y = alt/2;

    --centro da tela
    center = {}
    center.x = lar/2;
    center.y = alt/2;

    --posição do jogador
    pos = {}
    pos.x = center.x;
    pos.y = center.y;
    pos.z = 50;

    speed = 500;

    love.mouse.setVisible(false);

    time = 0;
    pointTime = 0;
    wallTime = 1;

    pointList = {}
    wallList = {}
    particleList = {}

    pontos = 0;

end

function love.update(dt)
    time = time + 1 * dt;

    mouseX = love.mouse.getX();
    mouseY = love.mouse.getY();

    --ajustar a posição da nave do jogador
    pos.x = lerp(pos.x, mouseX, .1);
    pos.y = lerp(pos.y, mouseY, .1);

    --limitar a posição da nave do jogador
    pos.x = clamp(pos.x, .15 * lar, .85 * lar) + math.cos(time) * 700 * dt;
    pos.y = clamp(pos.y, .15 * alt, .85 * alt) + math.sin(time) * 700 * dt;
    pos.z = pos.z + math.sin(time) * 10 * dt;

    --calcular a caixa de colisão da nave do jogador
    colBox = {}
    colBox.x1 = pos.x - pos.z;
    colBox.x2 = pos.x + pos.z;
    colBox.y1 = pos.y - pos.z;
    colBox.y2 = pos.y + pos.z;

    --calcular a perspectiva da nave do jogador
    dist.x = math.sin(pos.x / lar - .5) * lar * 2;
    dist.y = math.sin(pos.y / alt - .5) * alt * 2;



    --adcionar pontos
    pointTime = pointTime - 1 * dt;
    if (pointTime <= 0) then
        pointTime = math.random(0, .5);
        if (#pointList < 100) then
            table.insert(pointList, newPoint());
        end
    end

    --adcionar paredes
    wallTime = wallTime - 1 * dt;
    if (wallTime <= 0) then
        wallTime = 2
        table.insert(wallList, newWall());
    end

    --update pontos
    updatePoint(dt);

    --updade paredes
    updateWall(dt);

    --update particulas
    updateParticle(dt);

    --fechar jogo
    if (love.keyboard.isDown("escape")) then
        love.event.quit();
    end

end

function love.draw(dt)
    --love.graphics.circle("line", lar/2 + pos.x, alt/2 +  pos.y, 10);

    --desenhar points na frente do jogador
    love.graphics.setColor(1, 1, 0, 1);
    for i, v in ipairs(pointList) do
        if (v.z <= pos.z) then
            love.graphics.circle("fill", v.x, v.y, v.z / 2.5);
        end
    end 

    --desenhar partículas
    for i, v in ipairs(particleList) do
        love.graphics.setColor(1, v.time / v.maxTime, 0, v.time / v.maxTime);
        love.graphics.circle("fill", v.x, v.y, v.z / 10);
    end

    --desenhar jogador
    for i = 0, 10, 1 do
        love.graphics.setColor(1, 0, i / 10, 1);
       love.graphics.circle(
            "fill",
            pos.x + i / 200 * dist.x,
            pos.y + i / 200 * dist.y,
            pos.z + i
        );
    end

    --desenhar points atrás do jogador
    for i, v in ipairs(pointList) do
        if (v.z > pos.z) then
            love.graphics.setColor(1, 1, 0, 1 - (v.z - pos.z) / 50);
            love.graphics.circle("fill", v.x, v.y, v.z / 2.5);
        end
    end 

    --desenhar caixa de colisão do jogador
    --love.graphics.rectangle("line", colBox.x1, colBox.y1, pos.z * 2, pos.z * 2);

    --desenhar paredes
    for i, v in ipairs(wallList) do
        for i = 0, 10, 1 do
            --love.graphics.rectangle("line", v.x - v.size / 2 - i, v.y - v.size / 2 - i, v.size - i, v.size - i);
        end
    end

    --desenhar textos
    love.graphics.setColor(1, 1, 1, 1);
    love.graphics.print(pos.z, 10, 10);
    love.graphics.print(pontos, lar / 2, 10);
    
end

--------------------------FUNCTIONS------------------------------

function newParticle(x, y, z, zspd)
    local particle      = {}
    particle.x          = x;
    particle.y          = y;
    particle.z          = z;
    particle.xspd       = math.random(-50, 50);
    particle.yspd       = math.random(-50, 50);
    particle.maxTime    = math.random(1, 3)
    particle.time       = particle.maxTime;

    return particle;
end

function updateParticle(dt)
    for i, v in ipairs(particleList) do
        local distx = math.sin(v.x / lar - .5) * 10;
        local disty = math.sin(v.y / alt - .5) * 10;

        v.x = (v.x + v.xspd * dt) + distx;
        v.y = (v.y + v.yspd * dt) + disty;
        v.z = v.z + 40 * dt;
        v.time = v.time - 1 * dt;

        if (v.time <= 0) then
            table.remove(particleList, i);
        end
    end
end

function newWall()
    local wall = {}
    wall.x = center.x + math.random(-300, 300);
    wall.y = center.y + math.random(-300, 300);
    wall.z = 0;
    wall.size = 10;

    return wall;
end

function updateWall(dt)
    for i, v in ipairs(wallList) do
        
        local distx = math.sin(v.x / lar - .5) * 10;
        local disty = math.sin(v.y / alt - .5) * 10;

        v.z = v.z + 5 * dt;
        v.x = v.x + distx;
        v.y = v.y + disty;
        v.size = v.size + v.z / 2;

        local collision = (v.x > colBox.x1) and (v.x < colBox.x2) and (v.y > colBox.y1) and (v.y < colBox.y2) and (v.z >= pos.z);

        if (v.z > 25) or (collision == true) then
            table.remove(wallList, i);
        end
    end
end

function newPoint()
    local point = {}
    point.x = center.x + math.random(-50, 50);
    point.y = center.y + math.random(-25, 25);
    point.z = 0;

    return point;
end

function updatePoint(dt)
    for i, v in ipairs(pointList) do

        local distx = math.sin(v.x / lar - .5) * 10;
        local disty = math.sin(v.y / alt - .5) * 10;

        v.z = v.z + 20 * dt;
        v.x = v.x + distx;
        v.y = v.y + disty;

        local collision = (v.x > colBox.x1) and (v.x < colBox.x2) and (v.y > colBox.y1) and (v.y < colBox.y2) and (v.z >= pos.z) and (v.z <= pos.z + 10);

        if (v.z > 200) or (collision == true) then
            table.remove(pointList, i);
            if (collision) then 
                pontos = pontos + 1;
                for i = 0, 5, 1 do
                    table.insert(particleList, newParticle(v.x, v.y, v.z));
                end 
            end
        end
    end
end

function clamp(n1, min, max)
    if (n1 < min) then 
        return min 
    elseif (n1 > max) then
        return max
    else
        return n1
    end
end

function lerp(a, b, t)
	return a + (b - a) * t;
end