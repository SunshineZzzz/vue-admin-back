drop table if exists `users`;
create table `users` (
  `id` bigint(20) unsigned not null auto_increment comment '自增id',
  `account` varchar(255) not null default '' comment '账号',
  `password` varchar(255) not null default '' comment '密码',
  `identity` int(10) not null default 0 comment '身份',
  `department` int(10) not null default 0 comment '部门',
  `name` varchar(255) not null default '' comment '昵称',
  `sex` tinyint unsigned not null default 0 comment '性别，1男性，2女性',
  `email` varchar(255) not null default '' comment '邮箱',
  `image_url` varchar(255) not null default '' comment '头像url',
  `create_time` bigint(20) not null default 0 comment '创建时间',
  `update_time` bigint(20) not null default 0 comment '更新时间',
  `status` int(10) unsigned not null default 0 comment '目前所处状态',
  primary key (`id`),
  unique key (`account`),
  key `identity` (`identity`),
  key `department` (`department`)
) engine=innodb default charset=utf8mb4;