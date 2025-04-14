-- Comment: 消息路由

local lor = require("lor.index")
local messageRouter = lor:Router()
local message = require("app.model.message")

-- 发布消息
messageRouter:post('/publishMessage', message.publishMessage)
-- 获取消息列表
messageRouter:post('/batchMessageList', message.batchMessageList)

return messageRouter