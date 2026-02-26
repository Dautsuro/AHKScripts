VERSION := "1.1.0"

SendMode "Event"

DETECTION_TARGETS := {
    stock: { name: "stock", x1: 797, y1: 385, x2: 1227, y2: 627, color: 0x59FF59 },
    buyButton: { name: "buyButton", x1: 784, y1: 385, x2: 943, y2: 766, color: 0x05D012 }
}

DELAY_AFTER_ACTION := 100
scrollDownCount := 0
scrollLimit := 110 ; Current observed limit (may change with each game update, adjust if needed).

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
    global scrollDownCount
    retry := 0

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

        if retry >= 5 and target.name == "buyButton"
            return
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
