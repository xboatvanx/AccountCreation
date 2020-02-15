PART 1 - Setting up Google Side

1 - The first step in this process is to create a Google Form for your Human Resources Department to fill out. I include the following fields for my environment: FirstName, LastName, Building, Title, Badge code, and SorF (staff or faculty). I make all of the fields mandatory. This list will vary for different environments.

2 - The form will produce a Google Sheet of results. The first column will always be the timestamp no matter what your variables are. We will deal with that in the Google Scripts that will shape the data for Powershell.

We will get started on the Google Scripting. Open the response Google Sheet tied to your form. Under "tools" go to script editor.

You will need to create two functions in your script: TrashCSV and BlankCheckCSVClear. These functions work together to clean up yesterday's data and shape the Sheet in order to export it to CSV where Powershell will be able to read it. Pleaese see the templates in the repository

3 - You must set triggers for your script to run regularly. I use chron style time based triggers. In your script editor, go to Edit and Current project's triggers.

I run TrashCSV first from 9-10PM nightly. I then run BlankCheckCSVClear from 10-11pm nightly.

4 - The next step is to pull the CSV from Google Drive using Google Drive File stream to map the Google drive of the account the form is on to the Local PC or server running the script.

PART 2

5 - Now here comes the big boy portion of the process: Taking the CSV and morphing the data into AD/Google accounts. Please note your variables and file paths will differ. We tried to note where you will need to customize these.

