-- Comment: 返回值定义

local ipairs = ipairs
local table_insert = table.insert
local tonumber = tonumber
local utils = require("app.utils.utils")
local http_not_found = ngx.HTTP_NOT_FOUND
local http_inner_error = ngx.HTTP_INTERNAL_SERVER_ERROR
local http_unauthorized = ngx.HTTP_UNAUTHORIZED
local lor_utils = require("lor.lib.utils.utils")

local parese_message = function(dest, src)
	dest.messageArr = {}
	if not src or#src == 0 then
		return
	end
	for _, v in ipairs(src) do
		table_insert(dest.messageArr, 
		{
			id = v.id,
			msg_id = v.msg_id,
			category = v.category,
			title = v.title,
			content = v.content,
			create_time = tonumber(v.create_time),
			update_time = tonumber(v.update_time),
			delete_time = tonumber(v.delete_time),
			department = v.department,
			name = v.name,
			level = utils.switch_message_level(v.level),
			status = v.status,
			click_num = v.click_num,
		})
	end
end

-- TODO，应该把公共错误提取出来
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
			dest.department = src.department
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
		-- 用户状态错误
		status_error = {
			status = 5,
			message = "用户状态错误",
		},
		-- 密码错误
		password_error = {
			status = 6,
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
	-- 验证账号与邮箱
	verify_accountandemail = {
		-- 成功
		success = {
			status = 0,
			message = "成功",
			data = {},
		},
		-- 参数错误
		params_error = {
			status = 1,
			message = "账号或者邮箱不能为空",
		},
		-- 数据库错误
		db_error = {
			status = 2,
			message = "数据库错误",
		},
		-- 验证失败
		verify_fail = {
			status = 3,
			message = "验证失败",
		},
		-- 内部错误
		inner_error = {
			status = 4,
			message = "内部错误",
		},
	},
	-- 登录界面修改密码 
	change_passwordinlogin = {
		-- 成功
		success = {
			status = 0,
			message = "成功",
		},
		-- 参数错误
		params_error = {
			status = 1,
			message = "参数错误",
		},
		-- 请重新验证
		reverify = {
			status = 2,
			message = "请重新验证",
		},
		-- 数据库错误
		db_error = {
			status = 3,
			message = "数据库错误",
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
	-- 修改密码
	change_password = {
		-- 成功
		success = {
			status = 0,
			message = "成功",
		},
		-- 参数错误
		params_error = {
			status = 2,
			message = "参数错误",
		},
		-- 数据库错误
		db_error = {
			status = 3,
			message = "数据库错误",
		},
		-- 密码错误
		password_error = {
			status = 4,
			message = "密码错误",
		},
	},
	-- 获取用户信息
	get_userinfo = {
		success = {
			-- 成功
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
			dest.department = src.department
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
			status = 2,
			message = "参数错误",
		},
		-- 数据库错误
		db_error = {
			status = 3,
			message = "数据库错误",
		},
		-- 用户不存在
		user_not_exist = {
			status = 4,
			message = "用户不存在",
		},
	},
	-- 修改昵称
	change_name = {
		-- 成功
		success = {
			status = 0,
			message = "成功",
		},
		-- 参数错误
		params_error = {
			status = 1,
			message = "参数错误",
		},
		-- 数据库错误
		db_error = {
			status = 2,
			message = "数据库错误",
		},
	},
	-- 修改性别
	change_sex = {
		-- 成功
		success = {
			status = 0,
			message = "成功",
		},
		-- 参数错误
		params_error = {
			status = 1,
			message = "参数错误",
		},
		-- 数据库错误
		db_error = {
			status = 2,
			message = "数据库错误",
		},
	},
	-- 修改邮箱
	change_email = {
		-- 成功
		success = {
			status = 0,
			message = "成功",
		},
		-- 参数错误
		params_error = {
			status = 1,
			message = "参数错误",
		},
		-- 数据库错误
		db_error = {
			status = 2,
			message = "数据库错误",
		},
	},
	-- 上传轮播图
	upload_swiper = {
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
		-- 参数错误
		params_error = {
			status = 2,
			message = "参数错误",
		},
		-- 数据库错误
		db_error = {
			status = 3,
			message = "数据库错误",
		},
	},
	-- 获取所有轮播图
	get_allSwiper = {
		-- 成功
		success = {
			status = 0,
			message = "成功",
			data = {},
		},
		-- 生成成功信息
		gen_success_data = function(dest, src)
			dest.swiperArr = {}
			for i=1, #src do
				table_insert(dest.swiperArr, src[i]["value"])
			end
		end,
		-- 数据库错误
		db_error = {
			status = 1,
			message = "数据库错误",
		},
	},
	-- 获取公司名称
	get_companyName = {
		-- 成功
		success = {
			status = 0,
			message = "成功",
			data = {},
		},
		-- 数据库错误
		db_error = {
			status = 1,
			message = "数据库错误",
		},
	},
	-- 修改公司名称 
	change_companyName = {
		-- 成功
		success = {
			status = 0,
			message = "成功",
		},
		-- 参数错误
		params_error = {
			status = 1,
			message = "参数错误",
		},
		-- 数据库错误
		db_error = {
			status = 2,
			message = "数据库错误",
		},
	},
	-- 获取公司简介 
	get_companyIntroduce = {
		-- 成功
		success = {
			status = 0,
			message = "成功",
			data = {},
		},
		-- 参数错误
		params_error = {
			status = 1,
			message = "参数错误",
		},
		-- 数据库错误
		db_error = {
			status = 2,
			message = "数据库错误",
		},
	},
	-- 修改公司简介
	change_companyIntroduce = {
		-- 成功
		success = {
			status = 0,
			message = "成功",
		},
		-- 参数错误
		params_error = {
			status = 1,
			message = "参数错误",
		},
		-- 数据库错误
		db_error = {
			status = 2,
			message = "数据库错误",
		},
	},
	-- 获取所有公司信息
	get_allCompanyInfo = {
		-- 成功
		success = {
			status = 0,
			message = "成功",
			data = {},
		},
		-- 生成成功信息
		gen_success_data = function(dest, src)
			dest.companyInfo = {}
			for i=1, #src do
				dest.companyInfo[src[i]["key"]] = src[i]["value"]
			end
		end,
		-- 数据库错误
		db_error = {
			status = 1,
			message = "数据库错误",
		},
	},
	-- 设置公司部门
	set_department = {
		-- 成功
		success = {
			status = 0,
			message = "成功",
		},
		-- 参数错误
		params_error = {
			status = 1,
			message = "参数错误",
		},
		-- 数据库错误
		db_error = {
			status = 2,
			message = "数据库错误",
		},
	},
	-- 获取公司部门
	get_department = {
		-- 成功
		success = {
			status = 0,
			message = "成功",
			data = {},
		},
		gen_success_data = function(dest, src)
			dest.department = {}
			for i=1, #src do
				dest.department = src[i]["value"]
			end
		end,
		-- 数据库错误
		db_error = {
			status = 1,
			message = "数据库错误",
		},
	},
	-- 设置产品
	set_product = {
		-- 成功
		success = {
			status = 0,
			message = "成功",
		},
		-- 参数错误
		params_error = {
			status = 1,
			message = "参数错误",
		},
		-- 数据库错误
		db_error = {
			status = 2,
			message = "数据库错误",
		},
	},
	-- 获取产品
	get_product = {
		-- 成功
		success = {	
			status = 0,
			message = "成功",
			data = {},
		},
		gen_success_data = function(dest, src)
			dest.product = {}
			for i=1, #src do
				dest.product = src[i]["value"]
			end
		end,
		-- 数据库错误
		db_error = {
			status = 1,
			message = "数据库错误",
		},
	},
	-- 上传公司简介图片
	upload_companyIntroducePicture = {
		-- 成功
		success = {
			status = 0,
			message = "成功",
			data = {},
		},
		-- 参数错误
		params_error = {
			status = 1,
			message = "参数错误",
		},
		-- 上传失败
		upload_fail = {
			status = 1,
			message = "上传失败",
		},
	},
	-- 创建管理员
	create_admin = {
		-- 成功
		success = {
			status = 0,
			message = "成功",
		},
		-- 参数错误
		params_error = {
			status = 1,
			message = "参数错误",
		},
		-- 数据库错误
		db_error = {
			status = 2,
			message = "数据库错误",
		},
		-- 用户已经存在
		user_exist = {
			status = 3,
			message = "用户已经存在",
		},	
	},
	-- 获取对应身份总人数
	get_identity_number = {
		-- 成功
		success = {
			status = 0,
			message = "成功",
			data = {},
		},
		-- 参数错误
		params_error = {
			status = 1,
			message = "参数错误",
		},
		-- 数据库错误
		db_error = {
			status = 2,
			message = "数据库错误",
		},
	},
	-- 编辑管理员
	edit_admin = {
		-- 成功
		success = {
			status = 0,
			message = "成功",
		},
		-- 参数错误
		params_error = {
			status = 1,
			message = "参数错误",
		},
		-- 数据库错误
		db_error = {
			status = 2,
			message = "数据库错误",
		},
	},
	-- 修改用户身份
	change_identity = {
		-- 成功
		success = {
			status = 0,
			message = "成功",
		},
		-- 参数错误
		params_error = {
			status = 1,
			message = "参数错误",
		},
		-- 数据库错误
		db_error = {
			status = 2,
			message = "数据库错误",
		},
	},
	-- 搜索用户
	search_user = {
		-- 成功
		success = {
			status = 0,
			message = "成功",
			data = {},
		},
		gen_success_data = function(dest, src)
			dest.userList = {}
			for i=1, #src do
				dest.userList[i] = {}
				dest.userList[i].id = src[i]["id"]
				dest.userList[i].account = src[i]["account"] 
				dest.userList[i].name = src[i]["name"]
				dest.userList[i].email = src[i]["email"]
				dest.userList[i].identity = utils.switch_identity(src[i]["identity"])
				dest.userList[i].department = src[i]["department"]
				dest.userList[i].sex = utils.switch_sex(src[i]["sex"])
				dest.userList[i].create_time = src[i]["create_time"]
				dest.userList[i].update_time = src[i]["update_time"]
				dest.userList[i].status = src[i]["status"]
			end
		end,
		params_error = {
			status = 1,
			message = "参数错误",
		},
		-- 数据库错误
		db_error = {
			status = 2,
			message = "数据库错误",
		},
	},
	-- 根据部门搜索用户
	search_userByDepartment = {
		-- 成功
		success = {
			status = 0,
			message = "成功",
			data = {},
		},
		gen_success_data = function(dest, src)
			dest.userList = {}
			for i=1, #src do
				dest.userList[i] = {}
				dest.userList[i].id = src[i]["id"]
				dest.userList[i].account = src[i]["account"] 
				dest.userList[i].name = src[i]["name"]
				dest.userList[i].email = src[i]["email"]
				dest.userList[i].identity = utils.switch_identity(src[i]["identity"])
				dest.userList[i].department = src[i]["department"]
				dest.userList[i].sex = utils.switch_sex(src[i]["sex"])
				dest.userList[i].create_time = src[i]["create_time"]
				dest.userList[i].update_time = src[i]["update_time"]
				dest.userList[i].status = src[i]["status"]
			end
		end,
		params_error = {
			status = 1,
			message = "参数错误",
		},
		-- 数据库错误
		db_error = {
			status = 2,
			message = "数据库错误",
		},
	},
	-- 解冻用户
	hot_user = {
		-- 成功
		success = {
			status = 0,
			message = "成功",
		},
		-- 参数错误
		params_error = {
			status = 1,
			message = "参数错误",
		},
		-- 数据库错误
		db_error = {
			status = 2,
			message = "数据库错误",
		},
	},
	-- 获取封禁用户
	get_ban_list = {
		-- 成功
		success = {
			status = 0,
			message = "成功",
			data = {},
		},
		-- 生成成功信息
		gen_success_data = function(dest, src)
			dest.userList = {}
			for i=1, #src do
				dest.userList[i] = {}
				dest.userList[i].id = src[i]["id"]
				dest.userList[i].account = src[i]["account"] 
				dest.userList[i].name = src[i]["name"]
				dest.userList[i].email = src[i]["email"]
				dest.userList[i].identity = utils.switch_identity(src[i]["identity"])
				dest.userList[i].department = src[i]["department"]
				dest.userList[i].sex = utils.switch_sex(src[i]["sex"])
				dest.userList[i].create_time = src[i]["create_time"]
				dest.userList[i].update_time = src[i]["update_time"]
				dest.userList[i].status = src[i]["status"]
			end
		end,
		-- 数据库错误
		db_error = {
			status = 1,
			message = "数据库错误",
		},
	},
	-- 删除用户
	delete_user = {
		-- 成功
		success = {
			status = 0,
			message = "成功",
		},
		-- 参数错误
		params_error = {
			status = 1,
			message = "参数错误",
		},
		-- 数据库错误
		db_error = {
			status = 2,
			message = "数据库错误",
		},
	},
	-- 批量获取用户
	batch_get_user = {
		-- 成功
		success = {
			status = 0,
			message = "成功",
			data = {},
		},
		-- 生成成功信息
		gen_success_data = function(dest, src)
			dest.userList = {}
			for i=1, #src do
				dest.userList[i] = {}
				dest.userList[i].id = src[i]["id"]
				dest.userList[i].account = src[i]["account"] 
				dest.userList[i].name = src[i]["name"]
				dest.userList[i].email = src[i]["email"]
				dest.userList[i].identity = utils.switch_identity(src[i]["identity"])
				dest.userList[i].department = src[i]["department"]
				dest.userList[i].sex = utils.switch_sex(src[i]["sex"])
				dest.userList[i].create_time = src[i]["create_time"]
				dest.userList[i].update_time = src[i]["update_time"]
				dest.userList[i].status = src[i]["status"]
			end
		end,
		-- 参数错误
		params_error = {
			status = 1,
			message = "参数错误",
		},
		-- 数据库错误
		db_error = {
			status = 2,
			message = "数据库错误",
		},
	},
	-- 获取类别和其对应总价
	get_categoryAndTotalPrice = {
		-- 成功
		success = {
			status = 0,
			message = "成功",
			data = {},
		},
		-- 生成成功信息
		gen_success_data = function(dest, src)
			dest.rstArr = {category={}, price={}}
			if not src or #src == 0 then
				return
			end
			for _, v in ipairs(src) do
				table_insert(dest.rstArr.category, v.category)
				table_insert(dest.rstArr.price, v.total_price)
			end
		end,
		-- 参数错误
		params_error = {
			status = 1,
			message = "参数错误",
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
	},
	-- 获取身份和其对应人数
	get_identifyAndNumber = {
		-- 成功
		success = {
			status = 0,
			message = "成功",
			data = {},
		},
		-- 生成成功信息
		gen_success_data = function(dest, src)
			dest.rstArr = {}
			if #src == 0 then
				return
			end
			for _, v in ipairs(src) do
				table_insert(dest.rstArr, {name = utils.switch_identity(v.identity), value = v.number})
			end
		end,
		-- 数据库错误
		db_error = {
			status = 1,
			message = "数据库错误",
		},
	},
	-- 获取每天登录人数
	get_dayAndNumber = {
		-- 成功
		success = {
			status = 0,
			message = "成功",
			data = {},
		},
		-- 生成成功信息
		gen_success_data = function(dest, src)
			dest.rstArr = {week={}, number={}}
			if not src or #src == 0 then
				return
			end
			for _, v in ipairs(src) do
				table_insert(dest.rstArr.week, v.login_date)
				table_insert(dest.rstArr.number, v.user_count)
			end
		end,
		-- 参数错误
		params_error = {
			status = 1,
			message = "参数错误",
		},
		-- 数据库错误
		db_error = {
			status = 2,
			message = "数据库错误",
		},
	},
	-- 发布消息
	publish_message = {
		-- 成功
		success = {
			status = 0,
			message = "成功",
		},
		-- 参数错误
		params_error = {
			status = 1,
			message = "参数错误",
		},
		-- 数据库错误
		db_error = {
			status = 2,
			message = "数据库错误",
		},
	},
	-- 分批获取消息
	batch_message_list = {
		-- 成功
		success = {
			status = 0,
			message = "成功",
			data = {},
		},
		-- 生成成功信息
		gen_success_data = parese_message,
		-- 参数错误
		params_error = {
			status = 1,
			message = "参数错误",
		},
		-- 数据库错误
		db_error = {
			status = 2,
			message = "数据库错误",
		},
	},
	-- 获取用户部门信息ids
	get_userDepartmentIds = {
		-- 成功
		success = {
			status = 0,
			message = "成功",
			data = {},
		},
		-- 生成成功信息
		gen_success_data = function(dest, src)
			dest.idArr = {}
			if not src or #src == 0 then
				return
			end
			for _, v in ipairs(src) do
				table_insert(dest.idArr, v.msg_id)
			end
		end,
		-- 参数错误
		params_error = {
			status = 1,
			message = "参数错误",
		},
		-- 数据库错误
		db_error = {
			status = 2,
			message = "数据库错误",
		},
	},
	-- 根据Ids获取部门消息
	get_departmentMsgByIds = {
		-- 成功
		success = {
			status = 0,
			message = "成功",
			data = {},
		},
		-- 生成成功信息
		gen_success_data = parese_message,
		-- 参数错误
		params_error = {
			status = 1,
			message = "参数错误",
		},
		-- 数据库错误
		db_error = {
			status = 2,
			message = "数据库错误",
		},
	},
	-- 获取不同消息等级与数量
	get_levelAndNumber = {
		-- 成功
		success = {
			status = 0,
			message = "成功",
			data = {},
		},
		-- 生成成功信息
		gen_success_data = function(dest, src)
			dest.rstArr = {}
			if not src or #src == 0 then
				return
			end
			for _, v in ipairs(src) do
				table_insert(dest.rstArr, {name = utils.switch_message_level(v.level), value = v.number})
			end
		end,
		db_error = {
			status = 1,
			message = "数据库错误",
		},
	},
	-- 封禁用户
	ban_user = {
		-- 成功
		success = {
			status = 0,
			message = "成功",
		},
		-- 参数错误
		params_error = {
			status = 1,
			message = "参数错误",
		},
		-- 数据库错误
		db_error = {
			status = 2,
			message = "数据库错误",
		},
	},
}

return return_codes