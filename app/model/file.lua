-- Comment: 文件业务

local http_ok = ngx.HTTP_OK
local http_bad_request = ngx.HTTP_BAD_REQUEST
local http_inner_error = ngx.HTTP_INTERNAL_SERVER_ERROR
local ngx_log = ngx.log
local ngx_info = ngx.INFO
local ngx_err = ngx.ERR
local os_time = os.time
local config = require("app.config.config")
local mysql_config = config.mysql
local mysql = require("lor.lib.utils.mysql")
local upload_config = config.upload
local string_format = string.format
local lor_utils = require("lor.lib.utils.utils")
local define_misc = require("app.config.define").misc
local file_dir = define_misc.fileDir
local define_log_type = require("app.config.define").log_type
local define_log_level = require("app.config.define").log_level
local upload_file_code = require("app.config.return_code").upload_file
local update_downloadNum_code = require("app.config.return_code").update_downloadNum
local file_listLength_code = require("app.config.return_code").file_listLength
local file_getFileList_code = require("app.config.return_code").file_getFileList
local search_fileByName_code = require("app.config.return_code").search_fileByName
local delete_file_code = require("app.config.return_code").delete_file

local M = {}

-- 上传文件
function M.uploadFile(req, res, next)
	local out_path = string_format("%s/%s", upload_config.outDir, file_dir)
	local path = string_format("%s/%s/", upload_config.dir, file_dir)

	local ok, err = lor_utils.rmkdir(path)
	if not ok then
		res:status(http_inner_error):json(upload_file_code.upload_fail)
		ngx_log(ngx_err, "file model upload file mkdir error:", err, ", dir:", path)
		return
	end

	local file_path, origin_filename, file_size, file_type, extraParam, err = lor_utils.multipart_formdata(upload_config, path, false, {["image/jpeg"]=1,["image/png"]=1,["application/pdf"]=1})
	if err then
		res:status(http_inner_error):json(upload_file_code.upload_fail)
		ngx_log(ngx_err, "file model upload file multipart formdata error:", err, ", dir:", path)
		return
	end

    if not extraParam.user_id or not extraParam.user_name then
		res:status(http_bad_request):json(upload_file_code.params_error)
		ok = lor_utils.file_remove(file_path)
		ngx_log(ngx_err, "file model upload file params error, file remove:", tostring(ok))
		return
	end

	out_path = string_format("%s/%s", out_path, origin_filename)

	local mdb, err = mysql:new(mysql_config)
	if not mdb then
		res:status(http_inner_error):json(upload_file_code.db_error)
		ngx_log(ngx_err, "file model upload file mysql:new() error:", err)
		return
	end

	local ress, err = mdb:update("insert into `files`(`user_id`,`user_name`,`name`,`url`,`size`,`type`,`download_number`,`create_time`) values (?,?,?,?,?,?,?,?)", 
        extraParam.user_id, extraParam.user_name, origin_filename, out_path, file_size, file_type, 0, os_time())
	if not ress then
		res:status(http_inner_error):json(upload_file_code.db_error)
		ngx_log(ngx_err, "file model upload file insert setting error:", err)
		return
	end

	upload_file_code.success.data.url = out_path
	res:status(http_ok):json(upload_file_code.success)
	ngx_log(ngx_info, "file model upload file success")

	res:eof()

	-- 记录日志
	local _, err = mdb:insert("insert into `log` set `user_id`=?,`name`=?,`category`=?,`content`=?,`time`=?,`level`=?", extraParam.user_id, extraParam.user_name, define_log_type.file_upload, out_path, os_time(), define_log_level.middle)
	if err then
		ngx_log(ngx_err, "file model upload file insert log error:", err)
	end
end

-- 更新下载次数
function M.updateDownloadNum(req, res, next)
	local file_id = req.body.file_id
	local download_number = tonumber(req.body.download_number) or 1

	if not file_id or not download_number then
		res:status(http_bad_request):json(update_downloadNum_code.params_error)
		ngx_log(ngx_err, "file model update download number params error")
		return
	end

	local mdb, err = mysql:new(mysql_config)
	if not mdb then
		res:status(http_inner_error):json(update_downloadNum_code.db_error)
		ngx_log(ngx_err, "file model update download number mysql:new() error:", err)
		return
	end

	local ress, err = mdb:update("update `files` set `download_number`=`download_number`+? where `id`=?", file_id, download_number)
	if not ress then
		res:status(http_inner_error):json(update_downloadNum_code.db_error)
		ngx_log(ngx_err, "file model update download number update error:", err)
		return
	end

	res:status(http_ok):json(update_downloadNum_code.success)
	ngx_log(ngx_info, "file model update download number success")
end

-- 获取文件列表总数
function M.fileListLength(req, res, next)
	local mdb, err = mysql:new(mysql_config)
	if not mdb then
		res:status(http_inner_error):json(file_listLength_code.db_error)
		ngx_log(ngx_err, "file model file list length mysql:new() error:", err)
		return
	end

	local ress, err = mdb:select("select count(*) as c from `files`")
	if not ress then
		res:status(http_inner_error):json(file_listLength_code.db_error)
		ngx_log(ngx_err, "file model file list length select message error:", err)
		return
	end

	file_listLength_code.gen_success_data(file_listLength_code.success.data, ress[1][1])
	res:status(http_ok):json(file_listLength_code.success)
	ngx_log(ngx_info, "file model file list length success")
end

-- 分批获取文件列表
function M.batchGetFileList(req, res, next)
	local offset = tonumber(req.body.offset)
	local limit = tonumber(req.body.limit)	

	if not offset or not limit then
		res:status(http_bad_request):json(file_getFileList_code.params_error)
		ngx_log(ngx_err, "file model batch get file list params error")
		return
	end

	local mdb, err = mysql:new(mysql_config)
	if not mdb then
		res:status(http_inner_error):json(file_getFileList_code.db_error)
		ngx_log(ngx_err, "file model batch get file list mysql:new() error:", err)
		return
	end

	local ress, err = mdb:select("select * from `files` order by `id` desc limit ?,?", offset, limit)
	if not ress then
		res:status(http_inner_error):json(file_getFileList_code.db_error)
		ngx_log(ngx_err, "file model batch get file list select message error:", err)
		return
	end

	file_getFileList_code.gen_success_data(file_getFileList_code.success.data, ress[1])
	res:status(http_ok):json(file_getFileList_code.success)
	ngx_log(ngx_info, "file model batch get file list success")
end

-- 搜索文件
function M.searchFileByName(req, res, next)
	local file_name = req.body.file_name

	if not file_name then
		res:status(http_bad_request):json(search_fileByName_code.params_error)
		ngx_log(ngx_err, "file model search file by name params error")
		return
	end

	local mdb, err = mysql:new(mysql_config)
	if not mdb then
		res:status(http_inner_error):json(search_fileByName_code.db_error)
		ngx_log(ngx_err, "file model search file by name mysql:new() error:", err)
		return
	end

	local ress, err = mdb:select("select * from `files` where `file_name`=?", file_name)
	if not ress then
		res:status(http_inner_error):json(search_fileByName_code.db_error)
		ngx_log(ngx_err, "file model search file by name select message error:", err)
		return
	end

	search_fileByName_code.gen_success_data(search_fileByName_code.success.data, ress[1])
	res:status(http_ok):json(search_fileByName_code.success)
	ngx_log(ngx_info, "file model search file by name success")
end

-- 删除文件
function M.deleteFile(req, res, next)
	local file_id = req.body.file_id
	local user_id = req.body.id
	local user_name = req.body.name

	if not file_id or not user_id or not user_name then
		res:status(http_bad_request):json(delete_file_code.params_error)
		ngx_log(ngx_err, "file model delete file params error")
		return
	end

	local mdb, err = mysql:new(mysql_config)
	if not mdb then
		res:status(http_inner_error):json(delete_file_code.db_error)
		ngx_log(ngx_err, "file model delete file mysql:new() error:", err)
		return
	end

	local ress, err = mdb:delete("delete from `files` where `id`=?", file_id)
	if not ress then
		res:status(http_inner_error):json(delete_file_code.db_error)
		ngx_log(ngx_err, "file model delete file delete message error:", err)
		return
	end

	res:status(http_ok):json(delete_file_code.success)
	ngx_log(ngx_info, "file model delete file success")

	res:eof()

	-- 记录日志
	local _, err = mdb:insert("insert into `log` set `user_id`=?,`name`=?,`category`=?,`content`=?,`time`=?,`level`=?", user_id, user_name, define_log_type.file_delete, file_id, os_time(), define_log_level.high)
	if err then
		ngx_log(ngx_err, "file model delete file insert log error:", err)
	end
end

return M