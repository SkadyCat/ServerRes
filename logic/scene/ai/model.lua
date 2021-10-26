local json = require "json"
local module = {}

module.coins = 200
function module.isNotValentinesDay()
    print("不是情人节")
    return true
end

function module.gotoCourt()
    print("前往球场")
end

function module.playBall()
    print("打球")
end

function module.hasnotFlowerGF(coinss)
    
    print("女友没花"..coinss)
    return true
end
function module:hasnotFlowerSelf(coins)

    -- print(json.encode(coins))
    print("自己没花没点钱"..tostring(coins))
    return false
end
function module.goHome()
    print("go home")
end

function module.fetchMoney()
    print("fetch money")
end
local index = 0
function module.hasnotFlowerGF()
    print("女友没花...")
    index = index + 1
    return false
end


function module.gotoFlowerShop()

    print("前往花店")
end

function module.buyFlower()
    print("买花")
end

function module.gotoGF()
    print("找女朋友")
end

function module.isHereGF()
    print("女朋友还在")
    return false
end


function module.giveFlower()
    print("给女友花")
    return false
end


return module