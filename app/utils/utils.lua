-- Comment: 工具函数

local sgmatch = ngx.re.gmatch
local define_user_identity = require("app.config.define").user_identity
local define_user_department = require("app.config.define").user_department
local define_message_level = require("app.config.define").message_level

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
	if identify == define_user_identity.normal then
		return "用户"
	elseif identify == define_user_identity.userMgr then
		return "用户管理员"
	elseif identify == define_user_identity.productMgr then
		return "产品管理员"
	else
		-- define_user_identity.root
		return "超级管理员"
	end
end

-- 身份字符串转化为对应类型
function Utils.switch_identity_str(identify)
	if identify == "用户" then
		return define_user_identity.normal
	elseif identify == "用户管理员" then
		return define_user_identity.userMgr
	elseif identify == "产品管理员" then
		return define_user_identity.productMgr
	elseif identify == "消息管理员" then
		return define_user_identity.messageMgr
	else
		-- 超级管理员
		return define_user_identity.root
	end
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

-- 消息等级转化为对应字符串
function Utils.switch_message_level(level)
	if level == define_message_level.normal then
		return "一般"
	end
	if level == define_message_level.important then
		return "重要"
	end
	return "必要"
end

return Utils
