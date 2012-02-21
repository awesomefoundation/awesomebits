set_data_method = (event, data, xhr) ->
  xhr.type = $(event.currentTarget).attr('data-method').toUpperCase()

dean_success = (event, data, status, xhr) ->
  role_container = $('span[data-role-id="'+data.role_id+'"]')
  if data.role == 'dean'
    role_container.closest('tr').find('td.role-name').text('Dean')
    role_container.find('a.dean-toggle').text('Demote Dean').attr('data-method', 'delete').removeClass('promote-user').addClass('demote-user')
  else
    role_container.closest('tr').find('td.role-name').text('Trustee')
    role_container.find('a.dean-toggle').text('Promote Trustee').attr('data-method', 'post').removeClass('demote-user').addClass('promote-user')

admin_success = (event, data, status, xhr) ->
  user_row = $('tr[data-user-id="'+data.user_id+'"]')
  if data.admin == true
    user_row.removeClass('trustee').addClass('admin')
    user_row.find('a.admin-toggle').text('Demote Admin').attr('data-method', 'delete').removeClass('promote-user').addClass('demote-user')
  else
    user_row.removeClass('admin').addClass('trustee')
    user_row.find('a.admin-toggle').text('Promote Admin').attr('data-method', 'post').removeClass('demote-user').addClass('promote-user')

ajax_failure = (xhr, status, error) ->
  alert(error.message)

$(".admin-toggle")
  .live("ajax:beforeSend", set_data_method)
  .live("ajax:success", admin_success)
  .live("ajax:failure", ajax_failure)

$(".dean-toggle")
  .live("ajax:beforeSend", set_data_method)
  .live("ajax:success", dean_success)
  .live("ajax:failure", ajax_failure)
