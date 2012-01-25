class FakeMailer
  def initialize
    @emails = []
  end

  def method_missing(method, *args, &block)
    @emails << FakeEmail.new(method)
    @emails.last
  end

  def delivery_count_for(name)
    @emails.select{|mail| mail.name == name }.length
  end

  def delivery_made_for(name)
    @emails.select{|mail| mail.name == name }.all?(&:delivered?)
  end

  class FakeEmail
    def initialize(name)
      @name = name
    end

    attr_reader :name

    def deliver
      @delivered = true
    end

    def delivered?
      @delivered
    end
  end

end
