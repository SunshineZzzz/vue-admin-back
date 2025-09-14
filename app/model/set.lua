-- Comment: 设置业务

local string_format = string.format
local os_time = os.time
local tostring = tostring
local http_ok = ngx.HTTP_OK
local http_bad_request = ngx.HTTP_BAD_REQUEST
local http_inner_error = ngx.HTTP_INTERNAL_SERVER_ERROR
local ngx_log = ngx.log
local ngx_info = ngx.INFO
local ngx_err = ngx.ERR
local config = require("app.config.config")
local mysql_config = config.mysql
local mysql = require("lor.lib.utils.mysql")
local upload_config = config.upload
local lor_utils = require("lor.lib.utils.utils")
local define_misc = require("app.config.define").misc
local swiper_dir = define_misc.swiperDir
local companyIntroduce_dir = define_misc.companyIntroduceDir
local upload_swiper_code = require("app.config.return_code").upload_swiper
local get_allSwiper_code = require("app.config.return_code").get_allSwiper
local get_companyName_code = require("app.config.return_code").get_companyName
local change_companyName_code = require("app.config.return_code").change_companyName
local get_companyIntroduce_code = require("app.config.return_code").get_companyIntroduce
local change_companyIntroduce_code = require("app.config.return_code").change_companyIntroduce
local get_allCompanyInfo_code = require("app.config.return_code").get_allCompanyInfo
local set_department_code = require("app.config.return_code").set_department
local get_department_code = require("app.config.return_code").get_department
local set_product_code = require("app.config.return_code").set_product
local get_product_code = require("app.config.return_code").get_product
local upload_companyIntroducePicture_code = require("app.config.return_code").upload_companyIntroducePicture
local define_setting_type = require("app.config.define").setting_type
local define_setting_name = require("app.config.define").setting_name

local M = {}

-- 上传轮播图
function M.uploadSwiper(req, res, next)
	local id = req.jwt.id

	local out_path = string_format("%s/%s", upload_config.outDir, swiper_dir)
	local path = string_format("%s/%s/", upload_config.dir, swiper_dir)

	local ok, err = lor_utils.rmkdir(path)
	if not ok then
		res:status(http_inner_error):json(upload_swiper_code.upload_fail)
		ngx_log(ngx_err, "set model upload swiper mkdir error:", err, ", dir:", path)
		return
	end

	local file_path, origin_filename, _, file_type, extraParam, err = lor_utils.multipart_formdata(upload_config, path, false, {["image/jpeg"] = 1})
	if err then
		res:status(http_inner_error):json(upload_swiper_code.upload_fail)
		ngx_log(ngx_err, "set model upload swiper multipart formdata error:", err, ", dir:", path)
		return
	end

	if not extraParam.swiperId then
		res:status(http_bad_request):json(upload_swiper_code.params_error)
		ok = lor_utils.file_remove(file_path)
		ngx_log(ngx_err, "set model upload swiper params error, file remove:", tostring(ok))
		return
	end

	local new_name = string_format("%s%s.%s", define_setting_name.swiperPrefix, extraParam.swiperId, file_type)
	if new_name ~= origin_filename then
		local ok, err = lor_utils.file_move(file_path, string_format("%s/%s", path, new_name))
		if not ok then
			res:status(http_inner_error):json(upload_swiper_code.upload_fail)
			ok = lor_utils.file_remove(file_path)
			ngx_log(ngx_err, "set model upload swiper rename error, file remove:", tostring(ok))
			return
		end
		file_path = string_format("%s/%s", path, new_name)
	end

	out_path = string_format("%s/%s", out_path, new_name)

	local mdb, err = mysql:new(mysql_config)
	if not mdb then
		res:status(http_inner_error):json(upload_swiper_code.db_error)
		ngx_log(ngx_err, "set model upload swiper mysql:new() error:", err)
		return
	end

	local ress, err = mdb:update("insert into setting(`user_id`,`category`,`key`,`value`,`update_time`) values (?,?,?,?,?) on duplicate key update `user_id`=VALUES(`user_id`),`value`=VALUES(`value`),`update_time`=VALUES(`update_time`)", 
		id, define_setting_type.swiper, new_name, out_path, os_time())
	if not ress then
		res:status(http_inner_error):json(upload_swiper_code.db_error)
		ngx_log(ngx_err, "set model upload swiper insert setting error:", err)
		return
	end

	upload_swiper_code.success.data.image_url = out_path
	res:status(http_ok):json(upload_swiper_code.success)
	ngx_log(ngx_info, "set model upload swiper success")
end

-- 上传公司介绍图片
function M.uploadCompanyIntroducePicture(req, res, next)
	local key = req.query.key

	if not key or #key == 0 then
		res:status(http_bad_request):json(upload_companyIntroducePicture_code.params_error)
		ngx_log(ngx_err, "set model upload company introduce picture params error")
		return
	end

	local out_path = string_format("%s/%s/%s", upload_config.outDir, companyIntroduce_dir, key)
	local path = string_format("%s/%s/%s/", upload_config.dir, companyIntroduce_dir, key)

	local ok, err = lor_utils.rmkdir(path)
	if not ok then
		res:status(http_inner_error):json(upload_companyIntroducePicture_code.upload_fail)
		ngx_log(ngx_err, "set model upload company introduce picture mkdir error:", err, ", dir:", path)
		return
	end

	local file_path, origin_filename, _, _, _, err = lor_utils.multipart_formdata(upload_config, path, false, {["image/jpeg"] = 1})
	if err then
		res:status(http_inner_error):json(upload_companyIntroducePicture_code.upload_fail)
		ngx_log(ngx_err, "set model upload company introduce picture multipart formdata error:", err, ", dir:", file_path)
		return
	end

	out_path = string_format("%s/%s", out_path, origin_filename)

	upload_companyIntroducePicture_code.success.data.image_url = out_path
	res:status(http_ok):json(upload_companyIntroducePicture_code.success)
	ngx_log(ngx_info, "set model upload company introduce picture success")
end

-- 获取所有轮播图
function M.getAllSwiper(req, res, next)
	local mdb, err = mysql:new(mysql_config)
	if not mdb then
		res:status(http_inner_error):json(get_allSwiper_code.db_error)
		ngx_log(ngx_err, "set model get all swiper mysql:new() error:", err)
		return
	end

	local ress, err = mdb:select("select `value` from `setting` where `category`=?", define_setting_type.swiper)
	if not ress then
		res:status(http_inner_error):json(get_allSwiper_code.db_error)
		ngx_log(ngx_err, "set model get all swiper select setting error:", err)
		return
	end

	get_allSwiper_code.gen_success_data(get_allSwiper_code.success.data, ress[1])
	res:status(http_ok):json(get_allSwiper_code.success)
	ngx_log(ngx_info, "set model get all swiper success")
end

-- 获取公司名称
function M.getCompanyName(req, res, next)
	local mdb, err = mysql:new(mysql_config)
	if not mdb then
		res:status(http_inner_error):json(get_companyName_code.db_error)
		ngx_log(ngx_err, "set model get company name mysql:new() error:", err)
		return
	end

	local ress, err = mdb:select("select `value` from `setting` where `category`=?", define_setting_type.companyName)
	if not ress then
		res:status(http_inner_error):json(get_companyName_code.db_error)
		ngx_log(ngx_err, "set model get company name select setting error:", err)
		return
	end

	if ress[1][1] ~= nil then
		get_companyName_code.success.data.companyName = ress[1][1]["value"]
	else
		get_companyName_code.success.data.companyName = ""
	end
	res:status(http_ok):json(get_companyName_code.success)
	ngx_log(ngx_info, "set model get company name success")
end

-- 修改公司名称
function M.changeCompanyName(req, res, next)
	local id = req.jwt.id
	local name = req.body.name

	if not id or not name then
		res:status(http_bad_request):json(change_companyName_code.params_error)
		ngx_log(ngx_err, "set model change company name params error")
		return
	end

	local mdb, err = mysql:new(mysql_config)
	if not mdb then
		res:status(http_inner_error):json(change_companyName_code.db_error)
		ngx_log(ngx_err, "set model change company name mysql:new() error:", err)
		return
	end

	local ress, err = mdb:update("insert into setting(`user_id`,`category`,`key`,`value`,`update_time`) values (?,?,?,?,?) on duplicate key update `user_id`=VALUES(`user_id`),`value`=VALUES(`value`),`update_time`=VALUES(`update_time`)", 
		id, define_setting_type.companyName, define_setting_name.companyName, name, os_time())
	if not ress then
		res:status(http_inner_error):json(change_companyName_code.db_error)
		ngx_log(ngx_err, "set model change company name update setting error:", err)
		return
	end

	res:status(http_ok):json(change_companyName_code.success)
	ngx_log(ngx_info, "set model change company name success")
end

-- 获取公司简介
function M.getCompanyIntroduce(req, res, next)
	local key = req.body.key

	if not key then
		res:status(http_bad_request):json(get_companyIntroduce_code.params_error)
		ngx_log(ngx_err, "set model get company introduce params error")
		return
	end

	local mdb, err = mysql:new(mysql_config)
	if not mdb then
		res:status(http_inner_error):json(get_companyIntroduce_code.db_error)
		ngx_log(ngx_err, "set model get company introduce mysql:new() error:", err)
		return
	end

	key = define_setting_name.companyIntroducePrefix..key
	local ress, err = mdb:select("select `value` from `setting` where `category`=? and `key`=?", 
		define_setting_type.companyIntroduce, key)
	if not ress then
		res:status(http_inner_error):json(get_companyName_code.db_error)
		ngx_log(ngx_err, "set model get company introduce select setting error:", err)
		return
	end

	if ress[1][1] ~= nil then
		get_companyIntroduce_code.success.data.companyIntroduce = ress[1][1]["value"]
	else
		get_companyIntroduce_code.success.data.companyIntroduce = ""
	end
	res:status(http_ok):json(get_companyIntroduce_code.success)
	ngx_log(ngx_info, "set model get company introduce success")	
end

-- 修改公司简介
function M.changeCompanyIntroduce(req, res, next)
	local id = req.jwt.id
	local key = req.body.key
	local introduce = req.body.introduce

	if not id or not key or not introduce then
		res:status(http_bad_request):json(change_companyIntroduce_code.params_error)
		ngx_log(ngx_err, "set model change company introduce params error")
		return
	end

	local mdb, err = mysql:new(mysql_config)
	if not mdb then
		res:status(http_inner_error):json(change_companyName_code.db_error)
		ngx_log(ngx_err, "set model change company introduce mysql:new() error:", err)
		return
	end

	key = define_setting_name.companyIntroducePrefix..key
	local ress, err = mdb:update("insert into setting(`user_id`,`category`,`key`,`value`,`update_time`) values (?,?,?,?,?) on duplicate key update `user_id`=VALUES(`user_id`),`value`=VALUES(`value`),`update_time`=VALUES(`update_time`)", 
		id, define_setting_type.companyIntroduce, key, introduce, os_time())
	if not ress then
		res:status(http_inner_error):json(change_companyIntroduce_code.db_error)
		ngx_log(ngx_err, "set model change company introduce update setting error:", err)
		return
	end

	res:status(http_ok):json(change_companyIntroduce_code.success)
	ngx_log(ngx_info, "set model change company introduce success")
end

-- 获取所有公司信息
function M.getAllCompanyInfo(req, res, next)
	local mdb, err = mysql:new(mysql_config)
	if not mdb then
		res:status(http_inner_error):json(get_allCompanyInfo_code.db_error)
		ngx_log(ngx_err, "set model get all company info mysql:new() error:", err)
		return
	end

	local ress, err = mdb:select("select * from `setting` where `category` in (?)", 
		define_setting_type.companyIntroduce)
	if not ress then
		res:status(http_inner_error):json(get_allCompanyInfo_code.db_error)
		ngx_log(ngx_err, "set model get all company info select setting error:", err)
		return
	end

	get_allCompanyInfo_code.gen_success_data(get_allCompanyInfo_code.success.data, ress[1])
	res:status(http_ok):json(get_allCompanyInfo_code.success)
	ngx_log(ngx_info, "set model get all company info success")
end

-- 部门设置
function M.setDepartment(req, res, next)
	local id = req.jwt.id
	local department = req.body.department

	if not id or not department then
		res:status(http_bad_request):json(set_department_code.params_error)
		ngx_log(ngx_err, "set model set department params error")
		return
	end

	local mdb, err = mysql:new(mysql_config)
	if not mdb then
		res:status(http_inner_error):json(set_department_code.db_error)
		ngx_log(ngx_err, "set model set department mysql:new() error:", err)
		return
	end

	local ress, err = mdb:update("insert into setting(`user_id`,`category`,`key`,`value`,`update_time`) values (?,?,?,?,?) on duplicate key update `user_id`=VALUES(`user_id`),`value`=VALUES(`value`),`update_time`=VALUES(`update_time`)", 
		id, define_setting_type.department, define_setting_name.department, department, os_time())
	if not ress then
		res:status(http_inner_error):json(set_department_code.db_error)
		ngx_log(ngx_err, "set model set department info select setting error:", err)
		return
	end	

	res:status(http_ok):json(set_department_code.success)
	ngx_log(ngx_info, "set model get all company info success")	
end

-- 获取部门
function M.getDepartment(req, res, next)
	local mdb, err = mysql:new(mysql_config)
	if not mdb then
		res:status(http_inner_error):json(get_department_code.db_error)
		ngx_log(ngx_err, "set model get department mysql:new() error:", err)
		return
	end

	local ress, err = mdb:select("select * from `setting` where `category`=? and `key`=?", define_setting_type.department, define_setting_name.department)
	if not ress then
		res:status(http_inner_error):json(get_department_code.db_error)
		ngx_log(ngx_err, "set model get department select setting error:", err)
		return
	end

	get_department_code.gen_success_data(get_department_code.success.data, ress[1][1])
	res:status(http_ok):json(get_department_code.success)
	ngx_log(ngx_info, "set model get department success")
end

-- 产品设置
function M.setProduct(req, res, next)
	local id = req.jwt.id
	local product = req.body.product

	if not id or not product then
		res:status(http_bad_request):json(set_product_code.params_error)
		ngx_log(ngx_err, "set model set product params error")
		return
	end

	local mdb, err = mysql:new(mysql_config)
	if not mdb then
		res:status(http_inner_error):json(set_product_code.db_error)
		ngx_log(ngx_err, "set model set product mysql:new() error:", err)
		return
	end

	local ress, err = mdb:update("insert into setting(`user_id`,`category`,`key`,`value`,`update_time`) values (?,?,?,?,?) on duplicate key update `user_id`=VALUES(`user_id`),`value`=VALUES(`value`),`update_time`=VALUES(`update_time`)", 
		id, define_setting_type.productType, define_setting_name.productType, product, os_time())
	if not ress then
		res:status(http_inner_error):json(set_product_code.db_error)
		ngx_log(ngx_err, "set model set product update setting error:", err)
		return
	end

	res:status(http_ok):json(set_product_code.success)
	ngx_log(ngx_info, "set model set product success")
end

-- 获取产品
function M.getProduct(req, res, next)
	local mdb, err = mysql:new(mysql_config)
	if not mdb then
		res:status(http_inner_error):json(get_product_code.db_error)
		ngx_log(ngx_err, "set model get product mysql:new() error:", err)
		return
	end

	local ress, err = mdb:select("select * from `setting` where `category`=? and `key`=?", define_setting_type.productType, define_setting_name.productType)
	if not ress then
		res:status(http_inner_error):json(get_product_code.db_error)
		ngx_log(ngx_err, "set model get product select setting error:", err)
		return
	end

	get_product_code.gen_success_data(get_product_code.success.data, ress[1][1])
	res:status(http_ok):json(get_product_code.success)
	ngx_log(ngx_info, "set model get product success")
end

return M