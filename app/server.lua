-- Comment: 服务实现

local lor = require("lor.index")
local router = require("app.router")
local config = require("app.config.config")
local view_config = config.view
local app = lor()
local http_code = require("app.config.return_code").http
local http_not_found = ngx.HTTP_NOT_FOUND
local http_inner_error = ngx.HTTP_INTERNAL_SERVER_ERROR

-- 模板配置
app:conf("view enable", view_config.enable)
app:conf("view engine", view_config.engine)
app:conf("view ext", view_config.ext)
app:conf("view layout", view_config.layout)
app:conf("views", view_config.views)

-- session和cookie支持，如果不需要可注释以下配置
local mw_cookie = require("lor.lib.middleware.cookie")
-- local mw_session = require("lor.lib.middleware.session")
app:use(mw_cookie())
-- app:use(mw_session({
-- 	session_key = "__app__", -- the key injected in cookie
-- 	session_aes_key = "aes_key_for_session", -- should set by yourself
-- 	timeout = 3600 -- default session timeout is 3600 seconds
-- }))
-- jwt支持，如果不需要可注释以下配置
local define_misc = require("app.config.define").misc
local mw_jet = require("lor.lib.middleware.jwt")
app:use(mw_jet({
	key = define_misc.jwtSecretKey,
	exclude = {"^/login/"}, --"^/api/"},
	notToken = http_code.unauthorized_error,
}))

-- 自定义中间件1: 注入一些全局变量供模板渲染使用
local mw_inject_version = require("app.middleware.inject_app_info")
app:use(mw_inject_version())

-- 自定义中间件2: 设置响应头
app:use(function(req, res, next)
	res:set_header("X-Powered-By", "Lor framework")
	next()
end)

router(app) -- 业务路由处理

-- 错误处理插件，可根据需要定义多个
app:erroruse(function(err, req, res, next)
	ngx.log(ngx.ERR, err)

	if req:is_found() ~= true then
		res:status(http_not_found):json(http_code.notFind_error)
	else
		res:status(http_inner_error):json(http_code.inner_error)
	end
end)

return app
