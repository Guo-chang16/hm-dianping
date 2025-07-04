
--获取id
local voucherId = ARGV[1]
local userId = ARGV[2]

--orderId
local orderId = ARGV[3]

--获取key
local stockKey = "seckill:stock:" .. voucherId
local orderKey = "seckill:order:" .. voucherId

--获取库存,判断
local stock = tonumber(redis.call('get', stockKey))
if not stock or stock <= 0 then
    return 1 -- 库存不足
end
--判断用户是否重复下单
if(redis.call('sismember',orderKey,userId) == 1) then
    --已经下过单
    return 2
end
-- 扣减库存
redis.call('incrby',stockKey,-1)
-- 保存用户id到Redis中
redis.call('sadd',orderKey,userId)

-- 发送消息
redis.call('xadd','stream.orders','*','userId',userId,'voucherId',voucherId,'id',orderId)
-- 返回
return 0