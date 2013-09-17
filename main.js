// Generated by CoffeeScript 1.6.3
(function() {
  var analyse, count, countNesting, countSelectorType, countSelectors, css, fs, _,
    __hasProp = {}.hasOwnProperty;

  css = require('css');

  _ = require('underscore');

  fs = require('fs');

  count = {
    nesting: [],
    sibling: 0,
    rules: 0,
    media: 0,
    element: 0,
    id: 0,
    "class": 0,
    pseudo: 0,
    selector: 0,
    attribute: 0
  };

  countSelectorType = function(selector) {
    var _ref, _ref1, _ref2, _ref3, _ref4, _ref5, _ref6;
    count.selector++;
    if (((_ref = selector.match(/\+/gi)) != null ? _ref.length : void 0) > 0) {
      count.sibling++;
    }
    if (((_ref1 = selector.match(/\.[a-z0-9_-]*$/i)) != null ? _ref1.length : void 0) > 0) {
      return count["class"]++;
    } else if (((_ref2 = selector.match(/\:+[^,:>\s]+$/i)) != null ? _ref2.length : void 0) > 0) {
      return count.pseudo++;
    } else if (((_ref3 = selector.match(/\#[a-z0-9_-]+$/i)) != null ? _ref3.length : void 0) > 0) {
      return count.id++;
    } else if (((_ref4 = selector.match(/\]$/i)) != null ? _ref4.length : void 0) > 0) {
      return count.attribute++;
    } else if (((_ref5 = selector.match(/(?:\s|\>|\+)+[a-z0-9_-]+$/i)) != null ? _ref5.length : void 0) > 0) {
      return count.element++;
    } else if (((_ref6 = selector.match(/^[a-z0-9_-]+$/i)) != null ? _ref6.length : void 0) > 0) {
      return count.element++;
    } else {
      return count.selector--;
    }
  };

  countSelectors = function(rule) {
    if (rule.type === 'media' && rule.rules) {
      count.media++;
      _(rule.rules).each(countSelectors);
    }
    if (_(rule).has('selectors') && rule.selectors.length > 0) {
      return _(rule.selectors).each(countSelectorType);
    }
  };

  analyse = function(rules) {
    var selectors;
    count.rules = rules.length;
    return selectors = _(rules).each(countSelectors);
  };

  countNesting = function(rules) {
    return _(rules).each(function(selector) {
      var depth, _ref;
      depth = (_ref = selector.match(/\s|\>/gi)) != null ? _ref.length : void 0;
      if (!count.nesting[depth] && depth) {
        return count.nesting[depth] = 1;
      } else if (depth) {
        return count.nesting[depth]++;
      }
    });
  };

  fs.readFile('./bootstrap.min.css', function(err, data) {
    var key, rules, value, _ref;
    rules = css.parse(data.toString()).stylesheet.rules;
    analyse(rules);
    _(rules).each(function(rule) {
      if (rule.selectors) {
        return _(rule.selectors).each(function(selector) {
          var nestLevel, _ref;
          nestLevel = (_ref = selector.match(/\s|\>/gi)) != null ? _ref.length : void 0;
          if (!count.nesting[nestLevel] && nestLevel) {
            return count.nesting[nestLevel] = 1;
          } else if (nestLevel) {
            return count.nesting[nestLevel]++;
          }
        });
      }
    });
    _ref = count.nesting;
    for (key in _ref) {
      if (!__hasProp.call(_ref, key)) continue;
      value = _ref[key];
      console.log(key, value);
    }
    console.log(count);
    return console.log(count["class"] + count.id + count.pseudo + count.attribute + count.element);
  });

}).call(this);