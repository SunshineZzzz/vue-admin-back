-- Comment: 登录路由

local lor = require("lor.index")
local loginRouter = lor:Router()
local login = require("app.model.login")

-- 注册
loginRouter:post("/register", login.register)
-- 登录
loginRouter:post('/login', login.login)

return loginRouter
