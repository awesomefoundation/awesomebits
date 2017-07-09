RSpec::Matchers.define :have_delivered_email do |expected|
  chain :to do |address|
    @address = address
  end

  match do |actual|
    emails = actual.delivery_to(expected, @address)
    expect(emails.length).to eq(1)
  end
end
