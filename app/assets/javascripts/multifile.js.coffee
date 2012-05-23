$(window).load ->
  $('.first input.multi').live 'change', ->
    clone = $(@parentNode).clone()
    clone.val('')
    $(this).removeAttr('id')
    $(this).hide()
    filename = $(this).val().split("\\").pop()
    $(@parentNode).append($('<p>' + filename + '</p>'))
    $(@parentNode).removeClass('noremove')
    $(@parentNode).removeClass('first')
    $(@parentNode).addClass('uploading')
    clone.insertBefore(@parentNode)

  $('*[data-remove="true"]').live 'click', (event) ->
    event.stopPropagation()
    event.preventDefault()
    if ! $(@parentNode).hasClass("noremove")
      $(@parentNode).remove()

