require 'spec_helper'
require 'paperclip/matchers/have_attached_file_matcher'

describe Photo do
  it { should belong_to :project }
  it { should have_attached_file :image }
end
