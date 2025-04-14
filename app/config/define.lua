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
}