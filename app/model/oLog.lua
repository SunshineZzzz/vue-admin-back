-- Comment: 操作日志业务

local http_ok = ngx.HTTP_OK
local http_bad_request = ngx.HTTP_BAD_REQUEST
local http_inner_error = ngx.HTTP_INTERNAL_SERVER_ERROR
local ngx_log = ngx.log
local ngx_info = ngx.INFO
local ngx_err = ngx.ERR
local tonumber = tonumber
local pairs = pairs
local config = require("app.config.config")
local mysql_config = config.mysql
local mysql = require("lor.lib.utils.mysql")
local utils = require("app.utils.utils")
local define_log_type = require("app.config.define").log_type
local table_insert = table.insert
local get_oLogType_code = require("app.config.return_code").get_oLogType
local get_oLogListLength_code = require("app.config.return_code").get_oLogListLength
local batch_getOlogList_code = require("app.config.return_code").batch_getOlogList
local clearOLogList_code = require("app.config.return_code").clearOLogList
local search_OLogListByType_code = require("app.config.return_code").search_OLogListByType

local M = {}

-- 获取操作日志类别
function M.getOLogType(req, res, next)
    local categoryArr = {}
    for _, v in pairs(define_log_type) do
        table_insert(categoryArr, utils.switch_log_type_str(v))
    end

    get_oLogType_code.success.data.categoryArr = categoryArr
	res:status(http_ok):json(get_oLogType_code.success)
	ngx_log(ngx_info, "olog model get olog type success")
end

-- 获取操作日志列表长度
function M.getOLogListLength(req, res, next)
    local mdb, err = mysql:new(mysql_config)
    if not mdb then
        res:status(http_inner_error):json(get_oLogListLength_code.db_error)
        ngx_log(ngx_err, "olog model get olog list length db error:", err)
        return
    end

    local ress, err = mdb:select("select count(*) as `c` from `log`")
    if not res then
        res:status(http_inner_error):json(get_oLogListLength_code.db_error)
        ngx_log(ngx_err, "olog model get olog list length select error:", err)
        return
    end

    get_oLogListLength_code.success.data.count = ress[1][1]['c']
    res:status(http_ok):json(get_oLogListLength_code.success)
    ngx_log(ngx_info, "olog model get olog list length success")
end

-- 分批获取操作日志列表
function M.batchGetOLogList(req, res, next)
    local offset = tonumber(req.body.offset)
    local limit = tonumber(req.body.limit)

    if not offset or not limit then
        res:status(http_bad_request):json(batch_getOlogList_code.params_error)
        ngx_log(ngx_err, "olog model batch get olog list param error")
        return
    end

    local mdb, err = mysql:new(mysql_config)
    if not mdb then
        res:status(http_inner_error):json(batch_getOlogList_code.db_error)
        ngx_log(ngx_err, "olog model batch get olog list db error:", err)
        return
    end

    local ress, err = mdb:select("select * from `log` order by `id` desc limit ?,?", offset, limit)
    if not ress then
        res:status(http_inner_error):json(batch_getOlogList_code.db_error)
        ngx_log(ngx_err, "olog model batch get olog list select error:", err)
        return
    end

    batch_getOlogList_code.gen_success_data(batch_getOlogList_code.success.data, ress[1])
    res:status(http_ok):json(batch_getOlogList_code.success)
    ngx_log(ngx_info, "olog model batch get olog list success")
end

-- 清空操作日志
function M.clearOLogList(req, res, next)
    local mdb, err = mysql:new(mysql_config)
    if not mdb then
        res:status(http_inner_error):json(clearOLogList_code.db_error)
        ngx_log(ngx_err, "olog model clear olog list db error:", err)
        return
    end

    local ress, err = mdb:delete("delete from `log`")
    if not ress then
        res:status(http_inner_error):json(clearOLogList_code.db_error)
        ngx_log(ngx_err, "olog model clear olog list exec error:", err)
        return
    end

    res:status(http_ok):json(clearOLogList_code.success)
    ngx_log(ngx_info, "olog model clear olog success")
end

-- 按类型获取操作日志列表
function M.searchOLogListByType(req, res, next)
    local typeStr = req.body.type

    if not typeStr then
        res:status(http_bad_request):json(search_OLogListByType_code.params_error)
        ngx_log(ngx_err, "olog model search olog list by type param error")
        return
    end

    local mdb, err = mysql:new(mysql_config)
    if not mdb then
        res:status(http_inner_error):json(search_OLogListByType_code.db_error)
        ngx_log(ngx_err, "olog model search olog list by type db error:", err)
        return
    end

    local ress, err = mdb:select("select * from `log` where `category`=?", utils.switch_log_type(typeStr))
    if not ress then
        res:status(http_inner_error):json(search_OLogListByType_code.db_error)
        ngx_log(ngx_err, "olog model search olog list by type select error:", err)
        return
    end

    search_OLogListByType_code.gen_success_data(search_OLogListByType_code.success.data, ress[1])
    res:status(http_ok):json(search_OLogListByType_code.success)
    ngx_log(ngx_info, "olog model search olog list by type success")
end

return M