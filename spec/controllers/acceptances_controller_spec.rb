require 'spec_helper'

describe AcceptancesController do
  let(:invitation) { FactoryGirl.create(:invitation) }

  context 'not logged in' do
    context 'GET to #new' do
      before do
        get :new, :invitation_id => invitation.id
      end

      it { should respond_with(:success) }
    end

    context 'accepting with password' do
      before do
        post :create, :invitation_id => invitation.id, :invitation => {}
      end

      it { should respond_with(:success) }
      it { should render_template('new') }
      it { expect(flash[:notice]).not_to be_blank }
    end
  end
end
