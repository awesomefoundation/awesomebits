Feature: An admin can invite new trustees, and they can accept and become users

  Scenario: Admin invites to any chapter
    Given I am logged in as an admin
    When I invite a new trustee to the "Boston" chapter
    Then that person should get an invitation email
    When they accept the invitation
    Then they should get another email welcoming them
    And the trustee can log in

    When I invite a new trustee to the "Sydney" chapter
    Then that person should get an invitation email
    When they accept the invitation
    Then they should get another email welcoming them
    And the trustee can log in

  Scenario: Dean can only invite to their chapter
    Given I am logged in as a "Boston" dean
    When I invite a new trustee to the "Boston" chapter
    Then that person should get an invitation email
    When they accept the invitation
    Then they should get another email welcoming them
    And the trustee can log in
    When I try to invite a new trustee to the "Syndey" chapter
    Then I am unable to invite them

  Scenario: Trustee can't invite others
    Given I am logged in as a "Boston" trustee
    When I try to invite a new trustee to the "Boston" chapter
    Then I am unable to invite them
