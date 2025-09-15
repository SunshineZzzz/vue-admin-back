-- Comment: 操作日志路由

local lor = require("lor.index")
local oLogRouter = lor:Router()
local oLog = require("app.model.oLog")

-- 获取操作日志类别
oLogRouter:post('/getOLogType', oLog.getOLogType)
-- 获取操作日志长度
oLogRouter:post('/getOLogListLength', oLog.getOLogListLength)
-- 分批获取操作日志列表
oLogRouter:post('/batchGetOLogList', oLog.batchGetOLogList)
-- 清空操作日志
oLogRouter:post('/clearOLogList', oLog.clearOLogList)
-- 按类型获取操作日志列表
oLogRouter:post('/searchOLogListByType', oLog.searchOLogListByType)

return oLogRouter
