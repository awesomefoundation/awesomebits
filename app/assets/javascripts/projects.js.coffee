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

shortlist_failure = (xhr, status, error) ->
  alert(error.message)

$(".short-list")
  .bind("ajax:beforeSend",  shortlist_before_send)
  .bind("ajax:success", shortlist_success)
  .bind("ajax:failure", shortlist_failure)
