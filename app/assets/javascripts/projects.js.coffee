shortlist_before_send = (event, data, xhr) ->
  xhr.type = $(event.currentTarget).attr('data-method').toUpperCase()

shortlist_success = (event, data, status, xhr) ->
  project_container = $('article[data-id="'+data.project_id+'"]')
  vote_button = project_container.find('a.short-list[data-chapter="'+data.chapter_id+'"]')
  $(event.currentTarget).blur()
  if data.shortlisted
    project_container.addClass('shortlisted')
    vote_button.attr('data-method', 'delete')
  else
    project_container.removeClass('shortlisted')
    vote_button.attr('data-method', 'post')
    project_container.find('a.short-list[data-chapter=""]').remove()

shortlist_failure = (xhr, status, error) ->
  alert(error.message)

mark_as_winner_before_send = (event, data, xhr) ->
  xhr.type = $(event.currentTarget).attr('data-method').toUpperCase()

mark_as_winner_success = (event, data, status, xhr) ->
  project_container = $('article[data-id="'+data.project_id+'"]')

  if data.winner
    project_container.addClass('winner')
    project_container.find('a.mark-as-winner').attr('data-method', 'delete')
  else
    project_container.removeClass('winner')
    project_container.find('a.mark-as-winner').attr('data-method', 'post')

  if data.location
    window.location = data.location

mark_as_winner_failure = (xhr, status, error) ->
  alert(error.message)

display_remaining_chars = ->
  self = $(this)
  element = $('#'+self.attr('id')+'_chars_left')
  max_length = self.attr('maxlength')
  curr_length = self.val().length
  element.text(max_length - curr_length)

$(".short-list")
  .bind("ajax:beforeSend",  shortlist_before_send)
  .bind("ajax:success", shortlist_success)
  .bind("ajax:failure", shortlist_failure)

$(".mark-as-winner, .remove-as-winner")
  .bind("ajax:beforeSend", mark_as_winner_before_send)
  .bind("ajax:success", mark_as_winner_success)
  .bind("ajax:failure", mark_as_winner_failure)

$('#project_about_me').keyup(display_remaining_chars)
$('#project_about_project').keyup(display_remaining_chars)
$('#project_use_for_money').keyup(display_remaining_chars)

populate_funded_description = ->
  funded_description = $('#project_funded_description')
  description        = $('#project_about_project').val()

  if $(this).val() and !funded_description.val()
    funded_description.val(description)

$('#project_funded_on').blur(populate_funded_description)

$(".comment-form")
  .on("ajax:success", (event, data, status, xhr) ->
    CommentStore.setComments(data.comments, data.project_id)
    $(this).find('.comment-form__input--textarea').val('')
    $(this).find('.comment-form__input--textarea').blur()
  ).on("ajax:error", (event, xhr, status, error) ->
    alert(xhr.responseJSON.message)
  )
