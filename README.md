Salesforce Assignment: Chatter-Public Group Synchronization & Digital Voting System
This project implements two solutions as part of a Salesforce developer assignment. The first solution manages synchronization between Chatter and Public groups. The second is a proof of concept for a digital voting system.

Setup Options
Install from GitHub Repository

Clone the repository:
bash
git clone https://github.com/Michalh43/deloitte.git

Deploy to your Salesforce environment:
bash
sfdx force:source:deploy -p <project_folder_path>

Configure permissions and review the "Party Choice Page."

Run tests to confirm successful setup:
bash
sfdx force:apex:test:run --resultformat human
Access through Developer Environment

Link to my Salesforce developer environment.
https://ourcrowd5-dev-ed.develop.my.salesforce.com/
User: lilavi@deloitte.co.il.deloitte 


Exercise 1: Chatter and Public Group Synchronization
Whenever a member is added to or removed from a Chatter group, this solution synchronizes that change with a public group of the same name.

Implementation Details
Trigger and Apex Class: Listens for member changes in Chatter groups and updates corresponding public groups.
Additions: Adds users to a public group matching the Chatter group name.
Removals: Removes users from the public group if they are removed from the Chatter group.
Group Creation: Automatically creates a public group if none exists for a new Chatter group.
Error Handling: Includes error handling for scenarios where groups or members cannot be updated.
Platform Events (Bonus): Publishes platform events for synchronization, enabling future integration with other systems if needed.


Exercise 2: Digital Voting System (Party Choice Page)
A digital voting interface allows users to select a party or blank vote. The system saves votes to the Salesforce database.

Implementation Details
Objects and Fields

Party: Represents a political party.
Fields: Party Name, Description, Party Code, Leader Name.
Choice: Represents a citizen's vote.
Fields: Party (Lookup to Party), Voter (Lookup to User), Date of Choice.
Apex Classes

Retrieves party options and handles the creation and updating of votes.
Error handling included to ensure only valid choices are saved.
LWC Components

Displays all parties as selectable cards on the "Party Choice Page."
Party Code: Central identifier on each card.
Description: Brief party description below the code.
Blank Vote Option: Users can select a blank vote, including an optional comment.
Save Button: Saves the choice, displaying a success message upon completion.
Testing

Comprehensive Apex tests ensure functionality and data integrity.
Confirm successful tests after setup.