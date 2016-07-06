--init.lua

---connect to wifi
wifi.setmode(wifi.STATION)
wifi.sta.config("YourSSID","WiFiPassword")
wifi.sta.connect()

-- settings
user = "username" -- adafruit username
auth = "deadbeefacabacabacabacacabacabacabacabaa" -- adadruit io auth key
feed_key = "esp8266-lightsensor"
topic = user .. "/feeds/" .. feed_key
cleansession = 1
interval = 5000 -- update interval in ms

-- do mqtt magic...
m = mqtt.Client("esp8266_clickbeetle", 120, user, auth, cleansession)

m:connect("io.adafruit.com", 1883, 0, function(conn) print("connected") end)

publish_sucess = function (value)
	print("published value " .. value .. " to " .. topic)
end

get_brightness = function ()
	-- body
	return adc.read(0) --LDR connected to gpio0 using pulldown
end

send_payload = function ()
	-- body
	payload = get_brightness()
	m:publish(topic, payload, 0, 0, publish_sucess(payload))
end

tmr.alarm(0, interval, 1, send_payload)

m:close();