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
local config = require("app.config.config")
local mysql_config = config.mysql
local mysql = require("lor.lib.utils.mysql")
local lor_utils = require("lor.lib.utils.utils")
local utils = require("app.utils.utils")
local pw = require("lor.lib.utils.password")
local jwt = require("lor.lib.utils.jwt")
local define_user_identity = require("app.config.define").user_identity
local define_misc = require("app.config.define").misc
local jwtSecretKey = define_misc.jwtSecretKey
local jwtExp = define_misc.jwtExp

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

	local hashed_password = ress[1][1]["password"]
	local ok, err = pw.verify_password(password, hashed_password)
	if not ok or err then
		res:status(http_ok):json(login_code.password_error)
		ngx_log(ngx_err, "login model login password error:", err or "nil")
		return
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
	ngx_log(ngx_info, "login model register success, data:", lor_utils.json_encode(login_code.success.data))
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
	ress, err = mdb:insert("insert into `users` set `account`=?,`password`=?,`identity`=?,`create_time`=?", account, password, define_user_identity.normal, os.time())
	if not ress or ress[1].affected_rows ~= 1 then
		res:status(http_inner_error):json(register_code.db_error)
		ngx_log(ngx_err, "login model register insert users error:", err)
		return
	end

	res:status(http_ok):json(register_code.success)
	ngx_log(ngx_info, "login model register success")
end

return M