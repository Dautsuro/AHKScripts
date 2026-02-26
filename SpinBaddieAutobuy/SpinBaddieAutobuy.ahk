VERSION := "1.2.0"

SendMode "Event"

DETECTION_TARGETS := {
    stock: { name: "stock", x1: 797, y1: 385, x2: 1227, y2: 627, color: 0x59FF59 },
    buyButton: { name: "buyButton", x1: 784, y1: 385, x2: 943, y2: 766, color: 0x05D012 }
}

DELAY_AFTER_ACTION := 100
scrollDownCount := 0
scrollHardLimit := 110 ; Current observed limit (may change with each game update, adjust if needed).
scrollLimit := scrollHardLimit 
failedRetryCount := 0

closeShopPos := { x: 1358, y: 273 }
potionPos := { x: 541, y: 1016 }
drinkPotionPos := { x: 1295, y: 722 }
inventoryPos := { x: 1828, y: 33 }
placeBestPos := { x: 1049, y: 477 }
shopWindowPos := { x: 946, y: 562 }
firstDicePos := { x: 960, y: 508 }

F1::StartSearch
F12::ExitApp

StartSearch() {
    Loop {
        if ProcessSearch(DETECTION_TARGETS.stock)
            continue

        ProcessSearch(DETECTION_TARGETS.buyButton)
    }
}

ProcessSearch(target) {
    global scrollDownCount, failedRetryCount, scrollLimit
    retry := 0

    if (failedRetryCount >= 3) {
        refillCoins
        failedRetryCount := 0
        scrollDownCount := 0
        scrollLimit := scrollHardLimit
    }

    while not PixelSearch(&x, &y, target.x1, target.y1, target.x2, target.y2, target.color, 5) {
        if IsEndOfList() and target.name == "stock" {
            ScrollBackUp
            return true
        }

        Send "{WheelDown}"
        scrollDownCount++
        retry++
        Sleep DELAY_AFTER_ACTION
        RandomJump

        if retry >= 5 and target.name == "buyButton" {
            failedRetryCount++
            return
        }
    }

    Click x, y + 5
    Sleep DELAY_AFTER_ACTION

    if target.name == "buyButton" {
        Click x, y - 150
        Sleep DELAY_AFTER_ACTION

        if IsEndOfList()
            ScrollBackUp
    }
}

IsEndOfList() {
    if scrollDownCount >= scrollLimit
        return true

    area := DETECTION_TARGETS.stock
    isLastDice := ImageSearch(&x, &y, area.x1, area.y1, area.x2, area.y2, "*20 assets/last-dice.png")
    isLastPotion := ImageSearch(&x, &y, area.x1, area.y1, area.x2, area.y2, "*20 assets/last-potion.png")
    return isLastDice or isLastPotion
}

ScrollBackUp() {
    global scrollDownCount, scrollLimit
    scrollLimit := scrollDownCount

    Loop scrollDownCount {
        Send "{WheelUp}"
        Sleep DELAY_AFTER_ACTION / 10
    }

    scrollDownCount := 0
    Sleep DELAY_AFTER_ACTION * 10
}

RandomJump() {
    if Random(1, 100) <= 5
        Send "{Space}"
}

refillCoins() {
    Click closeShopPos.x, closeShopPos.y
    Sleep DELAY_AFTER_ACTION * 5

    Click potionPos.x, potionPos.y
    Sleep DELAY_AFTER_ACTION * 5

    Click drinkPotionPos.x, drinkPotionPos.y
    Sleep DELAY_AFTER_ACTION * 5

    Click potionPos.x, potionPos.y
    Sleep DELAY_AFTER_ACTION * 5

    Click inventoryPos.x, inventoryPos.y
    Sleep DELAY_AFTER_ACTION * 5

    Click placeBestPos.x, placeBestPos.y
    Sleep DELAY_AFTER_ACTION * 5

    Click inventoryPos.x, inventoryPos.y
    Sleep DELAY_AFTER_ACTION * 5

    Send "e"
    MouseMove shopWindowPos.x, shopWindowPos.y
    Sleep DELAY_AFTER_ACTION * 50


    Loop scrollHardLimit {
        Send "{WheelUp}"
    }

    Sleep DELAY_AFTER_ACTION * 10

    Loop 2 {
        Click firstDicePos.x, firstDicePos.y
        Sleep DELAY_AFTER_ACTION
    }
}
