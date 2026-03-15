this app will calculate the islamic tax (zakah)
Splash screen
then home screen:
    - different fields for each carat the user can increment and decrement the amount or enter it manually

State Management:
    - Bloc

Logic:
    - Islamic zakah requires the minimum 85 grams of 24 carat gold
    Why we need this? after calculations if the result is less than 85 grams we inform the user doesn't need to pay zakah
    - How we calculate?
        - we take the amount of gramns in each purity such as 14,18,21,22,24
        we multiply the amount * purity then we divide the number by 24

        example:
             14 purity * 5 grams = 70/24 = 2.9166667 of 24 carat gold.
             18 purity * 10 grams = 180/24 = 7.5 of 24 carat gold.
             etc..
    So we calculate each field the sum them together and if they're less than 85 grams
    Then the user doesn't need to pay zakah
    else:
    if the total exceeds 85 then we divide the result/total of grams by 40
    as the zakah is 2.5%

Notes:
    - Application is only in arabic.
    - create a constants file as this code will be reusable
    there we will place colors used in the app.
    for this app colors will be teal and white.
    save user input to shared preferences to make it easy for him
    allow the user to input the begining of a year as this tax is paid annually and save it to shared prefs too.

Q: How long should the splash screen stay visible before navigating to home?
A: the splash would have the logo centered in it for a 2 seconds
Q: For the annual date, do you want only the Hijri year, only the Gregorian year, or a full date picker?
A: Hijri year only
Q: Should this saved year represent the start of the zakah cycle for all entries, or be linked per calculation session?
A: One global year for all calculations
Q: How many decimal places should results show in the UI?
A: No rounding (full precision)
Q: Should the home screen include exactly 5 purity fields (14, 18, 21, 22, 24) as fixed inputs?
A: Start with 5 and make it configurable for more if needed

Confirmed Requirements

Splash screen shows centered logo for 2 seconds.
App language is Arabic only.
Home screen starts with 5 purity fields: 14, 18, 21, 22, 24.
Each field supports increment, decrement, and manual entry.
Year input is Hijri year only, saved as one global value.
Zakah result should show full precision (no rounding).
Include reset button to clear all saved values.
Shared preferences should persist grams and Hijri year.
Keep architecture extensible for future configurable purities, but do not implement dynamic purities in v1.
Plan Prepared
A full implementation plan has been created and saved to session memory at /memories/session/plan.md, including:

App structure and constants setup.
Splash and home UI flow.
Calculator logic and threshold handling.
Shared preferences persistence and reset behavior.
Verification steps (analyze, test, and manual formula checks).

Edits:
    - find a package to pick hijri date including day
    - make appbar transparent
    - use Cairo font which is in pubspec.yaml
    - use assets/background.png
    - Hijri date picker https://pub.dev/packages/hijri
    change package name to com.superdev.zakahcalc
    and display name to حاسبة زكاة المال