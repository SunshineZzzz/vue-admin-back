-- Comment: 部门消息

local lor = require("lor.index")
local dmRouter = lor:Router()
local dm = require("app.model.department_msg")

-- 获取用户部门消息ids
dmRouter:post('/getUserDepartmentIds', dm.getUserDepartmentIds)
-- 根据Ids获取部门消息
dmRouter:post('getDepartmentMsgByIds', dm.getDepartmentMsgByIds)

return dmRouter
