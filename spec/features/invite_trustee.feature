Feature: An admin can invite new trustees, and they can accept and become users

  Scenario: Admin invites to any chapter
    Given I am logged in as an admin
    When I invite a new trustee to the "Boston" chapter
    Then that person should get an invitation email
    When they accept the invitation
    Then they should get another email welcoming them
    And the trustee can log in

    Given I log back in
    When I invite a new trustee to the "Sydney" chapter
    Then that person should get an invitation email
    When they accept the invitation
    Then they should get another email welcoming them
    And the trustee can log in

  @dean
  Scenario: Dean can only invite to their chapter
    Given I am logged in as a dean
    When I invite a new trustee to my chapter
    Then that person should get an invitation email
    When they accept the invitation
    Then they should get another email welcoming them
    And the trustee can log in

    Given I log back in
    When I try to invite a new trustee to a chapter I am not dean of
    Then I am unable to invite them to that chapter

  Scenario: Dean will not see the chapter dropdown if they can only invite to one chapter
    Given I am logged in as a dean for only one chapter
    When I visit the invitation screen
    Then I should not see a drop down menu with chapters

  @trustee
  Scenario: Trustee can't invite others
    Given I am logged in as a trustee
    When I have not navigated anywhere yet
    Then I should not see a link to invite other trustees
    When I try to invite a new trustee to my chapter anyway
    Then I am unable to invite them
