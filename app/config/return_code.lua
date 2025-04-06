-- Comment: 返回值定义

local tonumber = tonumber
local utils = require("app.utils.utils")
local http_not_found = ngx.HTTP_NOT_FOUND
local http_inner_error = ngx.HTTP_INTERNAL_SERVER_ERROR
local http_unauthorized = ngx.HTTP_UNAUTHORIZED

local return_codes = {
	-- http
	http = {
		-- 未找到
		notFind_error = {
			status = http_not_found,
			message = "404! sorry, not found.",
		},
		-- 内部错误
		inner_error = {
			status = http_inner_error,
			message = "内部错误",
		},
		-- 未授权
		unauthorized_error = {
			status = http_unauthorized,
			message = "未授权，请登录",
		}
	},
	-- 登录
	login = {
		-- 成功
		success = {
			status = 0,
			message = "成功",
			data = {},
		},
		-- 生成成功信息
		gen_success_data = function(dest, src, token)
			dest.token = token
			dest.id = tonumber(src.id)
			dest.account = src.account
			dest.identity = utils.switch_identity(src.identity)
			dest.department = utils.switch_department(src.department)
			dest.name = src.name
			dest.sex = utils.switch_sex(src.sex)
			dest.email = src.email
			dest.image_url = src.image_url
			dest.create_time = tonumber(src.create_time)
			dest.update_time = tonumber(src.update_time)
			dest.status = tonumber(src.status)
		end,
		-- 参数错误
		params_error = {
			status = 1,
			message = "账号或者密码不能为空",
		},
		-- 数据库错误
		db_error = {
			status = 2,
			message = "数据库错误",
		},
		-- 内部错误
		inner_error = {
			status = 3,
			message = "内部错误",
		},
		-- 登录失败
		login_fail = {
			status = 4,
			message = "登录失败",
		},
		-- 密码错误
		password_error = {
			status = 5,
			message = "密码错误",
		},
	},
	-- 注册
	register = {
		-- 成功
		success = {
			status = 0,
			message = "成功",
		},
		-- 参数错误
		params_error = {
			status = 1,
			message = "账号或者密码不能为空",
		},
		-- 参数格式错误
		paramsFormat_error = {
			status = 2,
			message = "",
		},
		-- 数据库错误
		db_error = {
			status = 3,
			message = "数据库错误",
		},
		-- 账号已经存在
		account_exist = {
			status = 4,
			message = "账号已经存在",
		},
	},
	-- 上传头像
	upload_avatar = {
		-- 成功
		success = {
			status = 0,
			message = "成功",
			data = {},
		},
		-- 上传失败
		upload_fail = {
			status = 1,
			message = "上传失败",
		},
	},
}

return return_codes