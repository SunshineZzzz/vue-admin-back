-- Comment: 总览业务

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
local get_categoryAndTotalPrice_code = require("app.config.return_code").get_categoryAndTotalPrice
local get_identifyAndNumber_code = require("app.config.return_code").get_identifyAndNumber
local get_dayAndNumber_code = require("app.config.return_code").get_dayAndNumber
local define_setting_type = require("app.config.define").setting_type
local lor_utils = require("lor.lib.utils.utils")

local M = {}

-- 获取产品类别和其总价
function M.getCategoryAndTotalPrice(req, res, next)
    local mdb, err = mysql:new(mysql_config)
    if not mdb then
        res:status(http_inner_error):json(get_categoryAndTotalPrice_code.db_error)
        ngx_log(ngx_err, "overview model get category and total price mysql:new() error:", err)
        return
    end

    local ress, err = mdb:select("select `value` from `setting` where `category`=?", define_setting_type.product)
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

    products = lor_utils.json_decode(ress[1][1]["value"])
    if products == nil then
        res:status(http_ok):json(get_categoryAndTotalPrice_code.inner_error)
        ngx_log(ngx_err, "overview model get category and total price decode error")
        return
    end

    local tmpKey = {}
    for key, _ in pairs(products) do
        table_insert(tmpKey, key)
    end

    ress, err = mdb:select("select `category`, sum(`price`*`quantity`) as `total_price` from product where category in (?) group by category", table_concat(tmpKey, ","))
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

-- 
function M.getLevelAndNumber(req, res, next)
end

-- 获取每天登录人数
function M.getDayAndNumber(req, res, next)
    local rangeDay = req.body.rangeDay

    if not rangeDay then
        res:status(http_bad_request):json(get_dayAndNumber_code.params_error)
        ngx_log(ngx_err, "overview model get day and number params error")
        return
    end

    local end_date = os.date("%Y-%m-%d")
    local start_date = os.date("%Y-%m-%d", os.time() - (rangeDay-1)*3600*24)

    local mdb, err = mysql:new(mysql_config)
    if not mdb then
        res:status(http_inner_error):json(get_dayAndNumber_code.db_error)
        ngx_log(ngx_err, "overview model get day and number mysql:new() error:", err)
        return
    end

    local ress, err = mdb:select("select date(from_unixtime(`login_time`)) as `login_date`, count(`id`) as `user_count` from `users` where `login_time`>=unix_timestamp('? 00:00:00') and `login_time`<=unix_timestamp('? 23:59:59') and `login_time`>0 group by login_date", start_date, end_date)
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