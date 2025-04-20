-- $Name: Маленький человек-паук$
-- $Version: 0.4$

require "dash"
require "quotes"

instead_version "1.3.0"

-- utils

function contains(list, item)
    for i, v in ipairs(list) do
        if v == item then
            return true
        end
    end
    return false
end

function gobj(nam, dsc)
    return obj {
        nam = nam,
        dsc = dsc,
        act = function (s, w)
            walk(nam)
        end
    }
end

function gobj1(nam, dsc)
    return obj {
        nam = nam,
        dsc = dsc,
        act = function (s, w)
            remove(nam)
            walk(nam)
        end
    }
end

-- game

function init()
    set_music('mus/theme.ogg')
end

function say_money(m)
    if m == 0 then
        return 'Нет монет'
    elseif contains({ 1, 21 }, m) then
        return tostring(m) .. ' монета'
    elseif contains({ 2, 3, 4, 22, 23, 24}, m) then
        return tostring(m) .. ' монеты'
    else
        return tostring(m) .. ' монет'
    end
end

function mobj(sum, dsc)
    return obj {
        nam = 'coin',
        _sum = sum,
        dsc = function (s, w)
            if s._sum > 0 then
                return dsc .. ' лежит {' .. say_money(sum) .. '}.'
            else
                return dsc .. ' ничего нет.'
            end
        end,
        act = function (s, w)
            me()._money = me()._money + sum
            s._sum = 0
            set_sound('snd/coin.ogg')
            return 'Ты взял деньги...'
        end
    }
end

money = obj {
    nam = function(s)
        local m = me()._money
        return say_money(m)
    end,
    inv = function (s, w)
        local m = me()._money
        if m == 0 then
            return 'У тебя нет ни одной монеты...'
        else
            return 'У тебя '..say_money(m)..'.'
        end
    end,
    use = function (s, w)
        return "Бесполезно! Это не продаётся."
    end
}

function sobj(snd, obj)
    local oldact = obj.act

    obj.act = function (s, w)
        set_sound('snd/'..snd..'.ogg')
        oldact(s, w)
    end

    return obj
end

function jump_obj(obj)
    return sobj('jump', obj)
end

function fall_obj(obj)
    return sobj('fall', obj)
end

backlink = obj {
    nam = 'backlink',
    dsc = '{Вернуться}',
    act = function (s, w)
        goback()
    end
}

main = room {
    nam = 'Маленький Человек-Паук',
    dsc = '',
    pic = 'gfx/splash.png',
    obj = {
        gobj('start', '^{Играть}'),
        gobj('authors', '^{Авторы}')
    }
}

authors = room {
    nam = 'Авторы',
    dsc = [[Эту игрушку Стёпа придумал специально для INSTEAD.
    ^^Идея: Стёпа
    ^Сценарий: Стёпа
    ^Программист: Папа
    ^Тестировали: Мама, дядя Серёжа
    ^Рядом бегал: Рома
    ^^Ноябрь 2010]],
    obj = { 'backlink' }
}

start = room {
    nam = 'Начало',
    dsc = [[Тебя зовут Питер Паркер. Ты -- человек-паук.
    Злой колдун уменьшил тебя. И теперь ты не можешь в полную силу сражаться со своими врагами.
    ^^Ты находишься в неизвестной комнате.]],
    obj = { gobj('sofa', '{Осмотреться}') },
    enter = function (s, f)
        if f == main then
            me()._money = 0
            inv():add('money')
        end
    end
}

sofa = room {
    nam = 'Диван',
    dsc = 'Ты стоишь на краю дивана.',
    obj = {
        gobj('pillow', 'В углу на диване лежит {подушка}.'),
        fall_obj(gobj('nearsofa', 'Если подойти к самому краю, то можно спрыгнуть на {пол} с дивана.'))
    }
}

pillow = room {
    nam = 'Подушка',
    dsc = 'Ты стоишь возле подушки.',
    obj = {
        gobj('underpillow', 'Можно заглянуть {под подушку}.'),
        gobj('sofa', 'Можно вернуться к {краю дивана}.')
    }
}

underpillow = room {
    nam = 'Под подушкой',
    dsc = 'Ты поднимаешь подушку. Интересно, что там под ней?',
    obj = {
        mobj(2, 'Под подушкой'),
        gobj('pillow', '{Положим} подушку на место.')
    }
}

nearsofa = room {
    nam = 'Возле дивана',
    dsc = 'Ты стоишь на полу в большой комнате.',
    obj = {
        gobj('paper', 'Под твоими ногами лежат {бумажки}.'),
        jump_obj(gobj('sofa', 'Рядом с тобой {диван}, ты легко можешь запрыгнуть на него.')),
        gobj('undersofa', 'Если посмотреть {под диван}, то ничего не видно -- темно.'),
        gobj('neartable1', 'Недалеко стоит {стол}.')
    };
}

undersofa = room {
    nam = 'Под диваном',
    dsc = 'Вокруг много пыли. Ты весь испачкался.',
    obj = {
        mobj(1, 'Под диваном'),
        gobj('nearsofa', 'Может быть вылезти отсюда на {чистое место}?')
    }
}

paper = room {
    nam = 'Под бумажками',
    dsc = 'Ты поднимаешь с пола бумажки.',
    obj = {
        mobj(2, 'Под бумажками'),
        gobj('nearsofa', 'Ненужные бумажки можно {выбросить}.')
    }
}

neartable1 = room {
    nam = 'Возле стола',
    dsc = 'Ты стоишь рядом с огромным столом.',
    obj = {
        jump_obj(gobj('table1', '"Может быть мне забраться на этот {стол}?", -- думаешь ты, --')),
        gobj('nearsofa', '"Или вернуться обратно к {дивану}?".')
    }
}

table1 = room {
    nam = 'На столе',
    dsc = 'Ты забрался на стол с ногами.',
    obj = {
        gobj('curtain', 'Стол стоит рядом с окном с {занавеской}, по которой легко забираться.'),
        gobj('cup', 'Перед тобой стоит {чашка}.'),
        gobj('book', 'Слева от тебя лежит {книжка}.'),
        fall_obj(gobj('neartable1', 'Ты можешь спрыгнуть со стола на {пол}.'))
    }
}

cup = room {
    nam = 'Чашка',
    dsc = 'Ты приподнимаешь чашку.',
    obj = {
        mobj(2, 'На столе под чашкой'),
        gobj('table1', 'Думаю, надо {поставить} чашку на место.')
    }
}

book = room {
    nam = 'Книжка',
    dsc = 'Ты приподнимаешь книжку.',
    obj = {
        mobj(3, 'На столе под книжкой'),
        gobj('table1', 'Думаю, надо {положить} книжку на место.')
    }
}

curtain = room {
    nam = 'Карниз',
    dsc = 'По занавеске ты забрался на карниз.',
    obj = {
        mobj(6, 'На карнизе'),
        gobj('door1', '^^Ты заметил, что если пройти по {карнизу} и слезть по занавеске, то окажешься у двери.'),
        fall_obj(gobj('table1', 'Впрочем, может спрыгнуть на {стол}?'))
    }
}

door1 = room {
    nam = 'Дверь',
    dsc = 'Ты стоишь в спальне возле двери, которая ведёт в другую комнату.',
    obj = {
        gobj('curtain', 'Рядом с дверью окно с {занавеской}, по которой можно легко забраться на карниз.'),
        gobj('kidroom', 'Дверь слегка приоткрыта и ты можешь пройти в {соседнюю комнату}.')
    }
}

ball = obj {
    nam = 'Мячик',
    dsc = 'Рядом с тобой лежит {мячик}.',
    act = function (s, w)
        objs():del(s)
        set_sound('snd/ball.ogg')
        return 'Ты пинаешь мячик и он откатывается...'
    end
}

cubes = obj {
    nam = 'Кубики',
    dsc = 'Невдалеке разбросаны {кубики}.',
    tak = function (s)
        if here() == neartable2 then
            objs():del('cubes')
            objs():add('stair')
            return 'Из кубиков ты строишь лесенку...', false
        end
        return 'Ты собираешь кубики.'
    end,
    inv = 'Кубиков много. Их неудобно нести в руках.',
    use = function (s, w)
        if w == truck and have('truck') and have('cubes') then
            inv():del('truck')
            inv():del('cubes')
            inv():add('truck_with_cubes')

            return 'Ты складываешь кубики в самосвал.'
        else
            return 'Не понимаю...'
        end
    end
}

truck = obj {
    nam = 'Самосвал',
    dsc = 'Чуть дальше стоит {самосвал}.',
    tak = 'Ты берёшь самосвал с собой.',
    inv = function (s, w)
        if here() == neartable3 then
            inv():del('truck')
            return 'Ты кладёшь самосвал на пол.'
        end
        return 'У самосвала большой пустой кузов.'
    end,
    use = 'Не понимаю...'
}

truck_with_cubes = obj {
    nam = 'Полный самосвал',
    inv = function (s)
        if here() == neartable2 then
            inv():del('truck_with_cubes')
            inv():add('truck')
            objs():add('cubes')
            set_sound('snd/cubes.ogg')
            return 'Кубики весело вываливаются из самосвала.'
        else
            return 'Некуда вывалить кубики...'
        end
    end
}

stair = gobj('table2', '^^Рядом со столом стоит {лесенка} из кубиков, по которой можно подняться наверх.')

kidroom = room {
    nam = 'Детская',
    dsc = 'Ты стоишь в детской комнате. На полу валяются разные игрушки.',
    obj = {
        ball, cubes, truck,
        gobj('door1', 'Сзади тебя {дверь}, через которую можно пройти в спальню.'),
        gobj('neartable2', 'Перед тобой {стол}. "Может подойти к нему?", -- думаешь ты.')
    },
    exit = function (s, t)
        if have('cubes') then
            return 'Нести кубики в руках очень неудобно...', false
        end
    end
}

neartable2 = room {
    nam = 'Перед столом в детской',
    dsc = 'Перед тобой очень высокий стол.',
    obj = {
        obj {
            nam = 'jump',
            dsc = '"Получится ли запрыгнуть на этот высокий {стол}?", -- думаешь ты.',
            act = function (s, w)
                local result = 'Нет, это вряд ли получится -- стол очень высокий.'

                if not seen('stair') then
                    result = result .. '^Вот если бы тут была лесенка... Но из чего её построить?'
                end

                return result
            end
        },
        gobj('kidroom', 'Или стоит вернуться к {двери в спальню}?'),
        gobj('kitchen', 'А вот впереди -- {дверь на кухню}. Пойти туда?')
    }
}

chestbox = obj {
    nam = 'chestbox',
    dsc = 'А вот подальше стоит очень интересная {шкатулка}...',
    act = 'К сожалению, просто так шкатулку не откроешь...',
    use = 'Хм...'
}

key = obj {
    nam = 'Ключ',
    dsc = 'Очень важный ключ.',
    inv = 'Интересно, что он открывает?..',
    use = function (s, t)
        if t == chestbox then
            inv():zap()
            walk('finish')
        end
    end
}

table2 = room {
    nam = 'Стол в детской',
    dsc = 'Итак, ты на столе в детской комнате. Осмотримся...',
    obj = {
        mobj(2, 'Прямо перед тобой'),
        chestbox,
        fall_obj(gobj('neartable2', '^^Впрочем, всегда можно спрыгнуть на {пол} с этого высокого стола.'))
    }
}

kitchen = room {
    nam = 'Кухня',
    dsc = 'Ты стоишь в кухне.',
    obj = {
        gobj('neartable2', 'Сзади тебя {дверь}, которая ведёт в детскую.'),
        gobj('neartable3', 'Перед тобой -- {стол}.'),
        gobj('nearstove', 'Чуть дальше {плита}, на которой что-то готовится.'),
        gobj('box1', '^^Справа -- тумбочка с тремя ящиками. Открыть {первый} ящик?'),
        gobj('box2', 'Или {второй}?'),
        gobj('box3', 'А может сразу {третий}?')
    }
}

box1 = room {
    nam = 'Первый ящик',
    dsc = 'Ты открыл первый ящик тумбочки.',
    obj = {
        mobj(1, 'В ящике'),
        gobj('kitchen', 'Ящик открыт - значит его можно {закрыть}!')
    }
}

box2 = room {
    nam = 'Второй ящик',
    dsc = 'Ты открыл второй ящик тумбочки.',
    obj = {
        mobj(1, 'В ящике'),
        gobj('kitchen', 'Ящик открыт - значит его можно {закрыть}!')
    }
}

box3 = room {
    nam = 'Третий ящик',
    dsc = 'Ты открыл третий ящик тумбочки.',
    obj = {
        mobj(1, 'В ящике'),
        gobj('kitchen', 'Ящик открыт - значит его можно {закрыть}!')
    }
}

neartable3 = room {
    nam = 'Перед столом на кухне',
    dsc = 'Ты стоишь перед широким кухонным столом.',
    obj = {
        gobj('kitchen', '{Дверь} в детскую позади тебя.'),
        gobj('nearstove', 'В углу стоит {плита}. Пахнет чем-то вкусным.'),
        jump_obj(gobj('table3', 'Рядом кухонный {стол}. "Смогу ли я не него запрыгнуть?", -- думаешь ты.'))
    }
}

table3 = room {
    nam = 'Кухонный стол',
    dsc = 'И вот ты забрался на стол... На нём лежат разные предметы.',
    enter = function (s, f)
        if have('truck') or have('truck_with_cubes') then
            return 'Эх! Тяжёлый самосвал мешает...', false
        end
    end,
    obj = {
        gobj1('fish', 'На тарелке лежит жареная {рыба}. Она очень приятно пахнет.');
        gobj1('tea', 'В красную чашку налит вкусный {чай}.');
        gobj1('coffee', 'Из синей чашки доносится аромат аппетитного {кофе}.');
        fall_obj(gobj('neartable3', '"Может быть пора спрыгнуть со стола на {пол}?", -- размышляешь ты.'))
    }
}

function mobj2(sum, dsc)
    o = mobj(sum, dsc)
    oldact = o.act
    o.act = function (s, w)
        walk('table3')
        return oldact(s, w)
    end
    return o
end

fish = room {
    nam = 'Ммм... Вкусная рыба!',
    dsc = 'Ты съедаешь рыбу, набираясь сил.',
    obj = {
        mobj2(1, 'В тарелке на самом дне')
    }
}

tea = room {
    nam = 'Какой сладкий чай!',
    dsc = 'Ты выпиваешь чай.',
    obj = {
        mobj2(1, 'В чашке на самом дне')
    }
}

coffee = room {
    nam = 'Кофе просто чудесный!',
    dsc = 'Ты выпиваешь кофе.',
    obj = {
        mobj2(1, 'В чашке на самом дне')
    }
}

nearstove = room {
    nam = 'Плита',
    dsc = 'Ты рядом с кухонной плитой. Тут очень вкусно пахнет.',
    obj = {
        jump_obj(gobj('stove', '"Может быть забраться на {плиту}?", -- думаешь ты.')),
        gobj('kitchen', '^^{Дверь} в детскую позади тебя.'),
        gobj('heater', 'За плитой видна {батарея}.')
    }
}

stove = room {
    nam = 'На плите',
    dsc = 'На плите очень жарко. На огне стоит сковородка.',
    obj = {
        mobj(4, 'В сковородке'),
        fall_obj(gobj('nearstove', '"Под плитой не так пекло. Может {спрыгнуть}?", -- думаешь ты.'))
    }
}


heater = room {
    nam = 'Батарея отопления',
    dsc = 'Ты подходишь к батарее отопления. Здесь очень тепло.',
    obj = {
        gobj('cockroach', 'Под батареей сидит важный и усатый {таракан}.'),
        gobj('nearstove', 'Позади тебя стоит {плита}, от которой так вкусно пахнет.')
    }
}

cockroach = dlg {
    nam = 'Таракан',
    enter = 'Таракан важно повернул к тебе свою усатую голову.',
    obj = {
        [1] = phr('Добрый день!', '-- Привет!', [[pon(2)]]),
        [2] = _phr('Что вы здесь делаете?', '-- Продаю разные полезные штуки.', [[pon(3)]]),
        [3] = _phr('А что у вас есть?', '-- У меня есть волшебный ключ.', [[pon(4)]]),
        [4] = _phr('Продайте мне его!', '-- Он стоит 28 монет.', [[if me()._money >= 28 then pon(5); end]]),
        [5] = _phr('Договорились!', '-- Бери, - таракан протянул мне ключ.', [[drop('money'); take('key')]]),
        [6] = phr('До свидания!', 'Пока!', [[pon(); walk('heater');]])
    },
    exit = function (s, w)
        s:pon(1)
        s:poff(2)
        s:poff(3)
        s:poff(4)
        s:poff(5)
        s:pon(6)
    end
}

finish = room {
    nam = 'Конец',
    dsc = 'Поздравляю!^^Ты открыл шкатулку и достал телепортер. Теперь ты можешь убраться из этого дома. Удачи в дальнейших поисках Венома!',
    enter = function (s, f)
        set_music('mus/win.ogg')
    end
}
