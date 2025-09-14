-- Comment: 定义相关

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
}