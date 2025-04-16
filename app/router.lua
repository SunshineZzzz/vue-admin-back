-- Comment: 路由管理相关

local loginRouter = require("app.routes.login")
local userRouter = require("app.routes.user")
local setRouter = require("app.routes.set")
local messageRouter = require("app.routes.message")
local dmRouter = require("app.routes.department_msg")
local overviewRouter = require("app.routes.overview")

return function(app)
	app:get("/", function(req, res, next)
		local data = {
			name =  req.query.name or "lor",
			desc =  req.query.desc or 'a framework of lua based on OpenResty'
		}
		res:render("index", data)
	end)

	app:use("/login", loginRouter())
	app:use("/user", userRouter())
	app:use("/set", setRouter())
	app:use("/message", messageRouter())
	app:use("/dm", dmRouter())
	app:use("/overview", overviewRouter())
end

