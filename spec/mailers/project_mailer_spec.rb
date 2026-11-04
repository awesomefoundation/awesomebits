require 'spec_helper'

describe ProjectMailer, :type => :mailer do
  let(:project) { FactoryBot.create(:project, :chapter => chapter) }
  let(:mail) { ProjectMailer.new_application(project) }

  describe 'in a chapter without custom email response' do
    let(:chapter) { FactoryBot.create(:chapter) }

    it 'includes the default email text' do
      # No idea why this works with "include" and not "match" and
      # mail.body.to_s but not mail.body.encoded
      expect(mail.body.to_s).to include(Chapter::DEFAULT_SUBMISSION_RESPONSE_EMAIL)
    end

    it 'includes saved question-answer pairs even when earlier slots are empty' do
      project.update!(extra_question_3: "Saved question?", extra_answer_3: "Saved answer")
      expect(mail.body.to_s).to include("Saved question?:\nSaved answer")
    end
  end

  describe 'in a chapter with a custom email response' do
    let(:chapter) { FactoryBot.create(:chapter, :submission_response_email => "This is a custom email response") }

    it 'includes the custom response' do
      expect(mail.body.encoded).to match("This is a custom email response")
    end
  end
end
