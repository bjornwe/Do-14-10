# Do-14-10
My first AppleWatch app using complications

The aim of this app is to help me adhere to the 14/10 intermittant fasting variant:
When I finish my evening meal at maybe 6pm I click the complication on the watch face,
then I press Now in the app view. Optionally I can add och subtract in 10 minutes steps. 
Also optionally I can rotate the crown to add or subtract hours.
The app helps me to remember when my 14 hours of fasting is over - in this case at 8am.
This time point is, as well as the day of week, shown by the complication.

The challenges for me was to learn Xcode and Swift and also to understand the AppleWatch 
libraries. I am coming from the C# world and I must say that pushing the app to
my Apple Watch 5 via the iPhone was delightfully simple :-)

The data model has only three variables, one of type Date and two strings. These are
persisted in three files (no json) to survive a watch restart.
The thing I never mastered was how to get these variables over from the model instance
to the ComplicationController. My kludge was to copy the values to static variables which 
were accessible from the ComplicationController.
Also a bit hard to grasp was how to use the functions in ComplicationController to
set up a bona fide time line. 

There are several links to good examples I am leaning on in the code.

Feel free to contact me. I have: 73 at wend.se
Björn Wendsjö
