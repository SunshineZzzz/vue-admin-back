-- Comment: 登录路由

local lor = require("lor.index")
local loginRouter = lor:Router()
local login = require("app.model.login")

-- 注册
loginRouter:post("/register", login.register)
-- 登录
loginRouter:post('/login', login.login)
-- 验证账号与邮箱
loginRouter:post('/verifyAccountAndEmail', login.verify_accountandemail)
-- 登录页面修改密码
loginRouter:post('/changePasswordInLogin', login.change_passwordinlogin)

return loginRouter
