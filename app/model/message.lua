-- Comment: 消息业务

local http_ok = ngx.HTTP_OK
local http_bad_request = ngx.HTTP_BAD_REQUEST
local http_inner_error = ngx.HTTP_INTERNAL_SERVER_ERROR
local ngx_log = ngx.log
local ngx_info = ngx.INFO
local ngx_err = ngx.ERR
local tonumber = tonumber
local os_time = os.time
local config = require("app.config.config")
local mysql_config = config.mysql
local mysql = require("lor.lib.utils.mysql")
local utils = require("app.utils.utils")
local publish_message_code = require("app.config.return_code").publish_message
local define_message_status = require("app.config.define").message_status
local edit_message_code = require("app.config.return_code").edit_message
local search_messageByDepartment_code = require("app.config.return_code").search_messageByDepartment
local search_messageByReceptDepartment_code = require("app.config.return_code").search_messageByReceptDepartment
local search_messageByLevel_code = require("app.config.return_code").search_messageByLevel
local first_deleteMessage_code = require("app.config.return_code").first_deleteMessage
local message_recover_code = require("app.config.return_code").message_recover
local message_delete_code = require("app.config.return_code").message_delete
local update_messageClick_code = require("app.config.return_code").update_messageClick
local get_recycleListLength_code = require("app.config.return_code").get_recycleListLength
local batch_recycleMessageList_code = require("app.config.return_code").batch_recycleMessageList
local get_messageListLength_code = require("app.config.return_code").get_messageListLength
local batch_message_list_code = require("app.config.return_code").batch_message_list
local get_messageListByReceptDepartmentLength_code = require("app.config.return_code").get_messageListByReceptDepartmentLength
local batch_messageListByReceptDepartment_code = require("app.config.return_code").batch_messageListByReceptDepartment

local M = {}

-- 发布消息
function M.publishMessage(req, res, next)
	local id = req.jwt.id
	local title = req.body.title
	local content = req.body.content
	local recept_department = req.body.recept_department
	local levelStr = req.body.level
	local publish_department = req.body.publish_department
	local publish_name = req.body.publish_name

	if not title or not content or not recept_department or not levelStr or not publish_department or not publish_name then
		res:status(http_bad_request):json(publish_message_code.params_error)
		ngx_log(ngx_err, "message model publish message params error1")
		return
	end

	local level = utils.switch_message_level_str(levelStr)
	if not level then
		res:status(http_bad_request):json(publish_message_code.params_error)
		ngx_log(ngx_err, "message model publish message params error2")
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

	local ress, err = mdb:tx_update(mysql_driver, "insert into `gen_message_id` (`department`,`msg_id`) values(?, 1) on duplicate key update msg_id = msg_id + 1", recept_department)
	if not ress then
		res:status(http_inner_error):json(publish_message_code.db_error)
		ngx_log(ngx_err, "message model publish message insert gen_message_id error:", err, ", recept_department:", recept_department)
		return
	end

	if ress[1].affected_rows == 0 then
		res:status(http_inner_error):json(publish_message_code.db_error)
		ngx_log(ngx_err, "message model publish message insert gen_message_id affected_rows error:", ress[1].affected_rows)
		return
	end

	ress, err = mdb:tx_select(mysql_driver, "select `msg_id` from `gen_message_id` where `department`=?", recept_department)
	if not ress then
		res:status(http_inner_error):json(publish_message_code.db_error)
		ngx_log(ngx_err, "message model publish message select gen_message_id error:", err)
		return
	end

	local lor_utils = require("lor.lib.utils.utils")
	print(lor_utils.json_encode(ress))

	local ok, err = mdb:commit(mysql_driver)
	if not ok then
		res:status(http_inner_error):json(publish_message_code.db_error)
		ngx_log(ngx_err, "message model publish message mysql:commit() error:", err)
		return
	end

	local msg_id = ress[1][1].msg_id
	ress, err = mdb:insert("insert into `message` set `msg_id`=?,`recept_department`=?,`title`=?,`content`=?,`create_time`=?,`update_time`=?,`delete_time`=?,`user_id`=?,`publish_department`=?,`publish_name`=?,`level`=?,`status`=?,`click_num`=?", 
		msg_id, recept_department, title, content, os_time(), os_time(), 0, id, publish_department, publish_name, level, define_message_status.normal, 0)
	if not ress then
		res:status(http_inner_error):json(publish_message_code.db_error)
		ngx_log(ngx_err, "message model publish message insert message error:", err)
		return
	end

	res:status(http_ok):json(publish_message_code.success)
	ngx_log(ngx_info, "message model publish message success")
end

-- 编辑消息
function M.editMessage(req, res, next)
	local id = req.jwt.id
	local msgId = req.body.msgId
	local title = req.body.title
	local content = req.body.content
	local levelStr = req.body.level
	local recept_department = req.body.recept_department

	if not id or not msgId or not title or not content or not levelStr or not recept_department then
		res:status(http_bad_request):json(edit_message_code.params_error)
		ngx_log(ngx_err, "message model edit message params error1")
		return
	end

	local level = utils.switch_message_level_str(levelStr)
	if not level then
		res:status(http_bad_request):json(edit_message_code.params_error)
		ngx_log(ngx_err, "message model edit message params error2")
		return
	end

	local mdb, err = mysql:new(mysql_config)
	if not mdb then
		res:status(http_inner_error):json(edit_message_code.db_error)
		ngx_log(ngx_err, "message model edit message mysql:new() error:", err)
		return
	end

	local ress, err = mdb:update("update `message` set `title`=?,`content`=?,`level`=?,`recept_department`=?,`update_time`=? where `msg_id`=?", title, content, level, recept_department, os_time(), msgId)
	if not ress then
		res:status(http_inner_error):json(edit_message_code.db_error)
		ngx_log(ngx_err, "message model edit message update message error:", err)
		return
	end

	res:status(http_ok):json(edit_message_code.success)
	ngx_log(ngx_info, "message model edit message success")
end

-- 根据发布部门进行搜索消息
function M.searchMessageByDepartment(req, res, next)
	local publish_department = req.body.publish_department

	if not publish_department then
		res:status(http_bad_request):json(search_messageByDepartment_code.params_error)
		ngx_log(ngx_err, "message model search message by department params error")
		return
	end

	local mdb, err = mysql:new(mysql_config)
	if not mdb then
		res:status(http_inner_error):json(search_messageByDepartment_code.db_error)
		ngx_log(ngx_err, "message model search message by department mysql:new() error:", err)
		return
	end

	local ress, err = mdb:select("select * from `message` where `publish_department`=? and `status`=?", publish_department, define_message_status.normal)
	if not ress then
		res:status(http_inner_error):json(search_messageByDepartment_code.db_error)
		ngx_log(ngx_err, "message model search message by department select message error:", err)
		return
	end

	search_messageByDepartment_code.gen_success_data(search_messageByDepartment_code.success.data, ress[1])
	res:status(http_ok):json(search_messageByDepartment_code.success)
	ngx_log(ngx_info, "message model search message by department success")
end

-- 根据接收部门进行搜索消息
function M.searchMessageByReceptDepartment(req, res, next)
	local recept_department = req.body.recept_department

	if not recept_department then
		res:status(http_bad_request):json(search_messageByReceptDepartment_code.params_error)
		ngx_log(ngx_err, "message model search message by recept department params error")
		return
	end

	local mdb, err = mysql:new(mysql_config)
	if not mdb then
		res:status(http_inner_error):json(search_messageByReceptDepartment_code.db_error)
		ngx_log(ngx_err, "message model search message by recept department mysql:new() error:", err)
		return
	end

	local ress, err = mdb:select("select * from `message` where `recept_department`=? and `status`=?", recept_department, define_message_status.normal)
	if not ress then
		res:status(http_inner_error):json(search_messageByReceptDepartment_code.db_error)
		ngx_log(ngx_err, "message model search message by recept department select message error:", err)
		return
	end

	search_messageByReceptDepartment_code.gen_success_data(search_messageByReceptDepartment_code.success.data, ress[1])
	res:status(http_ok):json(search_messageByReceptDepartment_code.success)
	ngx_log(ngx_info, "message model search message by recept department success")
end

-- 根据发布等级进行获取消息
function M.searchMessageByLevel(req, res, next)
	local level = req.body.level

	if not level then
		res:status(http_bad_request):json(search_messageByLevel_code.params_error)
		ngx_log(ngx_err, "message model search message by level params error1")
		return
	end

	local nLevel = utils.switch_message_level_str(level)
	if not level then
		res:status(http_bad_request):json(search_messageByLevel_code.params_error)
		ngx_log(ngx_err, "message model search message by level params error2")
		return
	end

	local mdb, err = mysql:new(mysql_config)
	if not mdb then
		res:status(http_inner_error):json(search_messageByLevel_code.db_error)
		ngx_log(ngx_err, "message model search message by level mysql:new() error:", err)
		return
	end

	local ress, err = mdb:select("select * from `message` where `level`=? and `status`=?", nLevel, define_message_status.normal)
	if not ress then
		res:status(http_inner_error):json(search_messageByLevel_code.db_error)
		ngx_log(ngx_err, "message model search message by level select message error:", err)
		return
	end

	search_messageByLevel_code.gen_success_data(search_messageByLevel_code.success.data, ress[1])
	res:status(http_ok):json(search_messageByLevel_code.success)
	ngx_log(ngx_info, "message model search message by level success")
end

-- 初次删除消息
function M.firstDeleteMessage(req, res, next)
	local msgId = req.body.msgId

	if not msgId then
		res:status(http_bad_request):json(first_deleteMessage_code.params_error)
		ngx_log(ngx_err, "message model first delete message params error")
		return
	end

	local mdb, err = mysql:new(mysql_config)
	if not mdb then
		res:status(http_inner_error):json(first_deleteMessage_code.db_error)
		ngx_log(ngx_err, "message model first delete message mysql:new() error:", err)
		return
	end

	local ress, err = mdb:update("update `message` set `update_time`=?,`delete_time`=?,`status`=? where `msg_id`=? and `status`=?", os_time(), os_time(), define_message_status.first_delete, msgId, define_message_status.normal)
	if not ress then
		res:status(http_inner_error):json(first_deleteMessage_code.db_error)
		ngx_log(ngx_err, "message model first delete message update message error:", err)
		return
	end

	if ress[1].affected_rows ~= 1 then
		res:status(http_inner_error):json(first_deleteMessage_code.first_delete_error)
		ngx_log(ngx_err, "message model first delete message update message affected_rows error:", ress[1].affected_rows)
		return
	end

	res:status(http_ok):json(first_deleteMessage_code.success)
	ngx_log(ngx_info, "message model first delete message success")
end

-- 更新消息点击率
function M.updateMessageClick(req, res, next)
	local msgId = req.body.msgId
	local click_num = tonumber(req.body.clickNum)

	if not msgId or not click_num or click_num <= 0 then
		res:status(http_bad_request):json(update_messageClick_code.params_error)
		ngx_log(ngx_err, "message model update message click params error")
		return
	end

	local mdb, err = mysql:new(mysql_config)
	if not mdb then
		res:status(http_inner_error):json(update_messageClick_code.db_error)
		ngx_log(ngx_err, "message model update message click mysql:new() error:", err)
		return
	end

	local ress, err = mdb:update("update `message` set `click_num`=`click_num`+? where `msg_id`=?", click_num, msgId)
	if not ress then
		res:status(http_inner_error):json(update_messageClick_code.db_error)
		ngx_log(ngx_err, "message model update message click update message error:", err)
		return
	end

	res:status(http_ok):json(update_messageClick_code.success)
	ngx_log(ngx_info, "message model update message click success")
end

-- 消息还原操作
function M.messageRecover(req, res, next)
	local msgId = req.body.msgId

	if not msgId then
		res:status(http_bad_request):json(message_recover_code.params_error)
		ngx_log(ngx_err, "message model message recover params error")
		return
	end

	local mdb, err = mysql:new(mysql_config)
	if not mdb then
		res:status(http_inner_error):json(message_recover_code.db_error)
		ngx_log(ngx_err, "message model message recover mysql:new() error:", err)
		return
	end

	local ress, err = mdb:update("update `message` set `status`=? where `msg_id`=? and `status`=?", define_message_status.normal, msgId, define_message_status.first_delete)
	if not ress then
		res:status(http_inner_error):json(message_recover_code.db_error)
		ngx_log(ngx_err, "message model message recover update message error:", err)
		return
	end

	if ress[1].affected_rows ~= 1 then
		res:status(http_inner_error):json(message_recover_code.recover_error)
		ngx_log(ngx_err, "message model message recover update message affected_rows error:", ress[1].affected_rows)
		return
	end

	res:status(http_ok):json(message_recover_code.success)
	ngx_log(ngx_info, "message model message recover success")
end

-- 消息删除操作
function M.messageDelete(req, res, next)
	local msgId = req.body.msgId

	if not msgId then
		res:status(http_bad_request):json(message_delete_code.params_error)
		ngx_log(ngx_err, "message model message delete params error")
		return
	end

	local mdb, err = mysql:new(mysql_config)
	if not mdb then
		res:status(http_inner_error):json(message_delete_code.db_error)
		ngx_log(ngx_err, "message model message delete mysql:new() error:", err)
		return
	end

	local ress, err = mdb:delete("delete from `message` where `msg_id`=? and `status`=?", msgId, define_message_status.first_delete)
	if not ress then
		res:status(http_inner_error):json(message_delete_code.db_error)
		ngx_log(ngx_err, "message model message delete error:", err)
		return
	end

	if ress[1].affected_rows ~= 1 then
		res:status(http_inner_error):json(message_delete_code.delete_error)
		ngx_log(ngx_err, "message model message delete affected_rows error:", ress[1].affected_rows)
		return
	end

	res:status(http_ok):json(message_delete_code.success)
	ngx_log(ngx_info, "message model delete message success")
end

-- 获取回收站的列表长度
function M.recycleMessageListLength(req, res, next)
	local mdb, err = mysql:new(mysql_config)
	if not mdb then
		res:status(http_inner_error):json(get_recycleListLength_code.db_error)
		ngx_log(ngx_err, "message model get recycle list length mysql:new() error:", err)
		return
	end

	local ress, err = mdb:select("select count(*) as c from `message` where `status`=?", define_message_status.first_delete)
	if not ress then
		res:status(http_inner_error):json(get_recycleListLength_code.db_error)
		ngx_log(ngx_err, "message model get recycle list length select message error:", err)
		return
	end

	get_recycleListLength_code.gen_success_data(get_recycleListLength_code.success.data, ress[1][1])
	res:status(http_ok):json(get_recycleListLength_code.success)
	ngx_log(ngx_info, "message model get recycle list length success")
end

-- 分批获取回收站消息列表
function M.batchRecycleMessageList(req, res, next)
	local offset = tonumber(req.body.offset)
	local limit = tonumber(req.body.limit)

	if not offset or not limit then
		res:status(http_bad_request):json(batch_recycleMessageList_code.params_error)
		ngx_log(ngx_err, "message model batch recycle message list params error")
		return
	end

	local mdb, err = mysql:new(mysql_config)
	if not mdb then
		res:status(http_inner_error):json(batch_recycleMessageList_code.db_error)
		ngx_log(ngx_err, "message model batch recycle message list mysql:new() error:", err)
		return
	end

	local ress, err = mdb:select("select * from `message` where `status`=? order by `msg_id` desc limit ?,?", define_message_status.first_delete, offset, limit)
	if not ress then
		res:status(http_inner_error):json(batch_recycleMessageList_code.db_error)
		ngx_log(ngx_err, "message model batch recycle message list select message error:", err)
		return
	end

	batch_recycleMessageList_code.gen_success_data(batch_recycleMessageList_code.success.data, ress[1])
	res:status(http_ok):json(batch_recycleMessageList_code.success)
	ngx_log(ngx_info, "message model batch recycle message list success")
end

-- 获取消息列表长度
function M.getMessageListLength(req, res, next)
	local mdb, err = mysql:new(mysql_config)
	if not mdb then
		res:status(http_inner_error):json(get_messageListLength_code.db_error)
		ngx_log(ngx_err, "message model get message list length mysql:new() error:", err)
		return
	end

	local ress, err = mdb:select("select count(*) as c from `message` where `status`=?", define_message_status.normal)
	if not ress then
		res:status(http_inner_error):json(get_messageListLength_code.db_error)
		ngx_log(ngx_err, "message model get message list length select message error:", err)
		return
	end

	get_messageListLength_code.gen_success_data(get_messageListLength_code.success.data, ress[1][1])
	res:status(http_ok):json(get_messageListLength_code.success)
	ngx_log(ngx_info, "message model get message list length success")
end

-- 分批获取消息列表
function M.batchMessageList(req, res, next)
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

	local ress, err = mdb:select("select * from `message` where `status`=? order by `msg_id` desc limit ?,?", define_message_status.normal, offset, limit)
	if not ress then
		res:status(http_inner_error):json(batch_message_list_code.db_error)
		ngx_log(ngx_err, "message model batch message list select message error:", err)
		return
	end

	batch_message_list_code.gen_success_data(batch_message_list_code.success.data, ress[1])
	res:status(http_ok):json(batch_message_list_code.success)
	ngx_log(ngx_info, "message model batch message list success")
end

-- 根据接收部门获取消息列表长度
function M.getMessageListByReceptDepartmentLength(req, res, next)
	local recept_department = req.body.recept_department

	if not recept_department then
		res:status(http_bad_request):json(get_messageListByReceptDepartmentLength_code.params_error)
		ngx_log(ngx_err, "message model get message list by recept department length params error")
		return
	end

	local mdb, err = mysql:new(mysql_config)
	if not mdb then
		res:status(http_inner_error):json(get_messageListByReceptDepartmentLength_code.db_error)
		ngx_log(ngx_err, "message model get message list by recept department length mysql:new() error:", err)
		return
	end

	local ress, err = mdb:select("select count(*) as c from `message` where `status`=? and `recept_department`=?", define_message_status.normal, recept_department)
	if not ress then
		res:status(http_inner_error):json(get_messageListByReceptDepartmentLength_code.db_error)
		ngx_log(ngx_err, "message model get message list by recept department length select message error:", err)
		return
	end

	get_messageListByReceptDepartmentLength_code.gen_success_data(get_messageListByReceptDepartmentLength_code.success.data, ress[1][1])
	res:status(http_ok):json(get_messageListByReceptDepartmentLength_code.success)
	ngx_log(ngx_info, "message model get message list by recept department length success")
end

-- 根据接收部门分批获取消息列表
function M.batchMessageListByReceptDepartment(req, res, next)
	local recept_department = req.body.recept_department
	local offset = tonumber(req.body.offset)
	local limit = tonumber(req.body.limit)

	if not recept_department or not offset or not limit then
		res:status(http_bad_request):json(batch_messageListByReceptDepartment_code.params_error)
		ngx_log(ngx_err, "message model batch message list by recept department params error")
		return
	end

	local mdb, err = mysql:new(mysql_config)
	if not mdb then
		res:status(http_inner_error):json(batch_messageListByReceptDepartment_code.db_error)
		ngx_log(ngx_err, "message model batch message list by recept department mysql:new() error:", err)
		return
	end

	local ress, err = mdb:select("select * from `message` where `status`=? and `recept_department`=? order by `msg_id` desc limit ?,?", define_message_status.normal, recept_department, offset, limit)
	if not ress then
		res:status(http_inner_error):json(batch_messageListByReceptDepartment_code.db_error)
		ngx_log(ngx_err, "message model batch message list by recept department select message error:", err)
		return
	end

	batch_messageListByReceptDepartment_code.gen_success_data(batch_messageListByReceptDepartment_code.success.data, ress[1])
	res:status(http_ok):json(batch_messageListByReceptDepartment_code.success)
	ngx_log(ngx_info, "message model batch message list by recept department success")
end


return M