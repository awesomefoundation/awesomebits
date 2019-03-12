require 'spec_helper'

describe AcceptancesController do
  let(:invitation) { FactoryGirl.create(:invitation) }

  context 'not logged in' do
    context 'GET to #new' do
      before do
        get :new, params: { invitation_id: invitation.id }
      end

      it { is_expected.to respond_with(:success) }
    end

    context 'accepting without a password' do
      before do
        post :create, params: { invitation_id: invitation.id, invitation: { password: "" } }
      end

      it { is_expected.to respond_with(:success) }
      it { is_expected.to render_template('new') }
      it { expect(flash[:notice]).not_to be_blank }
    end
  end
end
