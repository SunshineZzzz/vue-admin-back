-- Comment: 消息路由

local lor = require("lor.index")
local messageRouter = lor:Router()
local message = require("app.model.message")

-- 发布消息
messageRouter:post('/publishMessage', message.publishMessage)
-- 编辑消息
messageRouter:post('/editMessage', message.editMessage)
-- 根据发布部门进行搜索消息
messageRouter:post('/searchMessageByDepartment', message.searchMessageByDepartment)
-- 根据接收部门进行搜索消息
messageRouter:post('/searchMessageByReceptDepartment', message.searchMessageByReceptDepartment)
-- 根据发布等级进行获取消息
messageRouter:post('/searchMessageByLevel', message.searchMessageByLevel)
-- 初次删除消息
messageRouter:post('/firstDeleteMessage', message.firstDeleteMessage)
-- 更新消息点击率
messageRouter:post('/updateMessageClick', message.updateMessageClick)
-- 消息还原操作
messageRouter:post('/messageRecover', message.messageRecover)
-- 消息删除操作
messageRouter:post('/messageDelete', message.messageDelete)
-- 获取回收站的列表长度
messageRouter:post('/recycleMessageListLength', message.recycleMessageListLength)
-- 分批获取回收站消息列表
messageRouter:post('/batchRecycleMessageList', message.batchRecycleMessageList)
-- 获取消息列表长度
messageRouter:post('/getMessageListLength', message.getMessageListLength)
-- 分批获取消息列表
messageRouter:post('/batchMessageList', message.batchMessageList)
-- 根据接收部门获取消息列表长度
messageRouter:post('/getMessageListByReceptDepartmentLength', message.getMessageListByReceptDepartmentLength)
-- 根据接收部门分批获取消息列表
messageRouter:post('/batchMessageListByReceptDepartment', message.batchMessageListByReceptDepartment)

return messageRouter