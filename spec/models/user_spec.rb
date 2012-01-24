require 'spec_helper'

describe User do
  it { should validate_presence_of(:first_name) }
  it { should validate_presence_of(:last_name) }
  it { should validate_presence_of(:encrypted_password) }
  it { should have_many(:roles) }
  it { should have_many(:chapters).through(:roles) }
end
