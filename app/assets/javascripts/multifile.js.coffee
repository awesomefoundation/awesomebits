$(window).load ->
  $('.first input.multi').live 'change', ->
    clone = $(@parentNode).clone()
    clone.val('')
    $(@parentNode).removeClass('noremove')
    clone.insertBefore(@parentNode)

  $('*[data-remove="true"]').live 'click', (event) ->
    event.stopPropagation()
    event.preventDefault()
    if ! $(@parentNode).hasClass("noremove")
      $(@parentNode).remove()

