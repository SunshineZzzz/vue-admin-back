-- Comment: 工具函数

local sgmatch = ngx.re.gmatch
local define_user_identity = require("app.config.define").user_identity

local Utils = {}

-- 账号格式校验
function Utils.check_account(account)
	local iterator, err = sgmatch(account, "^[a-zA-Z0-9]{2,12}$", "jo")
	if not iterator then
		return false, "账号格式错误：需6-12位字母或数字"
	end
	local m, err = iterator()
	if err then
		return false, "账号格式错误：需6-12位字母或数字"
	end
	if m == nil then
		return false, "账号格式错误：需6-12位字母或数字"
	end
	return true, nil
end

-- 密码格式校验
function Utils.check_password(password)
	local iterator, err = sgmatch(password, "^(?![0-9]+$)[a-z0-9]{6,12}$")
	if not iterator then
		return false, "密码格式错误：需6-12位字母和数字组合，且不能全为数字"
	end
	local m, err = iterator()
	if err then
		return false, "密码格式错误：需6-12位字母和数字组合，且不能全为数字"
	end
	if m == nil then
		return false, "密码格式错误：需6-12位字母和数字组合，且不能全为数字"
	end
	return true, nil
end

-- 身份转化为对应字符串
function Utils.switch_identity(identify)
	print(identify)
	if identify == define_user_identity.normal then
		return "用户"
	else
		return ""
	end
end

-- 部门转化为对应字符串
function Utils.switch_department(department)
	return ""
end

-- 性别转化为对应字符串
function Utils.switch_sex(sex)
	if sex == 0 then
		return ""
	end
	if sex == 1 then
		return "男"
	end
	return "女"
end

return Utils
