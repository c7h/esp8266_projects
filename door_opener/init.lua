--door opener :)

--connect to wifi
wifi.setmode(wifi.STATION)
wifi.sta.config("berlin.freifunk.net", "")
wifi.sta.connect()

--setings
user = "c7h" -- adafruit username
auth = "3c7febbe94aae00ab677029c6e98ac0295d35fbb" -- adadruit io auth key
feed_key = "door-openings"
topic = user .. "/feeds/" .. feed_key
cleansession = 1
duration = 5000 -- how long should the door buzz in ms
shared_secret = "&*^!a24^6" -- secret that need to be attached on every command
door_gpio = 3

gpio.write(door_gpio, gpio.HIGH)
tmr.register(0, duration, tmr.ALARM_SEMI, function() gpio.write(door_gpio, gpio.HIGH) end)

received_message = function(client, topic, data)
	if data ~= nil then
		print("received a message on topic "..topic..":["..data.."]")
		if data == "open$"..shared_secret then
			print("###opening door###")
            gpio.write(door_gpio, gpio.LOW) -- open
			tmr.start(0) -- set timeout
		elseif data == "release" then
			tmr.stop(0)
			gpio.write(door_gpio, gpio.HIGH)
		end
	end
end


-- creating listener
m = mqtt.Client("esp8266_clickbeetle", 120, user, auth, cleansession)

on_connect_success = function(conn) 
  print("connected")
  -- stop reconnect loop
  tmr.stop(2)
  tmr.unregister(2)
  -- subscribe topic with qos = 0
  m:subscribe(topic,0, function(conn) 
    -- publish a message with data = my_message, QoS = 0, retain = 0
    m:publish(topic,"hello world from chip "..node.chipid(),0,0, function(conn) 
      print("successfully subscribed") 
    end)
  end)
end

on_connect_failure = function(conn, message)
	print("connection failed: " .. message)
end

m:on("offline", function(con) print("offline") end)
m:on("message", received_message)

net.dns.resolve("io.adafruit.com", function(sk, ip)
    if (ip == nil) then print("DNS fail!") else broker_ip = ip end
end)

tmr.alarm(2, 3000, tmr.ALARM_AUTO,
    function()
        m:connect(broker_ip, 1883, 0, on_connect_success, on_connect_failure)
    end
)
