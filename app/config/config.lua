-- Comment: 配置相关

-- 返回配置
return {
	-- 上传
	upload = {
		-- 上传路径
		dir = "./app/static/upload",
		-- 对外上传路径
		outDir = "/static/upload",
		-- 分块大小
		chunk_size = 4 * 1024,
		-- 上传超时，单位s
		recieve_timeout = 60 * 1000,
	},
	-- mysql配置
	mysql = {
		-- 地址
		host = "127.0.0.1",
		-- 端口
		port = 3306,
		-- 数据库
		database = "vue_admin_back",
		-- 用户名
		user = "root",
		-- 密码
		password = "123456",
		-- 空闲连接保活时间，单位s
		keepalive = 10,
		-- 空闲池子大小
		pool = 100,
		-- mysql操作超时超时
		timeout = 3000,
		-- 字符集
		charset = "utf8",
		-- 回复数据最大包大小
		max_packet_size = 1024 * 1024
	},
	-- 模板配置
	view = {
		-- 是否开启
		enable = true,
		-- 视图引擎字符串
		engine = "tmpl",
		-- 视图文件扩展名
		ext = "html",
		-- 视图布局文件名
		layout = "",
		-- 视图文件所在的目录
		views = "./app/views"
	},
}