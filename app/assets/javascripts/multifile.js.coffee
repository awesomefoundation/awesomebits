$(window).load ->
  $('.first input.multi').live 'change', ->
    clone = $(@parentNode).clone()
    clone.val('')
    $(@parentNode).removeClass('first')
    clone.insertBefore(@parentNode)

  $('.multi-input:.first *[data-remove="true"]').live 'click', (event) ->
    event.stopPropagation()
    event.preventDefault()

  $('.multi-input:not(.first) *[data-remove="true"]').live 'click', (event) ->
    event.stopPropagation()
    event.preventDefault()
    $(@parentNode).remove()

