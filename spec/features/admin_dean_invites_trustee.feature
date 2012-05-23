Feature: Admins and Deans can invite users to chapters they have access to

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

  Scenario: Lots of invitations to one user
    Given I am logged in as an admin
    When I invite a new trustee to the "Boston" chapter
    Then that person should get an invitation email
    When they accept the invitation
    Then they should get another email welcoming them

    Given I log back in
    And the email backlog has been cleared
    When I invite the same trustee to the "Boston" chapter
    Then that person should get another invitation email
    When they accept the invitation
    Then they should get another email welcoming them
    And the trustee can log in

    Given the email backlog has been cleared
    When the trustee tries to accept the invitation yet again
    Then they should get yet another email welcoming them

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
