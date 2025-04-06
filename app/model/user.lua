local string_format = string.format
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
local utils = require("app.utils.utils")
local lor_utils = require("lor.lib.utils.utils")
local upload_avatar_code = require("app.config.return_code").upload_avatar
local define_misc = require("app.config.define").misc
local avatar_dir = define_misc.avatarDir

local M = {}

-- 上传头像 & 上传头像返回
function M.upload_avatar(req, res, next)
	local out_path = string_format("%s/%s/%s/avatar.png", upload_config.outDir, tostring(req.jwt.id), avatar_dir)
	local path = string_format("%s/%s/%s/avatar.png", upload_config.dir, tostring(req.jwt.id), avatar_dir)

	local ok, err = lor_utils.rmkdir(lor_utils.dirname(path))
	if not ok then
		res:status(http_inner_error):json(upload_avatar_code.upload_fail)
		ngx_log(ngx_err, "user model upload avatar mkdir error:", err, ", dir:", path)
		return
	end

	local file_path, _, _, err = lor_utils.multipart_formdata(upload_config, path, true, {["image/png"] = 1})
	if err then
		res:status(http_inner_error):json(upload_avatar_code.upload_fail)
		ngx_log(ngx_err, "user model upload avatar multipart formdata error:", err, ", dir:", path)
		return
	end
	
	local mdb, err = mysql:new(mysql_config)
	if not mdb then
		res:status(http_inner_error):json(upload_avatar_code.upload_fail)
		ngx_log(ngx_err, "user model upload avatar mysql:new() error:", err, ", dir:", path)
		return
	end

	local ress, err = mdb:update("update `users` set `image_url`=? where `id`=?", out_path, req.jwt.id)
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

return M