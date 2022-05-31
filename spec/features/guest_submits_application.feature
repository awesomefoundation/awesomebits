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
    When I attach a file to the submission
    Then I should see the attachment was recognized
    But I should only see one file upload field
    When I attach another file to the submission
    Then I should see the attachment was recognized
    But I should still only see one file upload field
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
