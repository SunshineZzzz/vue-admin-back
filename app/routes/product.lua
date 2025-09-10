-- Comment: 产品路由

local lor = require("lor.index")
local productRouter = lor:Router()
local product = require("app.model.product")

-- 产品入库
productRouter:post('/createProduct', product.createProduct)
-- 删除产品
productRouter:post('/deleteProduct', product.deleteProduct)
-- 编辑产品信息
productRouter:post('/editProduct', product.editProduct)
-- 产品申请出库
productRouter:post('/applyOutProduct', product.applyOutProduct)
-- 对产品进行撤回申请
productRouter:post('/withdrawApplyProduct', product.withdrawApplyProduct)
-- 产品审核
productRouter:post('/auditProduct', product.auditProduct)
-- 通过入库编号对产品进行搜索
productRouter:post('/searchProductForId', product.searchProductForId)
-- 获取产品总数
productRouter:post('/getProductLength', product.getProductLength)
-- 获取申请出库产品总数
productRouter:post('/getApplyProductLength', product.getApplyProductLength)
-- 获取出库产品总数
productRouter:post('/getOutProductLength', product.getOutProductLength)
-- 分批获取产品列表
productRouter:post('/batchGetProductList', product.batchGetProductList)
-- 分批获取申请出库产品列表
productRouter:post('/batchGetApplyProductList', product.batchGetApplyProductList)
-- 分批获取出库产品列表
productRouter:post('/batchGetOutProductList', product.batchGetOutProductList)

return productRouter