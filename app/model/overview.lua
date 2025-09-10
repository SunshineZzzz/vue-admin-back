-- Comment: 总览业务

local http_ok = ngx.HTTP_OK
local http_bad_request = ngx.HTTP_BAD_REQUEST
local http_inner_error = ngx.HTTP_INTERNAL_SERVER_ERROR
local ngx_log = ngx.log
local ngx_info = ngx.INFO
local ngx_err = ngx.ERR
local unpack = unpack
local string_format = string.format
local config = require("app.config.config")
local mysql_config = config.mysql
local mysql = require("lor.lib.utils.mysql")
local get_categoryAndTotalPrice_code = require("app.config.return_code").get_categoryAndTotalPrice
local get_identifyAndNumber_code = require("app.config.return_code").get_identifyAndNumber
local get_dayAndNumber_code = require("app.config.return_code").get_dayAndNumber
local get_levelAndNumber_code = require("app.config.return_code").get_levelAndNumber
local define_setting_type = require("app.config.define").setting_type
local lor_utils = require("lor.lib.utils.utils")
local define_log_type = require("app.config.define").log_type

local M = {}

-- 获取产品类别和其总价
function M.getCategoryAndTotalPrice(req, res, next)
    local mdb, err = mysql:new(mysql_config)
    if not mdb then
        res:status(http_inner_error):json(get_categoryAndTotalPrice_code.db_error)
        ngx_log(ngx_err, "overview model get category and total price mysql:new() error:", err)
        return
    end

    local ress, err = mdb:select("select `value` from `setting` where `category`=?", define_setting_type.productType)
    if not ress then
        res:status(http_inner_error):json(get_categoryAndTotalPrice_code.db_error)
        ngx_log(ngx_err, "overview model get category and total price select setting error:", err)
        return
    end

    if ress[1][1] == nil then
        get_categoryAndTotalPrice_code.gen_success_data(
            get_categoryAndTotalPrice_code.success.data, 
            nil)
        res:status(http_ok):json(get_categoryAndTotalPrice_code.success)
        ngx_log(ngx_info, "overview model get category and total price success1")
        return
    end

    local products = lor_utils.json_decode(ress[1][1]["value"])
    if products == nil then
        res:status(http_ok):json(get_categoryAndTotalPrice_code.inner_error)
        ngx_log(ngx_err, "overview model get category and total price decode error")
        return
    end

    local placeholders, values = lor_utils.build_condition(products)
    ress, err = mdb:select(string_format("select `category`,sum(`price`*`quantity`) as `total_price` from product where `category` in (%s) group by `category`", placeholders), unpack(values))
    if not ress then
        res:status(http_inner_error):json(get_categoryAndTotalPrice_code.db_error)
        ngx_log(ngx_err, "overview model get category and total price select product error:", err)
        return
    end

    get_categoryAndTotalPrice_code.gen_success_data(get_categoryAndTotalPrice_code.success.data, ress[1])
    res:status(http_ok):json(get_categoryAndTotalPrice_code.success)
    ngx_log(ngx_info, "overview model get category and total price success2")
end

-- 获取不同身份和其数量
function M.getIdentityAndNumber(req, res, next)
    local mdb, err = mysql:new(mysql_config)
    if not mdb then
        res:status(http_inner_error):json(get_identifyAndNumber_code.db_error)
        ngx_log(ngx_err, "overview model get identity and number mysql:new() error:", err)
        return
    end

    local ress, err = mdb:select("select `identity`, count(*) as `number` from `users` group by `identity`")
    if not ress then
        res:status(http_inner_error):json(get_identifyAndNumber_code.db_error)
        ngx_log(ngx_err, "overview model get identity and number select users error:", err)
        return
    end

    get_identifyAndNumber_code.gen_success_data(get_identifyAndNumber_code.success.data, ress[1])
    res:status(http_ok):json(get_identifyAndNumber_code.success)
    ngx_log(ngx_info, "overview model get identity and number success")
end

-- 获取不同消息等级与数量
function M.getLevelAndNumber(req, res, next)
    local mdb, err = mysql:new(mysql_config)
    if not mdb then
        res:status(http_inner_error):json(get_levelAndNumber_code.db_error)
        ngx_log(ngx_err, "overview model get level and number mysql:new() error:", err)
        return
    end

    local ress, err = mdb:select("select `level`, count(*) as `number` from `message` group by `level` order by `level` asc")
    if not ress then
        res:status(http_inner_error):json(get_levelAndNumber_code.db_error)
        ngx_log(ngx_err, "overview model get level and number select message error:", err)
        return
    end

    get_levelAndNumber_code.gen_success_data(get_levelAndNumber_code.success.data, ress[1])
    res:status(http_ok):json(get_levelAndNumber_code.success)
    ngx_log(ngx_info, "overview model get level and number success")
end

-- 获取每天登录人数
function M.getDayAndNumber(req, res, next)
    local rangeDay = req.body.rangeDay

    if not rangeDay then
        res:status(http_bad_request):json(get_dayAndNumber_code.params_error)
        ngx_log(ngx_err, "overview model get day and number params error")
        return
    end

    local end_date = os.date("%Y-%m-%d") .. " 23:59:59"
    local start_date = os.date("%Y-%m-%d", os.time() - (rangeDay-1)*3600*24) .. " 00:00:00"

    local mdb, err = mysql:new(mysql_config)
    if not mdb then
        res:status(http_inner_error):json(get_dayAndNumber_code.db_error)
        ngx_log(ngx_err, "overview model get day and number mysql:new() error:", err)
        return
    end

    local ress, err = mdb:select("select date(from_unixtime(`time`)) as `login_date`, count(`id`) as `user_count` from `log` where `time`>=unix_timestamp(?) and `time`<=unix_timestamp(?) and `time`>0 and `category`=? group by login_date", start_date, end_date, define_log_type.login)
    if not ress then
        res:status(http_inner_error):json(get_dayAndNumber_code.db_error)
        ngx_log(ngx_err, "overview model get day and number select users error:", err)
        return
    end

    get_dayAndNumber_code.gen_success_data(get_dayAndNumber_code.success.data, ress[1])
    res:status(http_ok):json(get_dayAndNumber_code.success)
    ngx_log(ngx_info, "overview model get day and number success")
end

return M