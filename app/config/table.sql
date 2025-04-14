-- 用户
drop table if exists `users`;
create table `users` (
  `id` bigint(20) unsigned not null auto_increment comment '自增id',
  `account` varchar(255) not null default '' comment '账号',
  `password` varchar(255) not null default '' comment '密码',
  `identity` int(10) not null default 0 comment '身份',
  `department` varchar(255) not null default '' comment '部门',
  `name` varchar(255) not null default '' comment '昵称',
  `sex` tinyint unsigned not null default 0 comment '性别，1男性，2女性',
  `email` varchar(255) not null default '' comment '邮箱',
  `image_url` varchar(255) not null default '' comment '头像url',
  `create_time` bigint(20) not null default 0 comment '创建时间',
  `update_time` bigint(20) not null default 0 comment '更新时间',
  `login_time` bigint(20) not null default 0 comment '登录时间',
  `status` int(10) unsigned not null default 0 comment '目前所处状态',
  primary key (`id`),
  unique key (`account`),
  key `identity` (`identity`)
) engine=innodb default charset=utf8mb4;

-- 设置
drop table if exists `setting`;
create table `setting` (
  `id` bigint(20) unsigned not null auto_increment comment '自增id',
  `user_id` bigint(20) not null default 0 comment '用户id',
  `category` tinyint unsigned not null default 0 comment '设置项类别',
  `key` varchar(255) not null default '' comment '设置项key',
  `value` text not null default '' comment '设置项value',
  `update_time` bigint(20) not null default 0 comment '更新时间',
  primary key (`id`),
  unique key (`key`),
  key `category` (`category`),
  key `user_id` (`user_id`)
) engine=innodb default charset=utf8mb4;

-- 产品
drop table if exists `product`;
create table `product` (
  `id` bigint(20) unsigned not null auto_increment comment '自增id',
  `number` varchar(255) not null default '' comment '编号',
  `category` tinyint unsigned not null default 0 comment '类别',
  `name` varchar(255) not null default '' comment '名称',
  `unit` varchar(255) not null default '' comment '单位',
  `quantity` int(10) unsigned not null default 0 comment '数量',
  `price` int(10) unsigned not null default 0 comment '价格',
  `user_id` bigint(20) not null default 0 comment '负责人id',
  `create_time` bigint(20) not null default 0 comment '创建时间',
  `update_time` bigint(20) not null default 0 comment '更新时间',
  `remark` text not null default '' comment '备注',
  primary key (`id`),
  unique key (`number`),
  key `category` (`category`),
  key `user_id` (`user_id`)
) engine=innodb default charset=utf8mb4;

-- 消息
drop table if exists `message`;
create table `message` (
  `id` bigint(20) unsigned not null auto_increment comment '自增id',
  `msg_id` bigint(20) not null default 0 comment '消息id',
  `category` varchar(255) not null default '' comment '消息类别',
  `title` varchar(255) not null default '' comment '标题',
  `content` text not null default '' comment '内容',
  `create_time` bigint(20) not null default 0 comment '创建时间',
  `update_time` bigint(20) not null default 0 comment '更新时间',
  `delete_time` bigint(20) not null default 0 comment '删除时间',
  `department` varchar(255) not null default '' comment '发布部门',
  `name` varchar(255) not null default '' comment '发布人',
  `level` tinyint unsigned not null default 0 comment '消息等级',
  `status` tinyint unsigned not null default 0 comment '消息状态',
  `click_num` int(10) unsigned not null default 0 comment '点击次数',
  primary key (`id`),
  key `category` (`category`),
  key `msg_id` (`msg_id`)
) engine=innodb default charset=utf8mb4;

-- 生成消息Id
drop table if exists `gen_message_id`;
create table `gen_message_id` (
  `department` varchar(255) not null default '' comment '部门',
  `msg_id` bigint(20) not null default 0 comment '消息id',
  primary key (`department`),
  unique key (`msg_id`)
) engine=innodb default charset=utf8mb4;

-- 用户消息Id
drop table if exists `user_message_id`;
create table `user_message_id` (
  `user_id` bigint(20) not null default 0 comment '用户id',
  `department` varchar(255) not null default '' comment '部门',
  `read_msg_id` bigint(20) not null default 0 comment '已读消息id',
  primary key (`user_id`, `read_msg_id`)
) engine=innodb default charset=utf8mb4;