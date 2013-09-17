count = {
    nesting: []
}

clean = (css)->
    #
    # Strip css from unneeded text
    #
    css = css.replace /\/\//, ''                # Strip all line-comments
    css = css.replace /\s\s+/g, ' '             # Remove double-spaces and newlines
    css = css.replace /\s\>\s/g, '>'            # Remove spaces surrounding child selectors
    css = css.replace /\s\+\s/g, '+'            # Remove spaces surrounding child selectors
    css = css.replace /\/\*.*\*\//g, ''         # Strip all multiline comments
    css = css.replace /@media[^\.]*/g, ''       # Strip opening media queries
    css = css.replace /\}[^{]*\}/g, ''          # Strip closing media queries
    css = css.replace /\{[^}]+\}/g, '{}'        # Strip CSS blocks 
    css = css.replace /\[[^\]]*\]+/g, '[]'        # Strip attribute selector blocks 
    css = css.replace /\@[^{]+\{[^\}]*\}/gi, '' #Strip @page and font-face
    css = css.replace /(\.|\#)[a-z0-9-_]+/gi, '\$1s'      # Replace all class and id names with s

countSelectorTypes = (selectors) ->
    #
    # Counting what type of selectors are used
    #
    css = ',' + css
    css = selectors.toString()
    console.log css

    count.neighbour = css.match(/\+/gi)?.length || 0          # sibling selector .element + h2 

    count.class = css.match(/\.s,/gi)?.length || 0            # class selectors .class
    count.pseudo = css.match(/\:+[^,:]+,/gi)?.length || 0            # pseudo selectors :pseudo
    count.id = css.match(/\#[a-z\-_0-9]+/gi)?.length || 0                # id selectors #id
    count.attribute = css.match(/\[\]\,/gi)?.length || 0  # attribute selectors #id
    count.element = css.match(/(?:\s|\,|\>|\+)+[a-z]+,/gi)?.length                # element selector div
    count

countNesting = (selectors) ->
    # Split selectors into an array

    # Cache the amount of selectors
    count.selectors = selectors.length

    # Count nesting
    _(selectors).each (selector) ->
        depth = selector.match(/\s|\>/gi)?.length
        if(!count.nesting[depth] and depth)
            count.nesting[depth] = 1
        else if depth
            count.nesting[depth]++



parse = (css) ->
    # Count important statements before removing css blocks
    count.important = css.match(/\!important/gi).length

    # Rid CSS of all text that we don't need for the analysis
    css = clean css

    # Split up CSS into selectors
    selectors = css.match(/[^{},]+/gi) 

    # Count the levels of nesting
    countNesting selectors

    # Count selector types and nesting
    countSelectorTypes selectors

    console.log count


# Load css file
$.get 'bootstrap.min.css', parse
