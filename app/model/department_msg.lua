-- Comment: 登录业务

local http_ok = ngx.HTTP_OK
local http_bad_request = ngx.HTTP_BAD_REQUEST
local http_inner_error = ngx.HTTP_INTERNAL_SERVER_ERROR
local ngx_log = ngx.log
local ngx_info = ngx.INFO
local ngx_err = ngx.ERR
local unpack = unpack
local config = require("app.config.config")
local mysql_config = config.mysql
local mysql = require("lor.lib.utils.mysql")
local lor_utils = require("lor.lib.utils.utils")
local get_userDepartmentIds_code = require("app.config.return_code").get_userDepartmentIds
local get_departmentMsgByIds_code = require("app.config.return_code").get_departmentMsgByIds
local string_format = string.format

local M = {}

-- 获取用户部门消息ids
function M.getUserDepartmentIds(req, res, next)
	local id = req.jwt.id
	local department = req.body.department

	if not id or not department then
		res:status(http_bad_request):json(get_userDepartmentIds_code.params_error)
		ngx_log(ngx_err, "dm model get user department ids params error")
		return
	end

	local mdb, err = mysql:new(mysql_config)
	if not mdb then
		res:status(http_inner_error):json(get_userDepartmentIds_code.db_error)
		ngx_log(ngx_err, "dm model get user department ids mysql:new() error:", err)
		return
	end

	local ress, err = mdb:select("select `msg_id` from `gen_message_id` where `department`=?", department)
	if not ress then
		res:status(http_inner_error):json(get_userDepartmentIds_code.db_error)
		ngx_log(ngx_err, "dm model get user department ids select gen_message_id1 error:", err)
		return
	end

	if ress[1][1] == nil then
		get_userDepartmentIds_code.gen_success_data(get_userDepartmentIds_code.success.data, nil)
		res:status(http_ok):json(get_userDepartmentIds_code.success)
		ngx_log(ngx_info, "dm model get user department ids success1, department:", department)
		return
	end

	local msg_id = tonumber(ress[1][1]["msg_id"])
	
	local mysql_driver, err = mdb:begin()
	if not mysql_driver then
	    res:status(http_inner_error):json(get_userDepartmentIds_code.db_error)
	    ngx_log(ngx_err, "dm model get user department ids mysql:begin() error:", err)
	    return
	end

	ress, err = mdb:tx_select(mysql_driver, "select `read_msg_id` from `user_message_id` where `user_id`=? and `department`=?", id, department)
	if not ress then
	    res:status(http_inner_error):json(get_userDepartmentIds_code.db_error)
	    ngx_log(ngx_err, "dm model get user department ids select gen_message_id2 error:", err)
	    return
	end

	local read_msg_id = 0
	if ress[1][1] ~= nil and ress[1][1].read_msg_id ~= nil then
		read_msg_id = tonumber(ress[1][1].read_msg_id) or 0
	end

	if read_msg_id >= msg_id then
		local _, err = mdb:commit(mysql_driver)
	    get_userDepartmentIds_code.gen_success_data(get_userDepartmentIds_code.success.data, nil)
	    res:status(http_ok):json(get_userDepartmentIds_code.success)
	    ngx_log(ngx_info, "dm model get user department ids success2, department:", department, ", commit error:", err)
	    return
	end

	ress, err = mdb:tx_update(mysql_driver, "insert into `user_message_id` (`user_id`,`department`,`read_msg_id`) values (?,?,?) on duplicate key update `read_msg_id`=greatest(VALUES(`read_msg_id`),`read_msg_id`)", id, department, msg_id)
	if not ress then
		res:status(http_inner_error):json(get_userDepartmentIds_code.db_error)
		ngx_log(ngx_err, "dm model get user department ids update user_message_id error:", err)
		return
	end

	local ok, err = mdb:commit(mysql_driver)
	if not ok then
	    res:status(http_inner_error):json(get_userDepartmentIds_code.db_error)
	    ngx_log(ngx_err, "dm model get user department ids mysql:commit() error:", err)
	    return
	end

	ress, err = mdb:select("select `id` from `message` where `msg_id`>? and `recept_department`=?", read_msg_id, department)
	if not ress then
		res:status(http_inner_error):json(get_userDepartmentIds_code.db_error)
		ngx_log(ngx_err, "dm model get user department ids select user_message_id error:", err)
		return
	end

	get_userDepartmentIds_code.gen_success_data(get_userDepartmentIds_code.success.data, ress[1])
	res:status(http_ok):json(get_userDepartmentIds_code.success)
	ngx_log(ngx_info, "dm model get user department ids success3, department:", department)
end

-- 根据Ids获取部门消息
function M.getDepartmentMsgByIds(req, res, next)
	local id = req.jwt.id
	local ids = req.body.ids

	if not id or not ids then
		res:status(http_bad_request):json(get_departmentMsgByIds_code.params_error)
		ngx_log(ngx_err, "dm model get department msg by ids params error")
		return
	end

	local msg_ids = lor_utils.json_decode(ids)
	if msg_ids == nil then
		res:status(http_bad_request):json(get_departmentMsgByIds_code.params_error)
		ngx_log(ngx_err, "dm model get department msg by ids json decode error")
		return
	end

	local mdb, err = mysql:new(mysql_config)
	if not mdb then
		res:status(http_inner_error):json(get_departmentMsgByIds_code.db_error)
		ngx_log(ngx_err, "dm model get department msg by ids mysql:new() error:", err)
		return
	end

	-- print(lor_utils.json_encode(msg_ids))
	-- print(table.concat(msg_ids, ","))

	local placeholders, values = lor_utils.build_condition(msg_ids)
	-- print(placeholders)
	-- print(table.concat(values, ","))
	local ress, err = mdb:select(string_format("select * from `message` where `id` in (%s)", placeholders), unpack(values))
	if not ress then
		res:status(http_inner_error):json(get_departmentMsgByIds_code.db_error)
		ngx_log(ngx_err, "dm model get department msg by ids select message error:", err)
		return
	end

	-- print(lor_utils.json_encode(ress))

	get_departmentMsgByIds_code.gen_success_data(get_departmentMsgByIds_code.success.data, ress[1])
	res:status(http_ok):json(get_departmentMsgByIds_code.success)
	ngx_log(ngx_info, "dm model get department msg by ids success")
end

return M