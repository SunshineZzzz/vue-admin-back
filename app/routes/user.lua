-- Comment: 用户路由

local lor = require("lor.index")
local userRouter = lor:Router()
local user = require("app.model.user")

-- 上传头像
userRouter:post("/uploadAvatar", user.upload_avatar)
-- 修改密码
userRouter:post("/changePassword", user.change_password)
-- 获取用户信息
userRouter:post("/getUserInfo", user.get_userinfo)
-- 修改姓名
userRouter:post('/changeName', user.change_name)
-- 修改性别
userRouter:post('/changeSex', user.change_sex)
-- 修改邮箱
userRouter:post('/changeEmail', user.change_email)
-- 以下是用户管理相关
-- 添加管理员
userRouter:post('/createAdmin', user.createAdmin)
-- 获取对应身份的总数
userRouter:post('/getIdentityNumber', user.getIdentityNumber)
-- 编辑管理员账号信息
userRouter:post('/editAdmin', user.editAdmin)
-- 修改用户身份
userRouter:post('/changeIdentity', user.changeIdentity)
-- 通过账号对用户搜索
userRouter:post('/searchUser', user.searchUser)
-- 通过部门对用户搜索
userRouter:post('/searchUserByDepartment', user.searchUserByDepartment)
-- 冻结用户
userRouter:post('/banUser', user.banUser)
-- 解冻用户
userRouter:post('/hotUser', user.hotUser)
-- 获取冻结用户列表
userRouter:post('/getBanList', user.getBanList)
-- 删除用户
userRouter:post('/deleteUser', user.deleteUser)
-- 分批获取用户
userRouter:post('/batchGetUser', user.batchGetUser)

return userRouter