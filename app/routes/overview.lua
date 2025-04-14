-- Comment: 总览路由

local lor = require("lor.index")
local overviewRouter = lor:Router()
local overview = require("app.model.overview")

-- 获取产品类别和其总价
overviewRouter:post('/getCategoryAndTotalPrice', overview.getCategoryAndTotalPrice)
-- 获取不同身份和其数量
overviewRouter:post('/getIdentityAndNumber', overview.getIdentityAndNumber)
-- 获取不同消息等级与数量
overviewRouter:post('/getLevelAndNumber', overview.getLevelAndNumber)
-- 获取每天登录人数
overviewRouter:post('/getDayAndNumber', overview.getDayAndNumber)

return overviewRouter