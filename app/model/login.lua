-- Comment: 登录业务

local http_ok = ngx.HTTP_OK
local http_bad_request = ngx.HTTP_BAD_REQUEST
local http_inner_error = ngx.HTTP_INTERNAL_SERVER_ERROR
local os = os
local os_time = os.time
local ngx_log = ngx.log
local ngx_info = ngx.INFO
local ngx_err = ngx.ERR
local tonumber = tonumber
local login_code = require("app.config.return_code").login
local register_code = require("app.config.return_code").register
local verify_accountandemail_code = require("app.config.return_code").verify_accountandemail
local change_passwordinlogin_code = require("app.config.return_code").change_passwordinlogin
local config = require("app.config.config")
local mysql_config = config.mysql
local mysql = require("lor.lib.utils.mysql")
local lor_utils = require("lor.lib.utils.utils")
local utils = require("app.utils.utils")
local pw = require("lor.lib.utils.password")
local jwt = require("lor.lib.utils.jwt")
local define_user_identity = require("app.config.define").user_identity
local define_user_status = require("app.config.define").user_status
local define_misc = require("app.config.define").misc
local jwtSecretKey = define_misc.jwtSecretKey
local jwtExp = define_misc.jwtExp
local tempJwtExp = define_misc.tempJwtExp
local define_log_type = require("app.config.define").log_type
local define_log_level = require("app.config.define").log_level

local M = {}

-- 登录
function M.login(req, res, next)
	local account = req.body.account
	local password = req.body.password
	
	if not account or not password then
		res:status(http_bad_request):json(login_code.params_error)
		ngx_log(ngx_err, "login model login params error")
		return
	end

	local mdb, err = mysql:new(mysql_config)
	if not mdb then
		res:status(http_inner_error):json(login_code.db_error)
		ngx_log(ngx_err, "login model login mysql:new() error:", err)
		return
	end

	local ress, err = mdb:select("select * from `users` where `account`=?", account)
	if not ress then
		res:status(http_inner_error):json(login_code.db_error)
		ngx_log(ngx_err, "login model login select users error:", err)
		return
	end

	if #ress[1] == 0 then
		res:status(http_ok):json(login_code.login_fail)
		ngx_log(ngx_err, "login model login faild")
		return
	end

	if ress[1][1]["status"] ~= define_user_status.normal then
		res:status(http_ok):json(login_code.status_error)
		ngx_log(ngx_err, "login model login status error")
		return
	end

	local hashed_password = ress[1][1]["password"]
	local ok, err = pw.verify_password(password, hashed_password)
	if not ok or err then
		res:status(http_ok):json(login_code.password_error)
		ngx_log(ngx_err, "login model login password error:", err or "nil")
		return
	end

	local _, err = mdb:update("update `users` set `login_time`=? where `account`=?", os_time(), account)
	if err then
		ngx_log(ngx_err, "login model login update users error:", err)
	end

	local payload_data = lor_utils.clone(ress[1][1])
	payload_data.password = nil
	payload_data.image_url = nil
	payload_data.create_time = nil
	payload_data.update_time = nil
	payload_data.exp = os_time() + jwtExp
	local token, err = jwt.encode(payload_data, jwtSecretKey)
	if not token or err then
		res:status(http_inner_error):json(login_code.inner_error)
		ngx_log(ngx_err, "login model login jwt encode error:", err)
		return
	end

	login_code.gen_success_data(login_code.success.data, ress[1][1], token)
	res:status(http_ok):json(login_code.success)
	local content = lor_utils.json_encode(login_code.success.data)
	ngx_log(ngx_info, "login model register success, data:", content)
	
	res:eof()

	-- 记录登录日志
	local _, err = mdb:insert("insert into `log` set `user_id`=?,`name`=?,`category`=?,`content`=?,`time`=?,`level`=?", ress[1][1]["id"], ress[1][1]["name"], define_log_type.login, content, os_time(), define_log_level.low)
	if err then
		ngx_log(ngx_err, "login model login insert log error:", err)
	end
end

-- 注册
function M.register(req, res, next)
	local account = req.body.account
	local password = req.body.password
	
	if not account or not password or #password <= 0 then
		res:status(http_bad_request):json(register_code.params_error)
		ngx_log(ngx_err, "login model register params error")
		return
	end

	local ok, err = utils.check_account(account)
	if not ok then
		register_code.paramsFormat_error.message = err
		res:status(http_ok):json(register_code.paramsFormat_error)
		ngx_log(ngx_err, "login model register account format error:", err)
		return
	end

	ok, err = utils.check_password(password)
	if not ok then
		register_code.paramsFormat_error.message = err
		res:status(http_ok):json(register_code.paramsFormat_error)
		ngx_log(ngx_err, "login model register password format error:", err)
		return
	end

	local mdb, err = mysql:new(mysql_config)
	if not mdb then
		res:status(http_inner_error):json(register_code.db_error)
		ngx_log(ngx_err, "login model register mysql:new() error:", err)
		return
	end

	local ress, err = mdb:select("select count(1) as c from `users` where `account`=?", account)
	if not ress then
		res:status(http_inner_error):json(register_code.db_error)
		ngx_log(ngx_err, "login model register select users error:", err)
		return
	end

	local nCount = tonumber(ress[1][1]["c"])
	if nCount > 0 then
		res:status(http_ok):json(register_code.account_exist)
		ngx_log(ngx_err, "login model register account exist")
		return
	end
	
	password = pw.hash_password(password)
	ress, err = mdb:insert("insert into `users` set `account`=?,`password`=?,`identity`=?,`create_time`=?,`update_time`=?,`status`=?", account, password, define_user_identity.normal, os.time(), os.time(), define_user_status.normal)
	if not ress or ress[1].affected_rows ~= 1 then
		res:status(http_inner_error):json(register_code.db_error)
		ngx_log(ngx_err, "login model register insert users error:", err)
		return
	end

	res:status(http_ok):json(register_code.success)
	ngx_log(ngx_info, "login model register success")
end

-- 验证账号与邮箱
function M.verify_accountandemail(req, res, next)
	local account = req.body.account
	local email = req.body.email

	if not account or not email then
		res:status(http_bad_request):json(verify_accountandemail_code.params_error)
		ngx_log(ngx_err, "login model verify account and email params error")
		return
	end

	local mdb, err = mysql:new(mysql_config)
	if not mdb then
		res:status(http_inner_error):json(verify_accountandemail_code.db_error)
		ngx_log(ngx_err, "login model verify account and email mysql:new() error:", err)
		return
	end

	local ress, err = mdb:select("select count(1) as c from `users` where `account`=? and `email`=?", account, email)
	if not ress then
		res:status(http_inner_error):json(verify_accountandemail_code.db_error)
		ngx_log(ngx_err, "login model verify account and email select users error:", err)
		return
	end

	local nCount = tonumber(ress[1][1]["c"])
	if nCount <= 0 then
		res:status(http_ok):json(verify_accountandemail_code.verify_fail)
		ngx_log(ngx_err, "login model verify account and email account not exist")
		return
	end

	local payload_data = {}
	payload_data.account = account
	payload_data.exp = os_time() + tempJwtExp

	local token, err = jwt.encode(payload_data, jwtSecretKey)
	if not token or err then
		res:status(http_inner_error):json(verify_accountandemail_code.inner_error)
		ngx_log(ngx_err, "login model verify account and email jwt encode error:", err)
		return
	end

	verify_accountandemail_code.success.data.token = token
	res:status(http_ok):json(verify_accountandemail_code.success)
	ngx_log(ngx_info, "login model verify account and email success")
end

-- 登录页面修改密码
function M.change_passwordinlogin(req, res, next)
	local token = req.body.token
	local new_password = req.body.newPassword

	if not token or not new_password then
		res:status(http_bad_request):json(change_passwordinlogin_code.params_error)
		ngx_log(ngx_err, "login model change password in login params error")
		return
	end

	local payload_data, err = jwt.verify(token, jwtSecretKey)
	if not payload_data or err then
		res:status(http_ok):json(change_passwordinlogin_code.reverify)
		ngx_log(ngx_err, "login model change password in login reverify error:", err)
	end

	local mdb, err = mysql:new(mysql_config)
	if not mdb then
		res:status(http_inner_error):json(change_passwordinlogin_code.db_error)
		ngx_log(ngx_err, "login model change password in login mysql:new() error:", err)
		return
	end

	local hash_password = pw.hash_password(new_password)
	local ress, err = mdb:update("update `users` set `password`=?,`update_time`=?, where account=?", hash_password, os_time(), payload_data.account)
	if not ress or ress[1].affected_rows ~= 1 then
		res:status(http_inner_error):json(change_passwordinlogin_code.db_error)
		ngx_log(ngx_err, "login model change password in login update users password error:", err)
		return
	end

	res:status(http_ok):json(change_passwordinlogin_code.success)
	ngx_log(ngx_info, "login model change password in login success")
end

return M