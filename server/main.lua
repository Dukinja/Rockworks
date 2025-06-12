local enet = require("enet")

local host = enet.host_create("*:12345")

local clients = {}

local next_id = 1

function love.load()

love.window.setMode(350, 180, {resizable = false})
love.window.setTitle("Duke's Dedicated Hybrid Server")

end

function love.update(dt)

    local event = host:service()

    while event do
	
        if event.type == "connect" then
		
            clients[event.peer] = { x = 150, y = 150, username = "Player" }
            
        elseif event.type == "receive" then
		
            local data = event.data
            local uname, x, y = data:match("([^,]+),(-?%d+%.?%d*),(-?%d+%.?%d*)")
            x, y = tonumber(x), tonumber(y)

            if uname and x and y then
			
                clients[event.peer].x = x
                clients[event.peer].y = y
                clients[event.peer].username = uname
				
            end

        elseif event.type == "disconnect" then
		
            clients[event.peer] = nil
			
        end

        event = host:service()
		
    end

    for peer, _ in pairs(clients) do
	
        local data = ""

        for other_peer, info in pairs(clients) do
		
            if other_peer ~= peer then
			
                data = data .. info.username .. "," .. info.x .. "," .. info.y .. ";"
				
            end
			
        end

        peer:send(data)
		
    end
	
end

function love.draw()

love.graphics.print("Server Starting...", 10, 10)
love.graphics.print("Server Started!", 10, 30)
love.graphics.print("Server Running.", 10, 50)

end
