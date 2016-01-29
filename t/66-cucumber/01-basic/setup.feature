Feature: setup.pl database creation and migration functionalities
  In order to create company databases or migrate company databases
  from earlier versions and SQL-Ledger, we want system admins to be
  able to use the setup.pl functionalities involved.



Background:
  Given a database super-user
    And a LedgerSMB instance


Scenario: Creating a company *with* CoA
 Given a non-existent company named 'setup-test'
   And a non-existent user named 'the-user'
  When I navigate to the setup login page
   And I log into the company using the super-user credentials
  Then I should see the company creation page
  When I confirm database creation with these parameters:
      | parameter name    | value       |
      | Country code      | us          |
      | Chart of accounts | General.sql |
      | Templates         | demo        |
  Then I should see the user creation page
  When I create a user with these values:
      | label              | value            |
      | Username           | the-user         |
      | Password           | abcd3fg          |
      | Salutation         | Mr.              |
      | First Name         | A                |
      | Last name          | Dmin             |
      | Employee Number    | 00000001         |
      | Date of Birth      | 09/01/2006       |
      | Tax ID/SSN         | 00000002         |
      | Country            | United States    |
      | Assign Permissions | Full Permissions |
  Then I should see the setup confirmation page


