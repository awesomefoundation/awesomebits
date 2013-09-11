initialize_chapter_questions = ->
  questions = extra_questions[$('#project_chapter_id').val()]
  hide_questions()
  set_new_questions(questions)

update_extra_questions = (event) ->
  element = $(event.currentTarget)
  questions = extra_questions[element.val()]
  clear_existing_questions()
  set_new_questions(questions)

clear_existing_questions = ->
  hide_questions()
  $('.extra-questions input').val("")
  $('.extra-questions textarea').val("")

hide_questions = ->
  $('.extra-questions').hide()
  $('.extra-questions .extra-answer').hide()
  $('.extra-questions .extra-answer').removeClass('showing')
  $('.extra-questions .extra-question').removeClass('showing')

set_new_questions = (questions) ->
  if questions != undefined
    show_question_section() if questions.length
    show_one(question) for question in questions

show_question_section = ->
  $('.extra-questions').show()

show_one = (question) ->
  show_one_question(question)
  show_one_answer(question)

show_one_question = (question) ->
  question_input = next_hidden_question();
  question_input.addClass("showing")
  question_input.find('input').val(question)

next_hidden_question = ->
  $($('.extra-questions .extra-question:not(.showing)')[0])

show_one_answer = (question) ->
  answer = next_hidden_answer()
  answer.show()
  answer.addClass("showing")
  answer.find('label').text(question)

next_hidden_answer = ->
  $($('.extra-questions .extra-answer:not(.showing)')[0])

$('#project_chapter_id').change(update_extra_questions)

$(document).ready ->
  if $('.extra-questions').length
    initialize_chapter_questions()

