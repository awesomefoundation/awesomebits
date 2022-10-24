Feature: A visitor to the site submits an application

  Scenario: A visitor submits an application
    Given I am on the homepage
    When I submit a project to the "Boston" chapter
    Then I should be thanked
    And I should get an email telling me the application went through

  @javascript
  Scenario: A visitor sees character limts on description fields
    Given I am on the submission page
    When I type into the description fields
    Then I should see the amount of characters remaining

  @javascript
  Scenario: A visitor uploads multiple images
    Given I am on the submission page
    When I attach the file "1.JPG" to the submission
    Then I should see 1 attachment recognized
    When I attach the file "2.JPG" to the submission
    Then I should see 2 attachments recognized
    When I fill out the rest of the form
    And I submit the form
    Then the files I attached should have been uploaded

  Scenario: A visitor messes up while submitting an application
    Given I am on the homepage
    When I submit a project to the "Boston" chapter, but it fails
    Then I should see the error
    When I fix the error and resubmit
    Then I should be thanked
    And I should get an email telling me the application went through

  Scenario: A visitor is trying to submit a spam application
    Given I am on the submission page
    When I submit a spam project to the "Boston" chapter
    Then I should see the notice flash
    And the project count should be 0

  Scenario: A visitor submits an application in embed mode
    Given I am on the submission page in embed mode
    Then I should not see a header or footer
    And I should not see the chapter selection dropdown
    When I fill in the application form
    And I submit the form
    Then I should be thanked
    And I should not see a header or footer
