-- Comment: 路由管理相关

local loginRouter = require("app.routes.login")
-- local userRouter = require("app.routes.user")

return function(app)
	-- simple router: render html, visit "/" or "/?name=foo&desc=bar
	app:get("/", function(req, res, next)
		local data = {
			name =  req.query.name or "lor",
			desc =  req.query.desc or 'a framework of lua based on OpenResty'
		}
		res:render("index", data)
	end)

	app:use("/login", loginRouter())
	-- group router: 对以`/user`开始的请求做过滤处理
	-- app:use("/user", userRouter())
end

