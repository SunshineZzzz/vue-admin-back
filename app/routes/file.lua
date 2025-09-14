-- Comment: 文件路由

local lor = require("lor.index")
local fileRouter = lor:Router()
local file = require("app.model.file")

-- 上传文件
fileRouter:post("/uploadFile", file.uploadFile)
-- 更新下载次数
fileRouter:post('/updateDownloadNum', file.updateDownloadNum)
-- 获取文件列表总数
fileRouter:post('/fileListLength', file.fileListLength)
-- 分批获取文件列表
fileRouter:post('/batchGetFileList', file.batchGetFileList)
-- 根据文件名搜索文件
fileRouter:post('/searchFileByName', file.searchFileByName)
-- 删除文件
fileRouter:post('/deleteFile', file.deleteFile)

return fileRouter
