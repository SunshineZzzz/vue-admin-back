-- Comment: 工具函数

local sgmatch = ngx.re.gmatch
local define_user_identity = require("app.config.define").user_identity
local define_product_status = require("app.config.define").product_status
local define_message_level = require("app.config.define").message_level
local define_log_level = require("app.config.define").log_level
local table_concat = table.concat

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
	elseif identify == define_user_identity.messageMgr then
		return "消息管理员"
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
	elseif identify == "超级管理员" then
		return define_user_identity.root
	else
		return nil
	end
end

-- 消息等级转化为对应字符串
function Utils.switch_message_level(level)
	if level == define_message_level.normal then
		return "一般", nil
	end

	if level == define_message_level.important then
		return "重要", nil
	end

	if level == define_message_level.emergency then
		return "必要", nil
	end

	return "", "未知等级"
end

-- 消息字符串转化为对应类型
function Utils.switch_message_level_str(level)
	if level == "一般" then
		return define_message_level.normal
	end

	if level == "重要" then
		return define_message_level.important
	end

	if level == "必要" then
		return define_message_level.emergency
	end

	return nil
end

-- 日志等级转化为对应字符串
function Utils.switch_log_level(level)
	if level == define_log_level.low then
		return "低级"
	end
	if level == define_log_level.important then
		return "中级"
	end
	return "高级"
end

-- 产品状态转化为对应字符串
function Utils.switch_product_status(status)
	if status == define_product_status.normal then
		return "正常"
	elseif status == define_product_status.applying then
		return "申请出库"
	elseif status == define_product_status.agreeApply then
		return "同意出库"
	elseif status == define_product_status.rejectApply then
		return "拒绝出库"
	else
		return "未知状态"
	end
end

-- 产品搜索状态转化为对应字符串
function Utils.swicth_product_sType(status)
	if status == 1 then
		return table_concat({define_product_status.normal, define_product_status.applying}, ","), nil
	elseif status == 2 then
		return table_concat({define_product_status.applying, define_product_status.rejectApply}, ","), nil
	elseif status == 3 then
		return nil, nil
	else
		return nil, "未知状态"
	end
end

return Utils
