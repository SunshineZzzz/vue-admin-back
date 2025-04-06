-- Comment: 定义相关

return {
	-- 其他一些配置
	misc = {
		-- jwt秘钥
		jwtSecretKey = "sunshinez",
		-- jwt过期时间
		jwtExp = 1 * 3600,
		-- 头像上传目录
		avatarDir = "avatar",
	},
	-- 用户身份
	user_identity = {
		-- 普通用户
		normal = 1,
	},
	-- 用户状态
	user_status = {
		-- 正常
		normal = 1,
		-- 冻结
		frozen = 2,
	}
}