--[[
    Copyright (C) 2014 Dragino Technology Co., Limited

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0
]]--

module("luci.controller.arduino.sensor", package.seeall)

local util = require("luci.util")
local fs = require("luci.fs")
local ix = util.exec("LANG=en ifconfig wlan0")
local mac = ix and ix:match("HWaddr ([^%s]+)")
mac = string.gsub(mac,":","")

local server_t = { cumulocity={has_tenant=1,has_user=1,has_api=1,has_pass=1,has_gid=1}
			}

function index()
	entry({ "webpanel" , "sensor"}, call("config") ,nil)
end

local function get_service()
	local f = fs.dir('/usr/lib/lua/dragino/iot')
	local service ={}
	for k,v in pairs(f) do
		local n = string.match(v,"(.+)%.lua")
		if n ~= nil then
			service[#service+1]=n
		end
	end
	return service
end 


local function not_nil_or_empty(value)
  return value and value ~= ""
end

local function config_get()
  local uci = luci.model.uci.cursor()
  uci:load("iot")
  uci:load("arduino")
  local devicename = uci:get_first("iot","settings","DeviceName") or "DRAGINO-"..mac

  local debug_list = {}
  debug_list[1] = { code = "0", label = "Disable" }
  debug_list[2] = { code = "1", label = "Level 1" }
  debug_list[3] = { code = "2", label = "Level 2" }

  local uartmode_list = {}
  uartmode_list[1] = { code = "bridge", label = "Arduino Bridge" }
  uartmode_list[2] = { code = "passthrough", label = "Pass Through" }
  uartmode_list[3] = { code = "control", label = "Control" }
  uartmode_list[4] = { code = "beeconsole", label = "Bee Console" }

  local board_type = {}
  board_type[1] = { code = "leonardo", label = "Leonardo, M32, M32W" }
  board_type[2] = { code = "uno", label = "Arduino Uno w/ATmega328P" }
  board_type[3] = { code = "duemilanove328", label = "Arduino Duemilanove or Diecimila w/ATmega328" }
  board_type[4] = { code = "duemilanove168", label = "Arduino Duemilanove or Diecimila w/ATmega168,MRFM12B" }
  board_type[5] = { code = "mega2560", label = "Arduino Mega2560" }

  local uploadtype_list = {}
  uploadtype_list[1] = { code = "numerical", label = "Numerical" }
  uploadtype_list[2] = { code = "gps", label = "GPS" }
  uploadtype_list[3] = { code = "generic", label = "Generic" }

  local sensor_unit={}
  uci:foreach("iot","sensor",
	function(section)
		local cell = {}
		cell["remoteid"]=section.remoteid
		cell["type"]=section.type
		cell["uploadtype"] = section.uploadtype
		cell["pattern"] = section.pattern
		sensor_unit[section[".name"]] = cell
	end)

  local ctx = {
	server_t = server_t,
	service_available = get_service(),
	uartmode = uci:get_first("iot","settings","uartmode"),
	uartbaud = tonumber(uci:get_first("iot","settings","uartbaud")),
	server = uci:get_first("iot","settings","server"),
	deviceid = uci:get_first("iot","settings","deviceid"),
	tenant = uci:get_first("iot","settings","tenant"),
	user = uci:get_first("iot","settings","user"),
	pass = uci:get_first("iot","settings","pass"),
	apikey = uci:get_first("iot","settings","ApiKey"),
	uploadtype_list = uploadtype_list,
	board = uci:get("arduino","mcu","board"),
	board_type = board_type,
	debug_list = debug_list,
	uartmode_list = uartmode_list,
	debuglevel = uci:get_first("iot","settings","debug"),
	devicename = devicename,
	sensor_unit = sensor_unit,
	globalid = uci:get_first("iot","settings","GlobalID"),
  }

  luci.template.render("dragino/sensor", ctx)
end

local function config_post()
  local uci = luci.model.uci.cursor()
  uci:load("iot")
  uci:load("arduino")

  if luci.http.formvalue("board") then
    uci:set("arduino", "mcu", "board", luci.http.formvalue("board"))
  end

  if luci.http.formvalue("server") then
    uci:set("iot", "general", "server", luci.http.formvalue("server"))
  end

  if luci.http.formvalue("deviceid") then
    uci:set("iot", "general", "deviceid", luci.http.formvalue("deviceid"))
  end

  if luci.http.formvalue("uartmode") then
    uci:set("iot", "general", "uartmode", luci.http.formvalue("uartmode"))
  end

  if luci.http.formvalue("uartbaud") then
    uci:set("iot", "general", "uartbaud", luci.http.formvalue("uartbaud"))
  end


  if luci.http.formvalue("tenant") then
    uci:set("iot", "general", "tenant", luci.http.formvalue("tenant"))
  end
  if luci.http.formvalue("user") then
    uci:set("iot", "general", "user", luci.http.formvalue("user"))
  end
  if luci.http.formvalue("pass") then
    uci:set("iot", "general", "pass", luci.http.formvalue("pass"))
  end
  if luci.http.formvalue("apikey") then
    uci:set("iot", "general", "ApiKey", luci.http.formvalue("apikey"))
  end
  if luci.http.formvalue("debuglevel") then
    uci:set("iot", "general", "debug", luci.http.formvalue("debuglevel"))
  end

  local dn = luci.http.formvalue("devicename")
  devicename = not_nil_or_empty(dn) and dn or 'DRAGINO-'..mac
  uci:set("iot", "general", "DeviceName", devicename)

  uci:foreach("iot","sensor",
  	function(section)	
		local v = luci.http.formvalue("port_"..section[".name"].."_id")
		if v then
			local rm = luci.http.formvalue("port_"..section[".name"].."_remove")
			uci:set("iot",section[".name"],"type",luci.http.formvalue("port_"..section[".name"].."_type") or '')
			uci:set("iot",section[".name"],"uploadtype",luci.http.formvalue("port_"..section[".name"].."_uploadtype") or '')
			uci:set("iot",section[".name"],"pattern",luci.http.formvalue("port_"..section[".name"].."_pattern") or '')
			if v == "" or rm == "remove" then
				uci:delete("iot",section[".name"])		
			else 
				uci:set("iot",section[".name"],"remoteid",luci.http.formvalue("port_"..section[".name"].."_id"))
			end
		end
  	end)

  local new_port_name = luci.http.formvalue("new_port_name")

  if new_port_name and new_port_name ~= "-" and luci.http.formvalue("new_port_remoteid") ~= "" then
	local new_port = {}
	new_port["remoteid"]=luci.http.formvalue("new_port_remoteid")
	new_port["type"]=luci.http.formvalue("new_port_type")
	new_port["uploadtype"]=luci.http.formvalue("new_port_uploadtype")
	new_port["pattern"]=luci.http.formvalue("new_port_pattern")
	uci:section("iot","sensor",new_port_name,new_port)
  end


  uci:commit("iot")
  uci:commit("arduino")

  os.execute("/etc/init.d/dragino.init restart")
  luci.util.exec("/usr/bin/reset-mcu")
  config_get()
end

function config()
  if luci.http.getenv("REQUEST_METHOD") == "POST" then
    config_post()
  else
    config_get()
  end
end
