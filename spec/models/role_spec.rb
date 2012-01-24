require 'spec_helper'

describe Role do
  it { should belong_to :user }
  it { should belong_to :chapter }
end
