-- Comment: 产品业务

local http_ok = ngx.HTTP_OK
local http_bad_request = ngx.HTTP_BAD_REQUEST
local http_inner_error = ngx.HTTP_INTERNAL_SERVER_ERROR
local ngx_log = ngx.log
local ngx_info = ngx.INFO
local ngx_err = ngx.ERR
local os_time = os.time
local tonumber = tonumber
local config = require("app.config.config")
local mysql_config = config.mysql
local mysql = require("lor.lib.utils.mysql")
local define_product_status = require("app.config.define").product_status
local create_product_code = require("app.config.return_code").create_product
local delete_product_code = require("app.config.return_code").delete_product
local edit_product_code = require("app.config.return_code").edit_product
local apply_out_product_code = require("app.config.return_code").apply_out_product
local withdraw_apply_product_code = require("app.config.return_code").withdraw_apply_product
local audit_product_code = require("app.config.return_code").audit_product
local get_productListForId_code = require("app.config.return_code").get_productListForId
local get_productLength_code = require("app.config.return_code").get_productLength
local get_applyOutProductLength_code = require("app.config.return_code").get_applyOutProductLength
local get_outProductLength_code = require("app.config.return_code").get_outProductLength
local batch_getProductList_code = require("app.config.return_code").batch_getProductList
local batch_get_applyProductList_code = require("app.config.return_code").batch_get_applyProductList
local batch_get_outProductList_code = require("app.config.return_code").batch_get_outProductList
local define_log_type = require("app.config.define").log_type
local define_log_level = require("app.config.define").log_level
local lor_utils = require("lor.lib.utils.utils")
local utils = require("app.utils.utils")

local M = {}

-- 产品入库
function M.createProduct(req, res, next)
    local id = req.jwt.id
	local numberId = req.body.numberId
	local category = req.body.category
	local name = req.body.name
	local unit = req.body.unit
	local quantity = req.body.quantity
	local price = req.body.price
    local remark = req.body.remark

    if not numberId or not category or not name or not unit or not quantity or not price or not remark then
        res:status(http_bad_request):json(create_product_code.params_error)
        ngx_log(ngx_err, "product model create product params error")
        return
    end

    local mdb, err = mysql:new(mysql_config)
    if not mdb then
        res:status(http_inner_error):json(create_product_code.db_error)
        ngx_log(ngx_err, "product model create product mysql:new() error:", err)
        return
    end

    local ress, err = mdb:insert("insert into `product` set `number`=?,`category`=?,`name`=?,`unit`=?,`quantity`=?,`out_quantity`=0,`price`=?,`user_id`=?,`update_user_id`=?,`out_user_id`=0,`create_time`=?,`update_time`=?,`apply_out_time`=0,`out_time`=0,`status`=?,`remark`=?", 
        numberId, category, name, unit, tonumber(quantity), tonumber(price), id, id, os_time(), os_time(), define_product_status.normal, remark)
    if not ress then
        res:status(http_ok):json(create_product_code.create_error)
        ngx_log(ngx_err, "product model create product insert product error:", err)
        return
    end

    res:status(http_ok):json(create_product_code.success)
    ngx_log(ngx_info, "product model create product success")
end

-- 删除产品
function M.deleteProduct(req, res, next)
    local numberId = req.body.numberId

    if not numberId then
        res:status(http_bad_request):json(delete_product_code.params_error)
        ngx_log(ngx_err, "product model delete product params error")
        return
    end

    local mdb, err = mysql:new(mysql_config)
    if not mdb then
        res:status(http_inner_error):json(delete_product_code.db_error)
        ngx_log(ngx_err, "product model delete product mysql:new() error:", err)
        return
    end

    local ress, err = mdb:delete("delete from `product` where `number`=?", numberId)
    if not ress then
        res:status(http_inner_error):json(delete_product_code.delete_error)
        ngx_log(ngx_err, "product model delete product delete product error:", err)
        return
    end

    res:status(http_ok):json(delete_product_code.success)
    ngx_log(ngx_info, "product model delete product success")
end

-- 编辑产品信息
function M.editProduct(req, res, next)
    local id = req.jwt.id
	local numberId = req.body.numberId
	local category = req.body.category
	local name = req.body.name
	local unit = req.body.unit
	local quantity = req.body.quantity
	local price = req.body.price
    local remark = req.body.remark

    if not numberId or not category or not name or not unit or not quantity or not price or not remark then
        res:status(http_bad_request):json(edit_product_code.params_error)
        ngx_log(ngx_err, "product model edit product params error")
        return
    end

    local mdb, err = mysql:new(mysql_config)
    if not mdb then
        res:status(http_inner_error):json(edit_product_code.db_error)
        ngx_log(ngx_err, "product model edit product mysql:new() error:", err)
        return
    end

    local ress, err = mdb:update("update `product` set `category`=?,`name`=?,`unit`=?,`quantity`=?,`price`=?,`update_user_id`=?,`update_time`=?,`remark`=? where `number`=?", 
        category, name, unit, tonumber(quantity), tonumber(price), id, os_time(), remark, numberId)
    if not ress or ress[1].affected_rows ~= 1 then
        res:status(http_inner_error):json(edit_product_code.edit_error)
        ngx_log(ngx_err, "product model edit product update product error:", err)
        return
    end

    res:status(http_ok):json(edit_product_code.success)
    ngx_log(ngx_info, "product model edit product success")
end

-- 产品申请出库
function M.applyOutProduct(req, res, next)
    local id = req.jwt.id
	local numberId = req.body.numberId
	local quantity = req.body.quantity
    local remark = req.body.remark

    if not numberId or not quantity or not remark then
        res:status(http_bad_request):json(apply_out_product_code.params_error)
        ngx_log(ngx_err, "product model apply out product params error")
        return
    end

    local mdb, err = mysql:new(mysql_config)
    if not mdb then
        res:status(http_inner_error):json(apply_out_product_code.db_error)
        ngx_log(ngx_err, "product model apply out product mysql:new() error:", err)
        return
    end

    local ress, err = mdb:update("update `product` set `out_quantity`=?,`out_user_id`=?,`apply_out_time`=?,`remark`=?,`status`=? where `number`=? and `quantity`>=? and `status`=? or `status`=?", 
        tonumber(quantity), id, os_time(), remark, define_product_status.applying, numberId, tonumber(quantity), define_product_status.normal, define_product_status.rejectApply)
    if not ress or ress[1].affected_rows ~= 1 then
        res:status(http_ok):json(apply_out_product_code.apply_error)
        ngx_log(ngx_err, "product model apply out product update product error:", err)
        return
    end

    res:status(http_ok):json(apply_out_product_code.success)
    ngx_log(ngx_info, "product model apply out product success")
end

-- 对产品进行撤回申请
function M.withdrawApplyProduct(req, res, next)
    local id = req.jwt.id
    local numberId = req.body.numberId

    if not numberId then
        res:status(http_bad_request):json(withdraw_apply_product_code.params_error)
        ngx_log(ngx_err, "product model withdraw apply product params error")
        return
    end

    local mdb, err = mysql:new(mysql_config)
    if not mdb then
        res:status(http_inner_error):json(withdraw_apply_product_code.db_error)
        ngx_log(ngx_err, "product model withdraw apply product mysql:new() error:", err)
        return
    end

    local ress, err = mdb:update("update `product` set `update_user_id`=?,`update_time`=?,`status`=? where `number`=? and `status`=?", 
        id, os_time(), define_product_status.normal, numberId, define_product_status.applying)
    if not ress or ress[1].affected_rows ~= 1 then
        res:status(http_inner_error):json(withdraw_apply_product_code.apply_error)
        ngx_log(ngx_err, "product model withdraw apply product update product error:", err)
        return
    end

    res:status(http_ok):json(withdraw_apply_product_code.success)
    ngx_log(ngx_info, "product model withdraw apply product success")
end

-- 产品审核
function M.auditProduct(req, res, next)
    local id = req.jwt.id
    local name = req.body.name
    local numberId = req.body.numberId
    local status = req.body.status
    local remark = req.body.remark

    if not name or not numberId or not status or not remark then
        res:status(http_bad_request):json(audit_product_code.params_error)
        ngx_log(ngx_err, "product model audit product params error1")
        return
    end

    if status ~= "同意" and status ~= "拒绝" then
        res:status(http_bad_request):json(audit_product_code.params_error)
        ngx_log(ngx_err, "product model audit product params error2")
        return
    end

    local mdb, err = mysql:new(mysql_config)
    if not mdb then
        res:status(http_inner_error):json(audit_product_code.db_error)
        ngx_log(ngx_err, "product model audit product mysql:new() error:", err)
        return
    end

    if status == "同意" then
        local mysql_driver, err = mdb:begin()
	    if not mysql_driver then
	        res:status(http_inner_error):json(audit_product_code.db_error)
	        ngx_log(ngx_err, "product model audit(yes) product mysql:begin() error:", err)
	        return
	    end
        
        local ress, err = mdb:tx_update(mysql_driver, "insert into `out_product` (`number`,`category`,`name`,`unit`,`quantity`,`price`,`user_id`,`out_user_id`,`out_time`,`apply_out_time`,`remark`) select `number`,`category`,`name`,`unit`,`out_quantity`,`price`,?,`out_user_id`,?,`apply_out_time`,? from `product` where `number`=? and `quantity`>=`out_quantity` and `status`=?",
            id, os_time(), remark, numberId, define_product_status.applying)
        if not ress then
            res:status(http_inner_error):json(audit_product_code.audit_error)
            ngx_log(ngx_err, "product model audit(yes) product insert out out_product error1:", err)
            return
        end

        if ress[1].affected_rows ~= 1 then
            local _, err = mdb:rollback(mysql_driver)
            res:status(http_inner_error):json(audit_product_code.audit_error)
            ngx_log(ngx_err, "product model audit(yes) product insert out out_product error2:", err, ", affected_rows:", ress[1].affected_rows)
            return
        end

        ress, err = mdb:tx_update(mysql_driver, "update `product` set `quantity`=`quantity`-`out_quantity`,`out_quantity`=0,`update_user_id`=?,`update_time`=?,`out_time`=?,`status`=?,`remark`=? where `number`=? and `quantity`>=`out_quantity` and `status`=?",
            id, os_time(), os_time(), define_product_status.normal, remark, numberId, define_product_status.applying)
        if not ress then
            res:status(http_inner_error):json(audit_product_code.audit_error)
            ngx_log(ngx_err, "product model audit(yes) product update product error1:", err)
            return
        end

        if ress[1].affected_rows ~= 1 then
            local _, err = mdb:rollback(mysql_driver)
            res:status(http_inner_error):json(audit_product_code.audit_error)
            ngx_log(ngx_err, "product model audit(yes) product update product error2:", err, ", affected_rows:", ress[1].affected_rows)
            return
        end

        local ok, err = mdb:commit(mysql_driver)
        if not ok then
            res:status(http_inner_error):json(audit_product_code.audit_error)
            ngx_log(ngx_err, "product model audit(yes) product commit error:", err)
            return
        end
    else
        local ress, err = mdb:update("update `product` set `update_user_id`=?,`update_time`=?,`status`=?,`remark`=? where `number`=? and `status`=?", 
            id, os_time(), define_product_status.rejectApply, remark, numberId, define_product_status.applying)
        if not ress or ress[1].affected_rows ~= 1 then
            res:status(http_inner_error):json(audit_product_code.audit_error)
            ngx_log(ngx_err, "product model audit(no) product update product error2:", err, ", affected_rows:", ress[1].affected_rows)
            return
        end
    end

    res:status(http_ok):json(audit_product_code.success)
    local content = lor_utils.json_encode(req.body)
    ngx_log(ngx_info, "product model audit product success, content:", content)

    res:eof()

	-- 记录审核日志
	local _, err = mdb:insert("insert into `log` set `user_id`=?,`name`=?,`category`=?,`content`=?,`time`=?,`level`=?", id, name, define_log_type.product_audit, content, os_time(), define_log_level.high)
	if err then
		ngx_log(ngx_err, "product model audit product insert log error:", err)
	end
end

-- 通过入库编号对产品进行搜索
function M.searchProductForId(req, res, next)
    local numberId = req.body.numberId
    local sType = tonumber(req.body.sType)

    if not numberId or not sType then
        res:status(http_bad_request):json(get_productListForId_code.params_error)
        ngx_log(ngx_err, "product model search product for id params error1")
        return
    end

    local statusStr, err = utils.swicth_product_sType(sType)
    if err then
        res:status(http_bad_request):json(get_productListForId_code.params_error)
        ngx_log(ngx_err, "product model search product for id params error2")
        return
    end

    local mdb, err = mysql:new(mysql_config)
    if not mdb then
        res:status(http_inner_error):json(get_productListForId_code.db_error)
        ngx_log(ngx_err, "product model search product for id mysql:new() error:", err)
        return
    end

    if not statusStr then
        local ress, err = mdb:select("select p.*,ifnull(u1.name,'') as `user_name`,ifnull(u2.name,'') as `out_user_name` from `out_product` as `p` left join `users` as `u1` on p.user_id = u1.id left join `users` as `u2` on p.out_user_id = u2.id where p.number=?", numberId)
        if not ress then
            res:status(http_inner_error):json(get_productListForId_code.db_error)
            ngx_log(ngx_err, "product model search product for id select product error1:", err)
            return
        end

        get_productListForId_code.gen_success_data_out(get_productListForId_code.success.data, ress[1])
        res:status(http_ok):json(get_productListForId_code.success)
        ngx_log(ngx_info, "product model search product for id success1")
        return
    end

    local ress, err = mdb:select("select p.*,ifnull(u1.name,'') as `user_name`,ifnull(u2.name,'') as `update_user_name`,ifnull(u3.name,'') as `out_user_name` from `product` as `p` left join `users` as `u1` on p.user_id = u1.id left join `users` as `u2` on p.update_user_id = u2.id left join `users` as `u3` on p.out_user_id = u3.id where p.number=? and p.status in(?)", numberId, statusStr)
    if not ress then
        res:status(http_inner_error):json(get_productListForId_code.db_error)
        ngx_log(ngx_err, "product model search product for id select product error2:", err)
        return
    end

    get_productListForId_code.gen_success_data(get_productListForId_code.success.data, ress[1][1])
    res:status(http_ok):json(get_productListForId_code.success)
    ngx_log(ngx_info, "product model search product for id success2")
end

-- 获取产品总数
function M.getProductLength(req, res, next)
    local mdb, err = mysql:new(mysql_config)
    if not mdb then
        res:status(http_inner_error):json(get_productLength_code.db_error)
        ngx_log(ngx_err, "product model get product length mysql:new() error:", err)
        return
    end

    local ress, err = mdb:select("select count(*) as c from `product` where `status`!=?", define_product_status.agreeApply)
    if not ress then
        res:status(http_inner_error):json(get_productLength_code.db_error)
        ngx_log(ngx_err, "product model get product length select product error:", err)
        return
    end

    get_productLength_code.gen_success_data(get_productLength_code.success.data, ress[1][1])
    res:status(http_ok):json(get_productLength_code.success)
    ngx_log(ngx_info, "product model get product length success")
end

-- 获取申请出库产品总数
function M.getApplyProductLength(req, res, next)
    local mdb, err = mysql:new(mysql_config)
    if not mdb then
        res:status(http_inner_error):json(get_applyOutProductLength_code.db_error)
        ngx_log(ngx_err, "product model get apply out product length mysql:new() error:", err)
        return
    end

    local ress, err = mdb:select("select count(*) as c from `product` where `status`=? or `status`=?", define_product_status.applying, define_product_status.rejectApply)
    if not ress then
        res:status(http_inner_error):json(get_applyOutProductLength_code.db_error)
        ngx_log(ngx_err, "product model get apply out product length select product error:", err)
        return
    end

    get_applyOutProductLength_code.gen_success_data(get_applyOutProductLength_code.success.data, ress[1][1])
    res:status(http_ok):json(get_applyOutProductLength_code.success)
    ngx_log(ngx_info, "product model get apply out product length success")
end

-- 获取出库产品总数
function M.getOutProductLength(req, res, next)
    local mdb, err = mysql:new(mysql_config)
    if not mdb then
        res:status(http_inner_error):json(get_outProductLength_code.db_error)
        ngx_log(ngx_err, "product model get out product length mysql:new() error:", err)
        return
    end

    local ress, err = mdb:select("select count(*) as c from `out_product`")
    if not ress then
        res:status(http_inner_error):json(get_outProductLength_code.db_error)
        ngx_log(ngx_err, "product model get out product length select product error:", err)
        return
    end

    get_outProductLength_code.gen_success_data(get_outProductLength_code.success.data, ress[1][1])
    res:status(http_ok):json(get_outProductLength_code.success)
    ngx_log(ngx_info, "product model get out product length success")
end

-- 分批获取产品列表
function M.batchGetProductList(req, res, next)
	local offset = tonumber(req.body.offset)
	local limit = tonumber(req.body.limit)

	if not offset or not limit then
		res:status(http_bad_request):json(batch_getProductList_code.params_error)
		ngx_log(ngx_err, "product model batch get product list params error")
		return	
	end

	local mdb, err = mysql:new(mysql_config)
	if not mdb then
        res:status(http_inner_error):json(batch_getProductList_code.db_error)
        ngx_log(ngx_err, "product model batch get product list mysql:new() error:", err)
        return
	end

	local ress, err = mdb:select("select p.*,ifnull(u1.name,'') as `user_name`,ifnull(u2.name,'') as `update_user_name`,ifnull(u3.name,'') as `out_user_name` from `product` as `p` left join `users` as `u1` on p.user_id = u1.id left join `users` as `u2` on p.update_user_id = u2.id left join `users` as `u3` on p.out_user_id = u3.id where p.status!=? order by p.id asc limit ?,?", define_product_status.agreeApply, offset, limit)
	if not ress then
		res:status(http_inner_error):json(batch_getProductList_code.db_error)
        ngx_log(ngx_err, "product model batch get product list select product error:", err, "limit:", limit, ", offset:", offset)
        return
	end

    batch_getProductList_code.gen_success_data(batch_getProductList_code.success.data, ress[1])
    res:status(http_ok):json(batch_getProductList_code.success)
    ngx_log(ngx_info, "product model batch get product list success")
end

-- 分批获取申请出库产品列表
function M.batchGetApplyProductList(req, res, next)
    local offset = tonumber(req.body.offset)
    local limit = tonumber(req.body.limit)

    if not offset or not limit then
        res:status(http_bad_request):json(batch_get_applyProductList_code.params_error)
        ngx_log(ngx_err, "product model batch get apply product list params error")
        return	
    end

    local mdb, err = mysql:new(mysql_config)
    if not mdb then
        res:status(http_inner_error):json(batch_get_applyProductList_code.db_error)
        ngx_log(ngx_err, "product model batch get apply product list mysql:new() error:", err)
        return
    end

    local ress, err = mdb:select("select p.*,ifnull(u1.name,'') as `user_name`,ifnull(u2.name,'') as `update_user_name`,ifnull(u3.name,'') as `out_user_name` from `product` as `p` left join `users` as `u1` on p.user_id = u1.id left join `users` as `u2` on p.update_user_id = u2.id left join `users` as `u3` on p.out_user_id = u3.id where p.status=? or p.status=? order by p.id asc limit ?,?", 
        define_product_status.applying, define_product_status.rejectApply, offset, limit)
    if not ress then
        res:status(http_inner_error):json(batch_get_applyProductList_code.db_error)
        ngx_log(ngx_err, "product model batch get apply product list select product error:", err, "limit:", limit, ", offset:", offset)
        return
    end

    batch_get_applyProductList_code.gen_success_data(batch_get_applyProductList_code.success.data, ress[1])
    res:status(http_ok):json(batch_get_applyProductList_code.success)
    ngx_log(ngx_info, "product model batch get apply product list success")
end

-- 分批获取出库产品列表
function M.batchGetOutProductList(req, res, next)
    local offset = tonumber(req.body.offset)
    local limit = tonumber(req.body.limit)

    if not offset or not limit then
        res:status(http_bad_request):json(batch_get_outProductList_code.params_error)
        ngx_log(ngx_err, "product model batch get out product list params error")
        return	
    end

    local mdb, err = mysql:new(mysql_config)
    if not mdb then
        res:status(http_inner_error):json(batch_get_outProductList_code.db_error)
        ngx_log(ngx_err, "product model batch get out product list mysql:new() error:", err)
        return
    end

    local ress, err = mdb:select("select p.*,ifnull(u1.name,'') as `user_name`,ifnull(u2.name,'') as `out_user_name` from `out_product` as `p` left join `users` as `u1` on p.user_id = u1.id left join `users` as `u2` on p.out_user_id = u2.id order by p.id asc limit ?,?", 
        offset, limit)
    if not ress then
        res:status(http_inner_error):json(batch_get_outProductList_code.db_error)
        ngx_log(ngx_err, "product model batch get out product list select product error:", err, "limit:", limit, ", offset:", offset)
        return
    end

    batch_get_outProductList_code.gen_success_data(batch_get_outProductList_code.success.data, ress[1])
    res:status(http_ok):json(batch_get_outProductList_code.success)
    ngx_log(ngx_info, "product model batch get out product list success")
end

return M