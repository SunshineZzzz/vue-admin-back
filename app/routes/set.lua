-- Comment: 设置路由

local lor = require("lor.index")
local setRouter = lor:Router()
local set = require("app.model.set")

-- 上传轮播图
setRouter:post('/uploadSwiper', set.uploadSwiper)
-- 上传公司介绍图片
setRouter:post('/uploadCompanyIntroducePicture', set.uploadCompanyIntroducePicture)
-- 获取所有轮播图
setRouter:post('/getAllSwiper', set.getAllSwiper)
-- 获取公司名称
setRouter:post('/getCompanyName', set.getCompanyName)
-- 改变公司名称
setRouter:post('/changeCompanyName', set.changeCompanyName)
-- 编辑公司介绍的接口
setRouter:post('/changeCompanyIntroduce', set.changeCompanyIntroduce)
-- 获取公司介绍
setRouter:post('/getCompanyIntroduce', set.getCompanyIntroduce)
-- 获取所有公司信息
setRouter:post('/getAllCompanyInfo', set.getAllCompanyInfo)
-- 部门设置
setRouter:post('/setDepartment', set.setDepartment)
-- 获取部门
setRouter:post('/getDepartment', set.getDepartment)
-- 产品设置
setRouter:post('/setProduct', set.setProduct)
-- 获取产品
setRouter:post('/getProduct', set.getProduct)

return setRouter