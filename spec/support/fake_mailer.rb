class FakeMailer
  def initialize
    @emails = []
  end

  def method_missing(method, *args, &block)
    @emails << FakeEmail.new(method)
    @emails.last
  end

  def delivery_to(email_name, to = nil)
    @emails.select do |mail|
      res = mail.name == email_name
      res &&= (to.nil? || mail.to.include?(to))
      res &&= mail.delivered?
      res
    end
  end

  class FakeEmail
    def initialize(name)
      @name = name
    end

    attr_reader :name

    def deliver_now
      @delivered = true
    end

    def delivered?
      @delivered
    end
  end

end
