-- Comment: 消息业务

local http_ok = ngx.HTTP_OK
local http_bad_request = ngx.HTTP_BAD_REQUEST
local http_inner_error = ngx.HTTP_INTERNAL_SERVER_ERROR
local ngx_log = ngx.log
local ngx_info = ngx.INFO
local ngx_err = ngx.ERR
local tonumber = tonumber
local os_time = os.time
local table_insert = table.insert
local table_concat = table.concat
local config = require("app.config.config")
local mysql_config = config.mysql
local mysql = require("lor.lib.utils.mysql")
local lor_utils = require("lor.lib.utils.utils")
local publish_message_code = require("app.config.return_code").publish_message
local batch_message_list_code = require("app.config.return_code").batch_message_list
local define_message_status = require("app.config.define").message_status

local M = {}

-- 发布消息
function M.publishMessage(req, res, next)
	local title = req.body.title
	local content = req.body.content
	local category = req.body.category
	local department = req.body.department
	local name = req.body.name
	local level = req.body.level

	if not title or not content or not category or not department or not name or not level then
		res:status(http_bad_request):json(publish_message_code.params_error)
		ngx_log(ngx_err, "message model publish message params error")
		return
	end

	local mdb, err = mysql:new(mysql_config)
	if not mdb then
		res:status(http_inner_error):json(publish_message_code.db_error)
		ngx_log(ngx_err, "message model publish message mysql:new() error:", err)
		return
	end

	local mysql_driver, err = mdb:begin()
	if not mysql_driver then
		res:status(http_inner_error):json(publish_message_code.db_error)
		ngx_log(ngx_err, "message model publish message mysql:begin() error:", err)
		return
	end
	
	local ress, err = mdb:tx_update(mysql_driver, "insert into `gen_message_id` (`department`,`msg_id`) values(?, 1) on duplicate key update msg_id = msg_id + 1", department)
	if not ress then
		res:status(http_inner_error):json(publish_message_code.db_error)
		ngx_log(ngx_err, "message model publish message insert gen_message_id error:", err)
		return
	end

	local ress, err = mdb:tx_select(mysql_driver, "select `msg_id` from `gen_message_id` where `department`=?", department)
	if not ress then
		res:status(http_inner_error):json(publish_message_code.db_error)
		ngx_log(ngx_err, "message model publish message select gen_message_id error:", err)
		return
	end

	local ok, err = mdb:commit(mysql_driver)
	if not ok then
		res:status(http_inner_error):json(publish_message_code.db_error)
		ngx_log(ngx_err, "message model publish message mysql:commit() error:", err)
		return
	end

	local msg_id = ress[1][1]["msg_id"]
	local ress, err = mdb:insert("insert into `message` set `msg_id`=?,`category`=?,`title`=?,`content`=?,`create_time`=?,`update_time`=?,`delete_time`=?,`department`=?,`name`=?,`level`=?,`status`=?,`click_num`=?", 
		msg_id, category, title, content, os_time(), os_time(), 0, department, name, level, define_message_status.normal, 0)
	if not ress then
		res:status(http_inner_error):json(publish_message_code.db_error)
		ngx_log(ngx_err, "message model publish message insert message error:", err)
		return
	end

	res:status(http_ok):json(publish_message_code.success)
	ngx_log(ngx_info, "message model publish message success")
end

-- 分批获取消息列表
function M.batchMessageList(req, res, next)
	local category = req.body.category
	local offset = tonumber(req.body.offset)
	local limit = tonumber(req.body.limit)

	if not offset or not limit then
		res:status(http_bad_request):json(batch_message_list_code.params_error)
		ngx_log(ngx_err, "message model batch message list params error")
		return
	end

	local mdb, err = mysql:new(mysql_config)
	if not mdb then
		res:status(http_inner_error):json(batch_message_list_code.db_error)
		ngx_log(ngx_err, "message model batch message list mysql:new() error:", err)
		return
	end

	local ress, err = mdb:select("select * from `message` where `category`=? and `status`=? order by `msg_id` desc limit ?,?", category, define_message_status.normal, offset, limit)
	if not ress then
		res:status(http_inner_error):json(batch_message_list_code.db_error)
		ngx_log(ngx_err, "message model batch message list select message error:", err)
		return
	end

	batch_message_list_code.gen_success_data(batch_message_list_code.success.data, ress[1])
	res:status(http_ok):json(batch_message_list_code.success)
	ngx_log(ngx_info, "message model batch message list success")
end

return M