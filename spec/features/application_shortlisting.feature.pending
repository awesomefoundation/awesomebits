Feature: As a Trustee I can view a list of grant applications and add them to a
  shortlist

  Scenario: Trustee creates application shortlist
    Given I am logged in as a trustee
    When I am looking at the list of applications
    Then I should only see applications for this month in my chapter
    When I shortlist an application
    Then the application indicates that I have shortlisted it
    When I refresh the page
    Then shortlisted applications are still displayed

  Scenario: Trustee sees applications from last month
    Given I am logged in as a trustee
    When I am looking at the list of applications
    And I look at applications from 2 months ago
    Then all applications shown should be from 2 months ago
    When I shortlist an application
    Then the application indicates that I have shortlisted it
