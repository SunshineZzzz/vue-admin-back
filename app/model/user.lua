-- Comment: 用户业务

local string_format = string.format
local tonumber = tonumber
local os_time = os.time
-- local tostring = tostring
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
local upload_avatar_code = require("app.config.return_code").upload_avatar
local change_password_code = require("app.config.return_code").change_password
local get_userinfo_code = require("app.config.return_code").get_userinfo
local change_name_code = require("app.config.return_code").change_name
local change_sex_code = require("app.config.return_code").change_sex
local change_email_code = require("app.config.return_code").change_email
local create_admin_code = require("app.config.return_code").create_admin
local get_identity_number_code = require("app.config.return_code").get_identity_number
local edit_admin_code = require("app.config.return_code").edit_admin
local change_identity_code = require("app.config.return_code").change_identity
local search_user_code = require("app.config.return_code").search_user
local search_userByDepartment_code = require("app.config.return_code").search_userByDepartment
local hot_user_code = require("app.config.return_code").hot_user
local get_ban_list_code = require("app.config.return_code").get_ban_list
local delete_user_code = require("app.config.return_code").delete_user
local batch_get_user_code = require("app.config.return_code").batch_get_user
local ban_user_code = require("app.config.return_code").ban_user
local define_misc = require("app.config.define").misc
local avatar_dir = define_misc.avatarDir
local pw = require("lor.lib.utils.password")
local define_user_identity = require("app.config.define").user_identity
local define_user_status = require("app.config.define").user_status
local utils = require("app.utils.utils")

-- TODO 参数不安全，后续优化

local M = {}

-- 上传头像 & 上传头像返回
function M.upload_avatar(req, res, next)
	local id = req.jwt.id
	if not id then
		res:status(http_bad_request):json(upload_avatar_code.upload_fail)
		ngx_log(ngx_err, "user model upload avatar params error")
		return
	end

	local out_path = string_format("%s/%s/%s/avatar.jpeg", upload_config.outDir, avatar_dir, id)
	local path = string_format("%s/%s/%s/avatar.jpeg", upload_config.dir, avatar_dir, id)

	local ok, err = lor_utils.rmkdir(lor_utils.dirname(path))
	if not ok then
		res:status(http_inner_error):json(upload_avatar_code.upload_fail)
		ngx_log(ngx_err, "user model upload avatar mkdir error:", err, ", dir:", path)
		return
	end

	local file_path, _, _, extra, err = lor_utils.multipart_formdata(upload_config, path, true, {["image/jpeg"] = 1})
	if err then
		res:status(http_inner_error):json(upload_avatar_code.upload_fail)
		ngx_log(ngx_err, "user model upload avatar multipart formdata error:", err, ", dir:", path)
		return
	end
	
	-- print(lor_utils.json_encode(extra))

	local mdb, err = mysql:new(mysql_config)
	if not mdb then
		res:status(http_inner_error):json(upload_avatar_code.upload_fail)
		ngx_log(ngx_err, "user model upload avatar mysql:new() error:", err, ", dir:", path)
		return
	end

	local ress, err = mdb:update("update `users` set `image_url`=? where `id`=?", out_path, id)
	if not ress or ress[1].affected_rows ~= 1 then
		res:status(http_inner_error):json(upload_avatar_code.upload_fail)
		ngx_log(ngx_err, "user model upload avatar update users image_url error:", err, 
			", file_path", file_path, ", dir:", path)
		return
	end

	ngx_log(ngx_info, "user model upload avatar success, file_path:", file_path, ", dir:", path)
	upload_avatar_code.success.data.image_url = out_path
	res:status(http_ok):json(upload_avatar_code.success)
end

-- 修改密码
function M.change_password(req, res, next)
	local id = req.body.id
	local oldPassword = req.body.oldPassword
	local newPassword = req.body.newPassword
	
	if not id or not oldPassword or not newPassword then
		res:status(http_bad_request):json(change_password_code.params_error)
		ngx_log(ngx_err, "user model change password params error")
		return
	end

	local mdb, err = mysql:new(mysql_config)
	if not mdb then
		res:status(http_inner_error):json(change_password_code.db_error)
		ngx_log(ngx_err, "user model change password mysql:new() error:", err)
		return
	end

	local ress, err = mdb:select("select `password` from `users` where `id`=?", id)
	if not ress then
		res:status(http_inner_error):json(change_password_code.db_error)
		ngx_log(ngx_err, "user model change password select users error:", err)
		return
	end

	local hashed_password = ress[1][1]["password"]
	local ok, err = pw.verify_password(oldPassword, hashed_password)
	if not ok or err then
		res:status(http_ok):json(change_password_code.password_error)
		ngx_log(ngx_err, "user model change password password verify error:", err or "nil")
		return
	end

	local password = pw.hash_password(newPassword)
	ress, err = mdb:update("update `users` set `password`=?,`update_time`=?", password, os_time())
	if not ress or ress[1].affected_rows ~= 1 then
		res:status(http_inner_error):json(change_password_code.db_error)
		ngx_log(ngx_err, "user model change password update users password error:", err)
		return
	end

	res:status(http_ok):json(change_password_code.success)
	ngx_log(ngx_info, "user model change password success")
end

-- 获取用户信息
function M.get_userinfo(req, res, next)
	local id = req.body.id
	
	if not id then
		res:status(http_bad_request):json(get_userinfo_code.params_error)
		ngx_log(ngx_err, "user model get userinfo params error")
		return
	end

	local mdb, err = mysql:new(mysql_config)
	if not mdb then
		res:status(http_inner_error):json(get_userinfo_code.db_error)
		ngx_log(ngx_err, "user model get userinfo mysql:new() error:", err)
		return
	end

	local ress, err = mdb:select("select * from `users` where `id`=?", id)
	if not ress then
		res:status(http_inner_error):json(get_userinfo_code.db_error)
		ngx_log(ngx_err, "user model get userinfo select users error:", err)
		return
	end

	if #ress[1] == 0 then
		res:status(http_ok):json(get_userinfo_code.user_not_exist)
		ngx_log(ngx_err, "user model get userinfo user not exist")
		return
	end

	get_userinfo_code.gen_success_data(get_userinfo_code.success.data, ress[1][1])
	res:status(http_ok):json(get_userinfo_code.success)
	ngx_log(ngx_info, "user model get userinfo success, data:", lor_utils.json_encode(get_userinfo_code.success.data))
end

-- 修改昵称
function M.change_name(req, res, next)
	local id = req.body.id
	local name = req.body.name

	if not id or not name then
		res:status(http_bad_request):json(change_name_code.params_error)
		ngx_log(ngx_err, "user model change name params error")
		return
	end

	local mdb, err = mysql:new(mysql_config)
	if not mdb then
		res:status(http_inner_error):json(change_name_code.db_error)
		ngx_log(ngx_err, "user model change name mysql:new() error:", err)
		return
	end

	local ress, err = mdb:update("update `users` set `name`=?,`update_time`=? where `id`=?", name, os_time(), id)
	if not ress or ress[1].affected_rows ~= 1 then
		res:status(http_inner_error):json(change_name_code.db_error)
		ngx_log(ngx_err, "user model change name update users name error:", err)
		return
	end

	res:status(http_ok):json(change_name_code.success)
	ngx_log(ngx_info, "user model change name success")
end

-- 修改性别
function M.change_sex(req, res, next)
	local id = req.body.id
	local sex = req.body.sex

	if not id or not sex then
		res:status(http_bad_request):json(change_sex_code.params_error)
		ngx_log(ngx_err, "user model change sex params error")
		return
	end

	local mdb, err = mysql:new(mysql_config)
	if not mdb then
		res:status(http_inner_error):json(change_sex_code.db_error)
		ngx_log(ngx_err, "user model change sex mysql:new() error:", err)
		return
	end

	local ress, err = mdb:update("update `users` set `sex`=?,`update_time`=? where `id`=?", sex, os_time(), id)
	if not ress or ress[1].affected_rows ~= 1 then
		res:status(http_inner_error):json(change_sex_code.db_error)
		ngx_log(ngx_err, "user model change sex update users sex error:", err)
		return
	end

	res:status(http_ok):json(change_sex_code.success)
	ngx_log(ngx_info, "user model change sex success")
end

-- 修改邮箱
function M.change_email(req, res, next)
	local id = req.body.id
	local email = req.body.email

	if not id or not email then
		res:status(http_bad_request):json(change_email_code.params_error)
		ngx_log(ngx_err, "user model change email params error")
		return
	end

	local mdb, err = mysql:new(mysql_config)
	if not mdb then
		res:status(http_inner_error):json(change_email_code.db_error)
		ngx_log(ngx_err, "user model change email mysql:new() error:", err)
		return
	end

	local ress, err = mdb:update("update `users` set `email`=?,`update_time`=? where `id`=?", email, os_time(), id)
	if not ress or ress[1].affected_rows ~= 1 then
		res:status(http_inner_error):json(change_email_code.db_error)
		ngx_log(ngx_err, "user model change email update users email error:", err)
		return
	end

	res:status(http_ok):json(change_email_code.success)
	ngx_log(ngx_info, "user model change email success")
end

-- 创建管理员
function M.createAdmin(req, res, next)
	local account = req.body.account
	local password = req.body.password
	local name = req.body.name
	local sex = req.body.sex
	local department = req.body.department
	local email = req.body.email
	local identity = req.body.identity

	if not account or not password or 
	not name or not sex or 
	not department or not email or 
	not identity or not utils.switch_identity_str(identity) then
		res:status(http_bad_request):json(create_admin_code.params_error)
		ngx_log(ngx_err, "user model create admin params error")
		return
	end

	local mdb, err = mysql:new(mysql_config)
	if not mdb then
		res:status(http_inner_error):json(create_admin_code.db_error)
		ngx_log(ngx_err, "user model create admin mysql:new() error:", err)
		return
	end

	local ress, err = mdb:select("select count(*) as c from `users` where `account`=?", account)
	if not ress then
		res:status(http_inner_error):json(create_admin_code.db_error)
		ngx_log(ngx_err, "user model create admin insert admin error:", err)
		return
	end

	if tonumber(ress[1][1]["c"] )> 0 then
		res:status(http_ok):json(create_admin_code.user_exist)
		ngx_log(ngx_err, "user model create admin user exist")
		return
	end

	local hashed_password = pw.hash_password(password)
	ress, err = mdb:insert("insert into `users` set `account`=?,`password`=?,`identity`=?,`department`=?,`name`=?,`sex`=?,`email`=?,`create_time`=?,`update_time`=?,`status`=?", 
		account, hashed_password, utils.switch_identity_str(identity), department, name, sex, email, os_time(), os_time(), define_user_status.normal)
	if not ress or ress[1].affected_rows ~= 1 then
		res:status(http_inner_error):json(create_admin_code.db_error)
		ngx_log(ngx_err, "user model create admin insert admin error:", err)
		return
	end

	res:status(http_ok):json(create_admin_code.success)
	ngx_log(ngx_info, "user model create admin success")
end

-- 获取对应身份的总数
function M.getIdentityNumber(req, res, next)
	local identity = req.body.identity

	if not identity or not utils.switch_identity_str(identity) then
		res:status(http_bad_request):json(get_identity_number_code.params_error)
		ngx_log(ngx_err, "user model get identity number params error")
		return
	end

	local mdb, err = mysql:new(mysql_config)
	if not mdb then
		res:status(http_inner_error):json(get_identity_number_code.db_error)
		ngx_log(ngx_err, "user model get identity number mysql:new() error:", err)
		return
	end

	local ress, err = mdb:select("select count(*) as `c` from `users` where `identity`=?", utils.switch_identity_str(identity))
	if not ress then
		res:status(http_inner_error):json(get_identity_number_code.db_error)
		ngx_log(ngx_err, "user model get identity number select users error:", err)
		return
	end

	get_identity_number_code.success.data.count = tonumber(ress[1][1]["c"])
	res:status(http_ok):json(get_identity_number_code.success)
	ngx_log(ngx_info, "user model get identity number success")
end

-- 编辑管理员
function M.editAdmin(req, res, next)
	local id = req.body.id
	local name = req.body.name
	local sex = req.body.sex
	local email = req.body.email
	local department = req.body.department

	if not id or not name or not sex or not email or not department then
		res:status(http_bad_request):json(edit_admin_code.params_error)
		ngx_log(ngx_err, "user model edit admin params error")
		return
	end

	local mdb, err = mysql:new(mysql_config)
	if not mdb then
		res:status(http_inner_error):json(edit_admin_code.db_error)
		ngx_log(ngx_err, "user model edit admin mysql:new() error:", err)
		return
	end

	local ress, err = mdb:update("update `users` set `name`=?,`sex`=?,`email`=?,`department`=?,`update_time`=? where `id`=?", name, sex, email, department, os_time(), id)
	if not ress or ress[1].affected_rows ~= 1 then
		res:status(http_inner_error):json(edit_admin_code.db_error)
		ngx_log(ngx_err, "user model edit admin update admin error:", err)
		return
	end

	res:status(http_ok):json(edit_admin_code.success)
	ngx_log(ngx_info, "user model edit admin success")
end

-- 修改用户身份
function M.changeIdentity(req, res, next)
	local id = req.body.id
	local identity = req.body.identity

	if not id or not identity  or not utils.switch_identity_str(identity) then
		res:status(http_bad_request):json(change_identity_code.params_error)
		ngx_log(ngx_err, "user model change identity params error")
		return
	end

	local mdb, err = mysql:new(mysql_config)
	if not mdb then
		res:status(http_inner_error):json(change_identity_code.db_error)
		ngx_log(ngx_err, "user model change identity mysql:new() error:", err)
		return
	end

	local ress, err = mdb:update("update `users` set `identity`=?,`update_time`=? where `id`=?", utils.switch_identity_str(identity), os_time(), id)
	if not ress or ress[1].affected_rows ~= 1 then
		res:status(http_inner_error):json(change_identity_code.db_error)
		ngx_log(ngx_err, "user model change identity update admin error:", err)
		return
	end

	res:status(http_ok):json(change_identity_code.success)
	ngx_log(ngx_info, "user model change identity success")
end

-- 搜索用户
function M.searchUser(req, res, next)
	local account = req.body.account
	local identity = req.body.identity

	if not account or not identity or not utils.switch_identity_str(identity) then
		res:status(http_bad_request):json(search_user_code.params_error)
		ngx_log(ngx_err, "user model search user params error")
		return
	end

	local mdb, err = mysql:new(mysql_config)
	if not mdb then
		res:status(http_inner_error):json(search_user_code.db_error)	
		ngx_log(ngx_err, "user model search user mysql:new() error:", err)
		return
	end

	local ress, err
	if lor_utils.trim_path_spaces(account) == "" then
		ress, err = mdb:select("select * from `users` where `identity`=?", utils.switch_identity_str(identity))
	else
		ress, err = mdb:select("select * from `users` where `account`=? and `identity`=?", account, utils.switch_identity_str(identity))
	end
	if not ress then
		res:status(http_inner_error):json(search_user_code.db_error)
		ngx_log(ngx_err, "user model search user select users error:", err)
		return
	end

	search_user_code.gen_success_data(search_user_code.success.data, ress[1])
	res:status(http_ok):json(search_user_code.success)
	ngx_log(ngx_info, "user model search user success")
end

-- 根据部门搜索用户
function M.searchUserByDepartment(req, res, next)
	local department = req.body.department
	local identity = req.body.identity

	if not department or not identity or not utils.switch_identity_str(identity) then
		res:status(http_bad_request):json(search_userByDepartment_code.params_error)
		ngx_log(ngx_err, "user model search user by department params error")
		return
	end

	local mdb, err = mysql:new(mysql_config)
	if not mdb then
		res:status(http_inner_error):json(search_userByDepartment_code.db_error)
		ngx_log(ngx_err, "user model search user by department mysql:new() error:", err)
		return
	end

	local ress, err = mdb:select("select * from `users` where `department`=? and `identity`=?", department, utils.switch_identity_str(identity))
	if not ress then
		res:status(http_inner_error):json(search_userByDepartment_code.db_error)
		ngx_log(ngx_err, "user model search user by department select users error:", err)
		return
	end

	search_userByDepartment_code.gen_success_data(search_userByDepartment_code.success.data, ress[1])
	res:status(http_ok):json(search_userByDepartment_code.success)
	ngx_log(ngx_info, "user model search user by department success")
end

-- 冻结用户
function M.banUser(req, res, next)
	local id = req.body.id

	if not id then
		res:status(http_bad_request):json(ban_user_code.params_error)
		ngx_log(ngx_err, "user model ban user params error")
		return
	end

	local mdb, err = mysql:new(mysql_config)
	if not mdb then
		res:status(http_inner_error):json(ban_user_code.db_error)
		ngx_log(ngx_err, "user model ban user mysql:new() error:", err)
		return
	end

	local ress, err = mdb:update("update `users` set `status`=?,`update_time`=? where `id`=?", define_user_status.frozen, os_time(), id)
	if not ress or ress[1].affected_rows ~= 1 then
		res:status(http_inner_error):json(ban_user_code.db_error)
		ngx_log(ngx_err, "user model ban user update error:", err)
		return
	end

	res:status(http_ok):json(ban_user_code.success)
	ngx_log(ngx_info, "user model ban user success")
end

-- 解冻用户
function M.hotUser(req, res, next)
	local id = req.body.id

	if not id then
		res:status(http_bad_request):json(hot_user_code.params_error)
		ngx_log(ngx_err, "user model hot user params error")
		return
	end

	local mdb, err = mysql:new(mysql_config)
	if not mdb then
		res:status(http_inner_error):json(hot_user_code.db_error)	
		ngx_log(ngx_err, "user model hot user mysql:new() error:", err)	
		return
	end

	local ress, err = mdb:update("update `users` set `status`=?,`update_time`=? where `id`=?", define_user_status.normal, os_time(), id)
	if not ress or ress[1].affected_rows ~= 1 then
		res:status(http_inner_error):json(hot_user_code.db_error)
		ngx_log(ngx_err, "user model hot user update admin error:", err)
		return
	end

	res:status(http_ok):json(hot_user_code.success)
	ngx_log(ngx_info, "user model hot user success")
end

-- 获取冻结用户列表
function M.getBanList(req, res, next)
	local mdb, err = mysql:new(mysql_config)
	if not mdb then
		res:status(http_inner_error):json(get_ban_list_code.db_error)
		ngx_log(ngx_err, "user model get ban list mysql:new() error:", err)
		return
	end

	local ress, err = mdb:select("select * from `users` where `status`=?", define_user_status.frozen)
	if not ress then
		res:status(http_inner_error):json(get_ban_list_code.db_error)
		ngx_log(ngx_err, "user model get ban list select users error:", err)
		return
	end

	get_ban_list_code.gen_success_data(get_ban_list_code.success.data, ress[1])
	res:status(http_ok):json(get_ban_list_code.success)
	ngx_log(ngx_info, "user model get ban list success")
end

-- 删除用户
function M.deleteUser(req, res, next)
	local id = req.body.id

	if not id then	
		res:status(http_bad_request):json(delete_user_code.params_error)
		ngx_log(ngx_err, "user model delete user params error")
		return
	end

	local mdb, err = mysql:new(mysql_config)
	if not mdb then
		res:status(http_inner_error):json(delete_user_code.db_error)
		ngx_log(ngx_err, "user model delete user mysql:new() error:", err)
		return
	end

	local ress, err = mdb:select("select * from `users` where `id`=?", id)
	if not ress or ress[1] == nil or ress[1][1] == nil then
		res:status(http_inner_error):json(delete_user_code.db_error)
		ngx_log(ngx_err, "user model delete user select users error:", err)
		return
	end
	local userInfo = ress[1][1]

	local sqls = string_format("%s;%s;%s;%s;%s;%s", 
		"delete from `users` where `id`="..id, 
		"delete from `user_message_id` where `user_id`="..id,
		"update `product` set `user_id`=0 where `user_id`="..id,
		"update `setting` set `user_id`=0 where `user_id`="..id,
		"update `message` set `user_id`=0 where `user_id`="..id,
		"update `log` set `user_id`=0 where `user_id`="..id)
	local ress, err = mdb:update(sqls)
	if not ress then
		res:status(http_inner_error):json(delete_user_code.db_error)
		ngx_log(ngx_err, "user model delete user delete admin error:", err)
		return
	end

	res:status(http_ok):json(delete_user_code.success)
	ngx_log(ngx_info, "user model delete user success")
	res:eof()

	-- 记录删除日志
	_, err = mdb:insert("insert into `log` set `user_id`=?,`name`=?,`category`=?,`content`=?,`time`=?,`level`=?", userInfo["id"], userInfo["name"], define_log_type.delete, "删除用户", os_time(), define_log_level.high)
	if err then
		ngx_log(ngx_err, "user model delete user insert log error:", err)
	end
end

-- 分批获取用户
function M.batchGetUser(req, res, next)
	local identity = req.body.identity
	local offset = tonumber(req.body.offset)
	local limit = tonumber(req.body.limit)

	if not identity or not utils.switch_identity_str(identity) or not offset or not limit then
		res:status(http_bad_request):json(batch_get_user_code.params_error)
		ngx_log(ngx_err, "user model batch get user params error")
		return	
	end

	local mdb, err = mysql:new(mysql_config)
	if not mdb then
		res:status(http_inner_error):json(batch_get_user_code.db_error)
		ngx_log(ngx_err, "user model batch get user mysql:new() error:", err, "limit:", limit, ", offset:", offset)
		return
	end

	local ress, err = mdb:select("select * from `users` where `identity`=? order by `id` asc limit ?,?", 
		utils.switch_identity_str(identity), offset, limit)
	if not ress then
		res:status(http_inner_error):json(batch_get_user_code.db_error)
		ngx_log(ngx_err, "user model batch get user select users error:", err, "limit:", limit, ", offset:", offset)
		return
	end

	batch_get_user_code.gen_success_data(batch_get_user_code.success.data, ress[1])
	res:status(http_ok):json(batch_get_user_code.success)
	ngx_log(ngx_info, "user model batch get user success, limit:", limit, ", offset:", offset)
end

return M