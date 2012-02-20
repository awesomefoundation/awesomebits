shortlist_before_send = (event, data, xhr) ->
  xhr.type = $(event.currentTarget).attr('data-method').toUpperCase()

shortlist_success = (event, data, status, xhr) ->
  project_container = $('article[data-id="'+data.project_id+'"]')
  if data.shortlisted
    project_container.addClass('shortlisted')
    project_container.find('a.short-list').attr('data-method', 'delete')
  else
    project_container.removeClass('shortlisted')
    project_container.find('a.short-list').attr('data-method', 'post')
    filter_short_list()

shortlist_failure = (xhr, status, error) ->
  alert(error.message)

filter_short_list = ->
  if $('.short-list-toggle input[type="checkbox"]').attr('checked')
    $('section.applications article').not('.shortlisted').hide()
  else
    $('section.applications article').show()

$(".short-list")
  .bind("ajax:beforeSend",  shortlist_before_send)
  .bind("ajax:success", shortlist_success)
  .bind("ajax:failure", shortlist_failure)

$('.short-list-toggle input[type="checkbox"]').change(filter_short_list)
