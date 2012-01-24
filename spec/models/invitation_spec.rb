require 'spec_helper'

describe Invitation do
  it { should belong_to(:inviter) }
  it { should belong_to(:invitee) }
  it { should belong_to(:chapter) }
  it { should validate_presence_of(:email) }
end
