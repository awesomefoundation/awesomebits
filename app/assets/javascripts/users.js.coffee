set_data_method = (event, data, xhr) ->
  xhr.type = $(event.currentTarget).attr('data-method').toUpperCase()

dean_success = (event, data, status, xhr) ->
  span = $('span[data-role-id="'+data.role_id+'"]')
  span.find('a').hide();
  if data.role == 'dean'
    span.closest('tr').find('td.role-name').text('Dean')
    span.find('a.demote-user').css('display', 'block') 
  else
    span.closest('tr').find('td.role-name').text('Trustee')
    span.find('a.promote-user').css('display', 'block') 

admin_success = (event, data, status, xhr) ->
  row = $('tr[data-user-id="'+data.user_id+'"]')
  row.find('td.promote-demote-admin a').hide()
  if data.admin == true
    row.removeClass('non_admin').addClass('admin')
    row.find('td.promote-demote-admin a.demote-user').css('display', 'block') 
  else
    row.removeClass('admin').addClass('non_admin')
    row.find('td.promote-demote-admin a.promote-user').css('display', 'block')

ajax_failure = (xhr, status, error) ->
  alert(error.message)

$("td.promote-demote-admin a")
  .live("ajax:beforeSend", set_data_method)
  .live("ajax:success", admin_success)
  .live("ajax:failure", ajax_failure)

$("td.promote-demote-dean a")
  .live("ajax:beforeSend", set_data_method)
  .live("ajax:success", dean_success)
  .live("ajax:failure", ajax_failure)
