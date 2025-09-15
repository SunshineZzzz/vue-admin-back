-- Comment: 定义相关

local define_router = {
	home = {
		name = "home",
		path = "home",
		meta = {title = "首页"},
		component = "home/index",
	},
	overview = {
		name = "overview",
		path = "overview",
		meta = {title = "系统概览"},
		component = "overview/index",
	},
	set = {
		name = "set",
		path = "set",
		meta = {title = "系统设置"},
		component = "menu_set/index",
	},
	users_manage = {
		name = "users_manage",
		path = "users_manage",
		meta = {title = "用户管理"},
		component = "user_manage/users_manage/index",
	},
	user_list = {
		name = "user_list",
		path = "user_list",
		meta = {title = "用户列表"},
		component = "user_manage/user_list/index",
	},
	message_manage = {
		name = "message_manage",
		path = "message_manage",
		meta = {title = "消息管理员"},
		component = "user_manage/message_manage/index",
	},
	product_manage = {
		name = "product_manage",
		path = "product_manage",
		meta = {title = "产品管理员"},
		component = "user_manage/product_manage/index",
	},
	product_manage_list = {
		name = "product_manage_list",
		path = "product_manage_list",
		meta = {title = "产品管理"},
		component = "product/product_manage_list/index",
	},
	out_product_manage_list = {
		name = "out_product_manage_list",
		path = "out_product_manage_list",
		meta = {title = "出库管理"},
		component = "product/out_product_manage_list/index",
	},
	message_list = {
		name = "message_list",
		path = "message_list",
		meta = {title = "消息管理"},
		component = "message/message_list/index",
	},
	recycle_message_list = {
		name = "recycle_message_list",
		path = "recycle_message_list",
		meta = {title = "回收站"},
		component = "message/recycle_list/index",
	},
	file = {
		name = "file",
		path = "file",
		meta = {title = "文件管理"},
		component = "file/index",
	},
	operation_log = {
		name = "operation_log",
		path = "operation_log",
		meta = {title = "日志管理"},
		component = "operation_log/index",
	},
}

local define_user_router = {
	-- 超级管理员菜单路由
	super_admin_menu = {
		name = "menu",
		path = "/menu",
		meta = {title = "菜单"},
		component = "menu/index",
		children = {
			define_router.home,
			define_router.overview,
			define_router.set,
			define_router.users_manage,
			define_router.user_list,
			define_router.message_manage,
			define_router.product_manage,
			define_router.product_manage_list,
			define_router.out_product_manage_list,
			define_router.message_list,
			define_router.recycle_message_list,
			define_router.file,
			define_router.operation_log,
		}
	},
	-- 用户管理员菜单路由
	user_admin_menu = {
		name = "menu",
		path = "/menu",
		meta = {title = "菜单"},
		component = "menu/index",
		children = {
			define_router.home,
			define_router.set,
			define_router.users_manage,
			define_router.user_list,
			define_router.message_manage,
			define_router.product_manage,
			define_router.file,
		}
	},
	-- 产品管理员菜单路由
	product_admin_menu = {
		name = "menu",
		path = "/menu",
		meta = {title = "菜单"},
		component = "menu/index",
		children = {
			define_router.home,
			define_router.set,
			define_router.product_manage_list,
			define_router.out_product_manage_list,
			define_router.file,
		},
	},
	-- 消息管理员菜单路由
	message_admin_menu = {
		name = "menu",
		path = "/menu",
		meta = {title = "菜单"},
		component = "menu/index",
		children = {
			define_router.home,
			define_router.set,
			define_router.message_list,
			define_router.recycle_message_list,
			define_router.file,
		},
	},
	-- 普通用户菜单路由
	normal_user_menu = {
		name = "menu",
		path = "/menu",
		meta = {title = "菜单"},
		component = "menu/index",
		children = {
			define_router.home,
			define_router.set,
			define_router.product_manage_list,
			define_router.out_product_manage_list,
			define_router.file,
		},
	},
}
return {
	-- 其他一些配置
	misc = {
		-- jwt秘钥
		jwtSecretKey = "sunshinez",
		-- jwt过期时间
		jwtExp = 1 * 3600,
		-- 临时jwt过期时间
		tempJwtExp = 5 * 60,
		-- 头像上传目录
		avatarDir = "avatar",
		-- 轮播图上传目录
		swiperDir = "swiper",
		-- 文件上传目录
		fileDir = "file",
		-- 公司名称上传目录
		companyNameDir = "companyName",
		-- 公司简介上传目录
		companyIntroduceDir = "companyIntroduce",
	},
	-- setting名称
	setting_name = {
		-- 转播图
		swiperPrefix = "swiper",
		-- 公司名称
		companyName = "conpanyName",
		-- 公司简介
		companyIntroducePrefix = "",
		-- 部门
		department = "department",
		-- 产品类别
		productType = "productType",
	},
	-- setting类型
	setting_type = {
		-- 转播图
		swiper = 1,
		-- 公司名称
		companyName = 2,
		-- 公司简介
		companyIntroduce = 3,
		-- 部门
		department = 4,
		-- 产品类别
		productType = 5
	},
	-- 用户身份
	user_identity = {
		-- 普通用户
		normal = 1,
		-- 用户管理员
		userMgr = 2,
		-- 产品管理员
		productMgr = 3,
		-- 消息管理员
		messageMgr = 4,
		-- 超级管理员
		root = 5,
	},
	-- 用户状态
	user_status = {
		-- 正常
		normal = 0,
		-- 冻结
		frozen = 1,
	},
	-- 消息状态
	message_status = {
		-- 正常
		normal = 0,
		-- 第一次删除
		first_delete = 1,
	},
	-- 消息等级
	message_level = {
		-- 一般
		normal = 0,
		-- 重要
		important = 1,
		-- 必要
		emergency = 2,
	},
	-- 商品状态
	product_status = {
		-- 正常
		normal = 0,
		-- 申请出库
		applying = 1,
		-- 同意出库
		agreeApply = 2,
		-- 拒绝出库
		rejectApply = 3,
	},
	-- 日志等级
	log_level = {
		-- 低级
		low = 0,
		-- 中级
		middle = 1,
		-- 高级
		high = 2,
	},
	-- 日志类型
	log_type = {
		-- 登录
		login = 0,
		-- 删除用户
		delete_user = 1,
		-- 产品审核
		product_audit = 2,
		-- 上传文件
		file_upload = 3,
		-- 删除文件
		file_delete = 4,
	},
	-- 路由
	router = {
		-- 超级管理员路由
		super_admin = define_user_router.super_admin_menu,
		-- 用户管理员路由
		user_admin = define_user_router.user_admin_menu,
		-- 产品管理员路由
		product_admin = define_user_router.product_admin_menu,
		-- 消息管理员路由
		message_admin = define_user_router.message_admin_menu,
		-- 普通用户路由
		normal_user = define_user_router.normal_user_menu,
	},
}