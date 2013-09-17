css = require('css')
_ = require('underscore')
fs = require('fs')

#
# Memory for stats
#
count = {
    nesting: []
    sibling: 0
    rules: 0
    media: 0
    element: 0
    id: 0
    class: 0
    pseudo: 0
    selector: 0
    attribute: 0

}


countSelectorType = (selector) ->
    count.selector++

    # sibling selector .element + h2 
    if(selector.match(/\+/gi)?.length > 0)
        count.sibling++

    # class selectors .class
    if(selector.match(/\.[a-z0-9_-]*$/i)?.length > 0)
        count.class++

    # pseudo selectors :pseudo
    else if(selector.match(/\:+[^,:>\s]+$/i)?.length > 0)
        count.pseudo++

    # id selectors #id
    else if(selector.match(/\#[a-z0-9_-]+$/i)?.length > 0)
        count.id++ 

    # attribute selectors #id
    else if(selector.match(/\]$/i)?.length > 0)
        count.attribute++

    # element selector div
    else if(selector.match(/(?:\s|\>|\+)+[a-z0-9_-]+$/i)?.length > 0)
        count.element++ 

    else if(selector.match(/^[a-z0-9_-]+$/i)?.length > 0)
        count.element++ 

    else
        count.selector-- # Except non-matching selectors from count

countSelectors = (rule) ->
    if rule.type is 'media' and rule.rules
        count.media++
        _(rule.rules).each countSelectors

    if(_(rule).has('selectors') and rule.selectors.length > 0)
        _(rule.selectors).each countSelectorType


analyse = (rules) ->
    # Cache the amount of rules
    count.rules = rules.length
    selectors = _(rules).each countSelectors

    #    countNesting rules


countNesting = (rules) ->
    # Split rules into an array
    # Count nesting
    _(rules).each (selector) ->
        depth = selector.match(/\s|\>/gi)?.length
        if(!count.nesting[depth] and depth)
            count.nesting[depth] = 1
        else if depth
            count.nesting[depth]++


fs.readFile './bootstrap.min.css', (err, data) ->
    rules = css.parse(data.toString()).stylesheet.rules
    analyse rules

    _(rules).each (rule) ->
        if rule.selectors
            _(rule.selectors).each (selector) ->
                nestLevel = selector.match(/\s|\>/gi)?.length
                if(!count.nesting[nestLevel] and nestLevel)
                    count.nesting[nestLevel] = 1
                else if nestLevel
                    count.nesting[nestLevel]++

    for own key, value of count.nesting
        console.log key, value 

    console.log count
    console.log count.class + count.id + count.pseudo + count.attribute + count.element


