-- Comment: 登录路由

local lor = require("lor.index")
local loginRouter = lor:Router()
local login = require("app.model.login")

-- 注册
loginRouter:post("/register", function(req, res, next)
	login.register(req, res, next)
end)

-- 登录
loginRouter:post('/login', function(req, res, next)
	login.login(req, res, next)
end)

return loginRouter
