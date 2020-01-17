class FundedProject < Project
  validates :funded_on, presence: true
end
