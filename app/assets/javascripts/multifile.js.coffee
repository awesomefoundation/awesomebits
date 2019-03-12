decrement_file_counter = (element) -> 
  if remaining = element.data('num-files')
    remaining = remaining - 1
    element.data('num-files', remaining)

    if remaining <= 0
      element.hide()

$(document).ready ->
  $('.input.file').find('.toggle-uploader a').click ->
    $('.input.file *[data-remove="true"]').click()
    $('.input.file').toggle()
    return false

  $(document).on 'change', '.first input.multi', ->
    clone = $(@parentNode).clone()
    clone.val('')
    clone.children('input.multi').val('')
    clone.data('num-files', $(@parentNode).data('num-files'))
    $(this).removeAttr('id')
    $(this).hide()
    filename = $(this).val().split("\\").pop()
    $(@parentNode).find('.filename').html(filename)
    $(@parentNode).removeClass('noremove')
    $(@parentNode).removeClass('first')
    $(@parentNode).addClass('uploading')

    # Limit the number of files we're allowed to attach
    decrement_file_counter(clone)

    clone.insertBefore(@parentNode)

  $('.s3_upload_field').each ->
    $(this).S3FileField
      add: (e, data) ->
        filename = data.files[0].name
        unique_id = data.files[0].unique_id

        element = $(e.target)
        parent = $(e.target.parentElement)
        clone = parent.clone()

        clone.children("##{element.attr('id')}").remove()
        clone.append($('<input>', { type: 'hidden', class: 'file-field', name: element.attr('name') }))
        clone.attr('id', "upload-#{unique_id}")
        clone.find('p.filename').html(filename)
        clone.find('.progress-meter').show()
        clone.find('.upload-status').show()
        clone.removeClass('noremove')
        clone.removeClass('first')

        clone.insertAfter(parent)

        # Limit the number of files we're allowed to attach
        decrement_file_counter(parent)

        window.awesomeEnvironment.remainingUploads += 1

        data.submit()

      always: (e, data) ->
        window.awesomeEnvironment.remainingUploads -= 1

      done: (e, data) ->
        clone = $("#upload-#{data.files[0].unique_id}")

        clone.children('.file-field').val(data.result.url)
        clone.find('.progress-meter').hide()
        clone.find('.upload-status').removeClass("icon-spinner")
        clone.find('.upload-status').removeClass("icon-spin")
        clone.find('.upload-status').addClass("icon-ok")

      fail: (e, data) ->
        clone = $("#upload-#{data.files[0].unique_id}")

        clone.find('.progress-meter').css(background: '#E81717')
        clone.find('.upload-status').removeClass("icon-spinner")
        clone.find('.upload-status').removeClass("icon-spin")
        clone.find('.upload-status').addClass("icon-exclamation")

      progress: (e, data) ->
        clone = $("#upload-#{data.files[0].unique_id}")

        progress = parseInt(data.loaded / data.total * 100, 10)
        clone.find('.progress-meter').css(width: "#{progress}%")

      dropZone: null

  $(document).on 'click', '*[data-remove="true"]', (event) ->
    event.stopPropagation()
    event.preventDefault()

    # The 'first' element always holds the remaining number of files
    first = $(@parentNode).siblings('.first')

    if ! $(@parentNode).hasClass("noremove")
      $(@parentNode).remove()

      if first.data('num-files') != undefined
        first.data('num-files', first.data('num-files') + 1)
        first.show()

  $('.project-form form').bind 'submit', (event) ->
    if window.awesomeEnvironment.remainingUploads > 0
      alert($('.project-form form').data('uploading-alert-text'))
      return false
