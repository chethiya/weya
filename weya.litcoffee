List of SVG elements

    Tags =
     svg: 'a altGlyph altGlyphDef altGlyphItem animate animateColor
      animateMotion animateTransform circle clipPath color-profile cursor
      defs desc ellipse feBlend feColorMatrix feComponentTransfer
      feComposite feConvolveMatrix feDiffuseLighting feDisplacementMap
      feDistantLight feFlood feFuncA feFuncB feFuncG feFuncR feGaussianBlur
      feImage feMerge feMergeNode feMorphology feOffset fePointLight
      feSpecularLighting feSpotLight feTile feTurbulence
      filter font font-face font-face-format font-face-name font-face-src
      font-face-uri foreignObject g glyph glyphRef hkern image line
      linearGradient marker mask metadata missing-glyph mpath path pattern
      polygon polyline radialGradient rect script set stop style svg symbol
      text textPath title tref tspan use view vkern switch foreignObject'

List of HTML elements

     html: 'a abbr address article aside audio b bdi bdo blockquote body button
      canvas caption cite code colgroup datalist dd del details dfn div dl dt
      em fieldset figcaption figure footer form h1 h2 h3 h4 h5 h6 head header
      hgroup html i iframe ins kbd label legend li main map mark menu meter
      nav noscript object ol optgroup option output p pre progress q rp rt
      ruby s samp script section select small span strong style sub summary
      sup table tbody td textarea tfoot th thead time title tr u ul video'

     htmlVoid: 'area base br col command embed hr img input keygen link meta
      param source track wbr'

Wrapper for browser API

    Api =
     document: @document


#Weya DOM

    weyaDomCreate = ->

Weya object to be passed as `this`

     weya =
      _elem: null

Manipulating dom objects

     setStyles = (elem, styles) ->
      for k, v of styles
       if v?
        elem.style.setProperty k, v
       else
        elem.style.removeProperty k

     setEvents = (elem, events) ->
      for k, v of events
       elem.addEventListener k, v, false

     setAttributes = (elem, attrs) ->
      for k, v of attrs
       switch k
        when 'style' then setStyles elem, v
        when 'on' then setEvents elem, v
        else
         if v?
          elem.setAttribute k, v
         else
          elem.removeAttribute k

Parse id and class string

     parseIdClass = (str) ->
      res =
       id: null
       class: []

      for c, i in str.split "."
       if c.indexOf("#") is 0
        res.id = c.substr 1
       else if c isnt ""
        if not res.class?
         res.class = [c]
        else
         res.class.push c

      return res


Append a child element

     append = (ns, name, args) ->
      idClass = null
      contentText = null
      attrs = null
      contentFunction = null

      for arg, i in args
       switch typeof arg
        when 'function' then contentFunction = arg
        when 'object' then attrs = arg
        when 'string'
         if args.length is 1
          contentText = arg
         else
          c = arg.charAt 0

          if i is 0 and (c is '#' or c is '.')
           idClass = arg
          else
           contentText = arg

Keep a reference to parent element

      pElem = @_elem

Keep a reference of `elem` to return at the end of the function

      if ns?
       elem = @_elem = Api.document.createElementNS ns, name
      else
       elem = @_elem = Api.document.createElement name

      if idClass?
       idClass = parseIdClass idClass
       if idClass.id?
        elem.id = idClass.id
       if idClass.class?
        if elem.classList?
         for c in idClass.class
          elem.classList.add c
        else #For older browsers; does not work with svgs
         className = ''
         for c in idClass.class
          className += ' ' if className isnt ''
          className += "#{c}"
         elem.className = className

      if attrs?
       setAttributes elem, attrs

      if pElem?
       pElem.appendChild elem

      if contentFunction?
       contentFunction.call this
      else if contentText?
       elem.textContent = contentText

      @_elem = pElem
      return elem

Wrap `append`

     wrapAppend = (ns, name) ->
      ->
       append.call this, ns, name, arguments


Initialize

     for name in Tags.svg.split ' '
      weya[name] = wrapAppend "http://www.w3.org/2000/svg", name

     for name in Tags.html.split ' '
      weya[name] = wrapAppend "http://www.w3.org/1999/xhtml", name

     for name in Tags.htmlVoid.split ' '
      weya[name] = wrapAppend null, name

     return weya


#Weya Markup

    weyaMarkupCreate = ->

Weya object to be passed as `this`

     weya =
      _buf: null
      _indent: 0

Render components

     setStyles = (buf, styles) ->
      buf.push " style=\""
      for k, v of styles
       buf.push "#{k}:#{v};"
      buf.push "\""

     setEvents = (buf, events) ->
      for k, v of events
       buf.push " on#{k}=\"#{v}\""

     setAttributes = (buf, attrs) ->
      for k, v of attrs
       switch k
        when 'style' then setStyles buf, v
        when 'on' then setEvents buf, v
        else
         buf.push " #{k}=\"#{v}\""

     setIndent = (buf, indent) ->
      for i in [0...indent]
       buf.push " "

Parse id and class string

     parseIdClass = (str) ->
      res =
       id: null
       class: null

      for c, i in str.split "."
       if c.indexOf("#") is 0
        res.id = c.substr 1
       else if c isnt ""
        if not res.class?
         res.class = c
        else
         res.class += " #{c}"

      return res


Append a child element

     append = (ns, name, args) ->
      idClass = null
      contentText = null
      attrs = null
      contentFunction = null

      for arg, i in args
       switch typeof arg
        when 'function' then contentFunction = arg
        when 'object' then attrs = arg
        when 'string'
         if args.length is 1
          contentText = arg
         else
          c = arg.charAt 0

          if i is 0 and (c is '#' or c is '.')
           idClass = arg
          else
           contentText = arg

      buf = @_buf

      setIndent buf, @_indent

      buf.push "<#{name}"

      if idClass?
       idClass = parseIdClass idClass
       if idClass.id?
        buf.push " id=\"#{idClass.id}\""
       if idClass.class?
        buf.push " class=\"#{idClass.class}\""

      if attrs?
       setAttributes buf, attrs

Can close void elements (element that self close) with a `/>`

      buf.push ">\n"
      @_indent++

      if contentFunction?
       contentFunction.call this
      else if contentText?
       setIndent buf, @_indent
       buf.push contentText
       buf.push "\n"

      @_indent--
      setIndent buf, @_indent
      buf.push "</#{name}>\n"

Wrap `append`

     wrapAppend = (ns, name) ->
      ->
       append.call this, ns, name, arguments


Initialize

     for name in Tags.svg.split ' '
      weya[name] = wrapAppend "http://www.w3.org/2000/svg", name

     for name in Tags.html.split ' '
      weya[name] = wrapAppend null, name

     for name in Tags.htmlVoid.split ' '
      weya[name] = wrapAppend null, name

     return weya


#Weya API

    weyaDom = weyaDomCreate()
    weyaMarkup = weyaMarkupCreate()

Create and append to `options.elem`. If `options.context` is provied it can be
accessed via `@$`. If `options.elem` is `null`, the element is created but
not appended.

    @Weya = Weya = (options, func) ->
     weya = weyaDom
     pContext = weya.$
     weya.$ = options.context
     pElem = weya._elem
     weya._elem = options.elem
     r = func?.call weya
     weya._elem = pElem
     weya.$ = pContext
     return r

    Weya.markup = (options, func) ->
     weya = weyaMarkup
     pContext = weya.$
     weya.$ = options.context
     pBuf = weya._buf
     weya._buf = []
     r = func?.call weya
     buf = weya._buf
     weya._buf = pBuf
     weya.$ = pContext
     return buf.join ''

    Weya.setApi = (api) ->
     for k, v of api
      Api[k] = v

    if module?
     module.exports = Weya
