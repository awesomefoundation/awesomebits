require 'spec_helper'

describe 'Routes for the blog' do
  it 'should redirect the contact page' do
    get '/blog/contact/'
    response.should redirect_to('/en/contact')
  end

  it 'should redirect the about page' do
    get '/blog/about/'
    response.should redirect_to('/en/about_us')
  end

  it 'should redirect the main blog page' do
    get '/blog/'
    response.should redirect_to('http://blog.awesomefoundation.org')
  end

  it 'should redirect a specific blog page' do
    get '/blog/2012/01/01/post-name'
    response.should redirect_to('http://blog.awesomefoundation.org/2012/01/01/post-name')
  end
end

describe 'Routes for submissions' do
  it 'should redirect the apply page' do
    get '/apply'
    response.should redirect_to('/en/submissions/new')
  end
end
