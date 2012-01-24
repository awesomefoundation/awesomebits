require 'spec_helper'

describe Project do
  it { should belong_to :chapter }
  it { should validate_presence_of :title }
  it { should validate_presence_of :status }
  it { should validate_presence_of :description }
end
