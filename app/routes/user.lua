local lor = require("lor.index")
local userRouter = lor:Router()
local user = require("app.model.user")

-- 上传头像
userRouter:post("/uploadAvatar", user.upload_avatar)

return userRouter