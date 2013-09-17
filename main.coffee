css = require('css')
_ = require('underscore')

#
# Memory for stats
#
class Count
    constructor: ->
        @nesting = []
        @sibling = 0
        @rules = 0
        @media = 0
        @element = 0
        @id = 0
        @classes = 0
        @pseudo = 0
        @selector = 0
        @attribute = 0
        @important = 0

points = {
    attribute: 2
    pseudo: 3
    nesting: [null, 4, 6, 10, 15, 30, 50, 70, 100, 130, 160, 200, 250, 330, 400]
}

giveScore = (count) ->
    score = 0

    if(count.attribute)
        score += count.attribute * points.attribute

    if(count.pseudo)
        score += count.pseudo * points.pseudo

    for value, key in count.nesting
        if key? and value?
            score += points.nesting[key] * value

    #Divide overall score by selector
    #    score = (score / count.selector).toFixed 2
    score


libraries = [
    {
        name: 'Twitter Bootstrap 3.0'
        path: 'css-libs/bootstrap3.min.css'
        count: new Count
    },
    {
        name: 'Twitter Bootstrap 2.3.2'
        path: 'css-libs/bootstrap2.responsive.min.css'
        count: new Count
    },
    {
        name: 'Zurb Foundation'
        path: 'css-libs/foundation.css'
        count: new Count
    },
    {
        name: 'Pure CSS'
        path: 'css-libs/pure.css'
        count: new Count
    },
    {
        name: 'Inuit CSS'
        path: 'css-libs/inuit.css'
        count: new Count
    }
    ]


countSelectorType = (selector, count) ->
    count.selector++

    # sibling selector .element + h2 
    if(selector.match(/\+/gi)?.length > 0)
        count.sibling++

    # class selectors .class
    if(selector.match(/\.[a-z0-9_-]*$/i)?.length > 0)
        count.classes++

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

countSelectors = (rule, count) ->
    if rule.type is 'media' and rule.rules
        count.media++
        _(rule.rules).each (rule) ->
            countSelectors(rule, count)

    if(_(rule).has('selectors') and rule.selectors.length > 0)
        _(rule.selectors).each (selector) ->
            countSelectorType selector, count

bytesToSize = (bytes) ->
    sizes = ['Bytes', 'KB', 'MB', 'GB', 'TB'];

    if (bytes == 0) 
        'n/a'

    else
        i = parseInt(Math.floor(Math.log(bytes) / Math.log(1024)));
        Math.round(bytes / Math.pow(1024, i), 2) + ' ' + sizes[i];

analyse = (rules, count) ->
    # Cache the amount of rules
    count.rules = rules.length

    selectors = _(rules).each (rule) ->
        countSelectors rule, count

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

renderData = (data) ->
    html = _($('#benchmark').html()).template(data)
    $('#benchmarks').append(html)


init = (data, lib) ->
    lib.count.important = data.match(/\!important/gi)?.length || 0 
    rules = css.parse(data).stylesheet.rules
    analyse rules, lib.count

    _(rules).each (rule) ->
        if rule.selectors
            _(rule.selectors).each (selector) ->
                nestLevel = selector.match(/\s|\>/gi)?.length
                if(!lib.count.nesting[nestLevel] and nestLevel)
                    lib.count.nesting[nestLevel] = 1
                else if nestLevel
                    lib.count.nesting[nestLevel]++


    # Give a score
    lib.score = giveScore lib.count

    if($?)
        renderData(lib)
    else 
        console.log lib



ajaxRequest = (path, callback) ->
    if(window? and _(window).has '$')
        xhr = $.get path, (data) ->
            callback data, bytesToSize(xhr.getResponseHeader('Content-Length'))


    else
        fs = require('fs')
        fs.readFile path, (err, data) ->
            callback data.toString()

_(libraries).each (lib) ->
    ajaxRequest lib.path, (data, size) ->
        lib.size = size
        init(data, lib)

