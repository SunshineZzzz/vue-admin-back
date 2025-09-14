-- Comment: 返回值定义

local ipairs = ipairs
local table_insert = table.insert
local tonumber = tonumber
local utils = require("app.utils.utils")
local http_not_found = ngx.HTTP_NOT_FOUND
local http_inner_error = ngx.HTTP_INTERNAL_SERVER_ERROR
local http_unauthorized = ngx.HTTP_UNAUTHORIZED
local define_product_status = require("app.config.define").product_status

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
			dest.sex = src.sex
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
			dest.sex = src.sex
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
			dest.department = "[]"
			if not src then
				return
			end
			dest.department = src["value"]
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
			dest.product = "[]"
			if not src then
				return
			end

			dest.product = src["value"]
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
				dest.userList[i].sex = src[i]["sex"]
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
				dest.userList[i].sex = src[i]["sex"]
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
				dest.userList[i].sex = src[i]["sex"]
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
				dest.userList[i].sex = src[i]["sex"]
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
	-- 编辑消息
	edit_message = {
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
	-- 根据发布部门进行搜索消息
	search_messageByDepartment = {
		-- 成功
		success = {
			status = 0,
			message = "成功",
			data = {},
		},
		-- 生成成功信息
		gen_success_data = function(dest, src)
			dest.messageList = {}

			if not src or #src == 0 then
				return
			end

			for _, v in ipairs(src) do
				table_insert(dest.messageList, {
					msg_id = v.msg_id,
					recept_department = v.recept_department,
					title = v.title,
					content = v.content,
					create_time = v.create_time,
					update_time = v.update_time,
					delete_time = v.delete_time,
					user_id = v.user_id,
					publish_department = v.publish_department,
					publish_name = v.publish_name,
					level = utils.switch_message_level(v.level),
					status = v.status,
					click_num = v.click_num,
				})
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
	search_messageByReceptDepartment = {
		-- 成功
		success = {
			status = 0,
			message = "成功",
			data = {},
		},
		-- 生成成功信息
		gen_success_data = function(dest, src)
			dest.messageList = {}

			if not src or #src == 0 then
				return
			end

			for _, v in ipairs(src) do
				table_insert(dest.messageList, {
					msg_id = v.msg_id,
					recept_department = v.recept_department,
					title = v.title,
					content = v.content,
					create_time = v.create_time,
					update_time = v.update_time,
					delete_time = v.delete_time,
					user_id = v.user_id,
					publish_department = v.publish_department,
					publish_name = v.publish_name,
					level = utils.switch_message_level(v.level),
					status = v.status,
					click_num = v.click_num,
				})
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
		}
	},
	-- 根据消息等级进行搜索
	search_messageByLevel = {
		-- 成功
		success = {
			status = 0,
			message = "成功",
			data = {},
		},
		-- 生成成功信息
		gen_success_data = function(dest, src)
			dest.messageList = {}

			if not src or #src == 0 then
				return
			end

			for _, v in ipairs(src) do
				table_insert(dest.messageList, {
					msg_id = v.msg_id,
					recept_department = v.recept_department,
					title = v.title,
					content = v.content,
					create_time = v.create_time,
					update_time = v.update_time,
					delete_time = v.delete_time,
					user_id = v.user_id,
					publish_department = v.publish_department,
					publish_name = v.publish_name,
					level = utils.switch_message_level(v.level),
					status = v.status,
					click_num = v.click_num,
				})
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
		}
	},
	-- 删除消息
	first_deleteMessage = {
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
		-- 删除失败
		first_delete_error = {
			status = 3,
			message = "删除失败",
		}
	},
	-- 恢复消息
	message_recover = {
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
		-- 恢复失败
		recover_error = {
			status = 3,
			message = "恢复失败",
		}
	},
	-- 消息删除
	message_delete = {
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
		-- 删除失败
		delete_error = {
			status = 3,
			message = "删除失败",
		}
	},
	-- 更新消息点击率
	update_messageClick = {
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
	-- 获取回收站消息长度
	get_recycleListLength = {
		-- 成功
		success = {
			status = 0,
			message = "成功",
			data = {},
		},
		-- 生成成功信息
		gen_success_data = function(dest, src)
			dest.count = 0
			if not src then
				return
			end
			dest.count = tonumber(src["c"])
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
	-- 分批获取回收站消息
	batch_recycleMessageList = {
		-- 成功
		success = {
			status = 0,
			message = "成功",
			data = {},
		},
		-- 生成成功信息
		gen_success_data = function(dest, src)
			dest.messageList = {}

			if not src or #src == 0 then
				return
			end

			for _, v in ipairs(src) do
				table_insert(dest.messageList, {
					msg_id = v.msg_id,
					recept_department = v.recept_department,
					title = v.title,
					content = v.content,
					create_time = v.create_time,
					update_time = v.update_time,
					delete_time = v.delete_time,
					user_id = v.user_id,
					publish_department = v.publish_department,
					publish_name = v.publish_name,
					level = utils.switch_message_level(v.level),
					status = v.status,
					click_num = v.click_num,
				})
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
		}
	},
	-- 获取消息列表长度
	get_messageListLength = {
		-- 成功
		success = {
			status = 0,
			message = "成功",
			data = {},
		},
		-- 生成成功信息
		gen_success_data = function(dest, src)
			dest.count = 0
			if not src then
				return
			end
			dest.count = tonumber(src["c"])
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
	-- 分批获取消息
	batch_message_list = {
		-- 成功
		success = {
			status = 0,
			message = "成功",
			data = {},
		},
		-- 生成成功信息
		gen_success_data = function(dest, src)
			dest.messageList = {}

			if not src or #src == 0 then
				return
			end

			for _, v in ipairs(src) do
				table_insert(dest.messageList, {
					msg_id = v.msg_id,
					recept_department = v.recept_department,
					title = v.title,
					content = v.content,
					create_time = v.create_time,
					update_time = v.update_time,
					delete_time = v.delete_time,
					user_id = v.user_id,
					publish_department = v.publish_department,
					publish_name = v.publish_name,
					level = utils.switch_message_level(v.level) ,
					status = v.status,
					click_num = v.click_num,
				})
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
	-- 根据接收部门获取消息列表长度
	get_messageListByReceptDepartmentLength = {
		-- 成功
		success = {
			status = 0,
			message = "成功",
			data = {},
		},
		-- 生成成功信息
		gen_success_data = function(dest, src)
			dest.count = 0
			if not src then
				return
			end
			dest.count = tonumber(src["c"])
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
	-- 根据接收部门分批获取消息列表
	batch_messageListByReceptDepartment = {
		-- 成功
		success = {
			status = 0,
			message = "成功",
			data = {},
		},
		-- 生成成功信息
		gen_success_data = function(dest, src)
			dest.messageList = {}

			if not src or #src == 0 then
				return
			end

			for _, v in ipairs(src) do
				table_insert(dest.messageList, {
					msg_id = v.msg_id,
					recept_department = v.recept_department,
					title = v.title,
					content = v.content,
					create_time = v.create_time,
					update_time = v.update_time,
					delete_time = v.delete_time,
					user_id = v.user_id,
					publish_department = v.publish_department,
					publish_name = v.publish_name,
					level = utils.switch_message_level(v.level),
					status = v.status,
					click_num = v.click_num,
				})
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
		}
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
				table_insert(dest.idArr, v.id)
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
		gen_success_data = function(dest, src)
			dest.messageList = {}

			if not src or #src == 0 then
				return
			end

			for _, v in ipairs(src) do
				table_insert(dest.messageList, {
					msg_id = v.msg_id,
					recept_department = v.recept_department,
					title = v.title,
					content = v.content,
					create_time = v.create_time,
					update_time = v.update_time,
					delete_time = v.delete_time,
					user_id = v.user_id,
					publish_department = v.publish_department,
					publish_name = v.publish_name,
					level = utils.switch_message_level(v.level),
					status = v.status,
					click_num = v.click_num,
				})
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
	-- 产品入库
	create_product = {
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
		-- 入库失败
		create_error = {
			status = 3,
			message = "入库失败",
		},
	},
	-- 删除产品
	delete_product = {
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
		-- 删除失败
		delete_error = {
			status = 3,
			message = "删除失败",
		},
	},
	-- 编辑产品信息
	edit_product = {
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
		-- 编辑失败
		edit_error = {
			status = 3,
			message = "编辑失败",
		},
	},
	-- 申请产品出库
	apply_out_product = {
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
		-- 申请失败
		apply_error = {
			status = 3,
			message = "申请失败",
		},
	},
	-- 对产品进行撤回申请
	withdraw_apply_product = {
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
		-- 撤回失败
		withdraw_error = {
			status = 3,
			message = "撤回失败",
		},
	},
	-- 审核产品
	audit_product = {
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
		-- 审核失败
		audit_error = {
			status = 3,
			message = "审核失败",
		},
	},
	-- 通过入库编号对产品进行搜索
	get_productListForId = {
		-- 成功
		success = {
			status = 0,
			message = "成功",
			data = {},
		},
		-- 生成成功信息
		gen_success_data_out = function(dest, src)
			dest.productList = {}

			if not src then
				return
			end

			for _, v in pairs(src) do
				table_insert(dest.productList, {
					id = v.number,
					category = v.category,
					name = v.name,
					unit = v.unit,
					quantity = tonumber(v.quantity),
					out_quantity = tonumber(v.out_quantity),
					price = tonumber(v.price),
					remark = v.remark,
					create_time = tonumber(v.create_time),
					update_time = 0,
					apply_out_time = tonumber(v.apply_out_time),
					out_time = tonumber(v.out_time),
					status = utils.switch_product_status(define_product_status.normal),
					user_name = v.user_name,
					update_user_name = '',
					out_user_name = v.out_user_name
				})
			end
		end,
		gen_success_data = function(dest, src)
			dest.productList = {}

			if not src then
				return
			end

			table_insert(dest.productList, {
				id = src.number,
				category = src.category,
				name = src.name,
				unit = src.unit,
				quantity = tonumber(src.quantity),
				out_quantity = tonumber(src.out_quantity),
				price = tonumber(src.price),
				remark = src.remark,
				create_time = tonumber(src.create_time),
				update_time = tonumber(src.update_time),
				apply_out_time = tonumber(src.apply_out_time),
				out_time = tonumber(src.out_time),
				status = utils.switch_product_status(src.status),
				user_name = src.user_name,
				update_user_name = src.update_user_name,
				out_user_name = src.out_user_name
			})
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
	-- 获取产品总数
	get_productLength =  {
		-- 成功
		success = {
			status = 0,
			message = "成功",
			data = {},
		},
		-- 生成成功信息
		gen_success_data = function(dest, src)
			dest.count = 0
			if not src then
				return
			end
			dest.count = tonumber(src["c"])
		end,
		-- 数据库错误
		db_error = {
			status = 1,
			message = "数据库错误",
		},
	},
	-- 获取申请出库产品总数
	get_applyOutProductLength = {
		-- 成功
		success = {
			status = 0,
			message = "成功",
			data = {},
		},
		-- 生成成功信息
		gen_success_data = function(dest, src)
			dest.count = 0
			if not src then
				return
			end
			dest.count = tonumber(src["c"])
		end,
		-- 数据库错误
		db_error = {
			status = 1,
			message = "数据库错误",
		},
	},
	-- 获取出库产品总数
	get_outProductLength = {
		-- 成功
		success = {
			status = 0,
			message = "成功",
			data = {},
		},
		-- 生成成功信息
		gen_success_data = function(dest, src)
			dest.count = 0
			if not src then
				return
			end
			dest.count = tonumber(src["c"])
		end,
		-- 数据库错误
		db_error = {
			status = 1,
			message = "数据库错误",
		},
	},
	-- 批量获取产品
	batch_getProductList = {
		-- 成功
		success = {
			status = 0,
			message = "成功",
			data = {},
		},
		-- 生成成功信息
		gen_success_data = function(dest, src)
			dest.productList = {}

			if not src or #src == 0 then
				return
			end

			for _, v in ipairs(src) do
				table_insert(dest.productList, {
					id = v.number,
					category = v.category,
					name = v.name,
					unit = v.unit,
					quantity = tonumber(v.quantity),
					out_quantity = tonumber(v.out_quantity),
					price = tonumber(v.price),
					remark = v.remark,
					create_time = tonumber(v.create_time),
					update_time = tonumber(v.update_time),
					apply_out_time = tonumber(v.apply_out_time),
					out_time = tonumber(v.out_time),
					status = utils.switch_product_status(v.status),
					user_name = v.user_name,
					update_user_name = v.update_user_name,
					out_user_name = v.out_user_name
				})
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
	-- 批量获取申请出库产品
	batch_get_applyProductList = {
		-- 成功
		success = {
			status = 0,
			message = "成功",
			data = {},
		},
		-- 生成成功信息
		gen_success_data = function(dest, src)
			dest.productList = {}

			if not src or #src == 0 then
				return
			end

			for _, v in ipairs(src) do
				table_insert(dest.productList, {
					id = v.number,
					category = v.category,
					name = v.name,
					unit = v.unit,
					quantity = tonumber(v.quantity),
					out_quantity = tonumber(v.out_quantity),
					price = tonumber(v.price),
					remark = v.remark,
					create_time = tonumber(v.create_time),
					update_time = tonumber(v.update_time),
					apply_out_time = tonumber(v.apply_out_time),
					out_time = tonumber(v.out_time),
					status = utils.switch_product_status(v.status),
					user_name = v.user_name,
					update_user_name = v.update_user_name,
					out_user_name = v.out_user_name
				})
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
	-- 批量获取出库产品
	batch_get_outProductList = {
		-- 成功
		success = {
			status = 0,
			message = "成功",
			data = {},
		},
		-- 生成成功信息
		gen_success_data = function(dest, src)
			dest.productList = {}

			if not src or #src == 0 then
				return
			end

			for _, v in ipairs(src) do
				table_insert(dest.productList, {
					id = v.number,
					category = v.category,
					name = v.name,
					unit = v.unit,
					quantity = tonumber(v.quantity),
					out_quantity = tonumber(v.out_quantity),
					price = tonumber(v.price),
					remark = v.remark,
					create_time = tonumber(v.create_time),
					update_time = 0,
					apply_out_time = tonumber(v.apply_out_time),
					out_time = tonumber(v.out_time),
					status = utils.switch_product_status(define_product_status.normal),
					user_name = v.user_name,
					update_user_name = '',
					out_user_name = v.out_user_name
				})
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
	-- 上传文件
	upload_file = {
		-- 上传成功
		success = {
			status = 0,
			message = "上传成功",
			data = {},
		},
		-- 上传失败
		upload_fail = {
			status = 1,
			message = "上传失败",
			data = {},
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
	-- 更新下载次数
	update_downloadNum = {
		-- 下载成功
		success = {
			status = 0,
			message = "下载成功",
			data = {},
		},
		-- 数据库错误
		db_error = {
			status = 1,
			message = "数据库错误",
		},
		-- 参数错误
		params_error = {
			status = 2,
			message = "参数错误",
		},
	},
	-- 获取文件列表
	file_listLength = {
		-- 成功
		success = {
			status = 0,
			message = "成功",
			data = {},
		},
		-- 生成成功信息
		gen_success_data = function(dest, src)
			dest.count = 0
			if not src then
				return
			end

			dest.count = tonumber(src["c"])
		end,
		-- 数据库错误
		db_error = {
			status = 1,
			message = "数据库错误",
		},
	},
	-- 分批获取文件列表 
	file_getFileList = {
		-- 成功
		success = {
			status = 0,
			message = "成功",
			data = {},
		},
		-- 生成成功信息
		gen_success_data = function(dest, src)
			dest.fileList = {}

			if not src or #src == 0 then
				return
			end

			for _, v in ipairs(src) do
				table_insert(dest.fileList, {
					file_id = tonumber(v.id),
					user_id = tonumber(v.user_id),
					user_name = v.user_name,
					name = v.name,
					url = v.url,
					size = tonumber(v.size),
					type = v.type,
					download_number = tonumber(v.download_number),
					create_time = tonumber(v.create_time),
				})
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
	-- 根据名称搜索文件
	search_fileByName = {
		-- 成功
		success = {
			status = 0,
			message = "成功",
			data = {},
		},
		-- 生成成功信息
		gen_success_data = function(dest, src)
			dest.fileList = {}

			if not src or #src == 0 then
				return
			end

			for _, v in ipairs(src) do
				table_insert(dest.fileList, {
					file_id = tonumber(v.id),
					user_id = tonumber(v.user_id),
					user_name = v.user_name,
					name = v.name,
					url = v.url,
					size = tonumber(v.size),
					type = v.type,
					download_number = tonumber(v.download_number),
					create_time = tonumber(v.create_time),
				})
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
	-- 删除文件
	delete_file = {
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
	}
}

return return_codes