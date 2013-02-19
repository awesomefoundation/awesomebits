$(window).load ->
  $('.first input.multi').live 'change', ->
    clone = $(@parentNode).clone()
    clone.val('')
    clone.children('input.multi').val('')
    $(this).removeAttr('id')
    $(this).hide()
    filename = $(this).val().split("\\").pop()
    $(@parentNode).append($('<p>' + filename + '</p>'))
    $(@parentNode).removeClass('noremove')
    $(@parentNode).removeClass('first')
    $(@parentNode).addClass('uploading')

    # Limit the number of files we're allowed to attach
    if remaining = $(@parentNode).data('num-files')
      remaining = remaining - 1
      clone.data('num-files', remaining)

      if remaining <= 0
        clone.hide()

    clone.insertBefore(@parentNode)


  $('*[data-remove="true"]').live 'click', (event) ->
    event.stopPropagation()
    event.preventDefault()

    # The 'first' element always holds the remaining number of files
    first = $(@parentNode).siblings('.first')

    if ! $(@parentNode).hasClass("noremove")
      $(@parentNode).remove()

      if first.data('num-files') != undefined
        first.data('num-files', first.data('num-files') + 1)
        first.show()
