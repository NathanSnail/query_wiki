require("luarocks.loader")
---@class util
local util = require("util")
--TODO: this should allow us to make user queries have a timeout
if false then
	local effil = require("effil")
	local thread = effil.thread(function()
		for _ = 1, 10000 do
			print("multithreaded")
		end
		return 10
	end)()
	print(thread:get(1000, "ms"))
end

local qm = require("query")
local gen = require("generate")("/home/nathan/Documents/code/noitadata/", qm)

local builtin = require("builtin")
builtin(qm, gen)

---@diagnostic disable-next-line: unused-local
local deck_files = qm.filter(gen.files, function(el)
	local contains = string.find(el, "deck") ~= nil
	return contains
end)

print(qm:get("name", "data/entities/animals/longleg.xml"))

--[[print(qm.filter(deck_files, function(el)
	local dmg = qm:get("field", el, "ProjectileComponent", "damage")
	return tonumber(dmg) > 0
end))]]

gen.spell_collection
	:filter(function(card)
		---@cast card expanded_action
		local begun = card.begun_projectiles[1]
		return tonumber(qm:get("field", begun, "ProjectileComponent", "damage")) > 1
	end)
	:map(function(v)
		return v.id
	end)
	:print()

local function runserver()
	local socket = require("cqueues.socket")
	local http_headers = require("http.headers")
	local sock = socket.listen("127.0.0.1", 8000)
	local http_server = require("http.server")
	local onstream = function(_, stream)
		local req_headers = assert(stream:get_headers())
		local req_method = req_headers:get(":method")

		print(
			string.format(
				'[%s] "%s %s HTTP/%g"  "%s" "%s"\n',
				os.date("%d/%b/%Y:%H:%M:%S %z"),
				req_method or "",
				req_headers:get(":path") or "",
				stream.connection.version,
				req_headers:get("user-agent") or "-"
			)
		)

		local res_headers = http_headers.new()
		res_headers:append(":status", "200")
		res_headers:append("content-type", "text/plain")
		-- Send headers to client; end the stream immediately if this was a HEAD request
		stream:write_headers(res_headers, req_method == "HEAD")
		if req_method == "HEAD" then
			return
		end
		-- Send body, ending the stream
		stream:write_chunk("Hello world!\n", true)
	end
	http_server.onstream = onstream
	http_server.tls = false
	http_server.socket = sock
	local serv = http_server:new()
	serv:listen(1000)
	-- serv:loop()
end

runserver()
