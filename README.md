# History books repository

## What's this repo for?

- This repo serves up data on history books published in the UK, data that I collect and hoard 🙂.

- It stores csv files containing book info, and the instructions to build them into a read only [Datasette](https://datasette.io/) SQLite database, deployed to Vercel.

- It is based heavily on the [Scottish Rail Announcements repo](https://github.com/simonw/scotrail-datasette) and workflow.

- The published Datasette site lives at [https://history-books-blush.vercel.app/](https://history-books-blush.vercel.app/).

- This then becomes the back end for my [history books blog mini database here](https://popularhistorybooks.com/allbooks/). This site is built using eleventy. Here is the [popular history books website source code on github](https://github.com/aewshopping/ssg-deploy-test).

- Previously I just loaded in a whole load of books at build time, then used a bit of javascript to hide and show books based on selected website user filters.

- Now I query the database by constructing SQL queries based on user input built on the front end. Don't worry it is a very small ready only database so I think it should be ok!

## Why did I bother?

- My current 'database' lives on Airtable. However I have run out of rows on the free tier. So if I want to be able to be able to keep adding books I need to either pay Airtable some money or find a different solution.

- Given my history book review / blog website doesn't generate any income, I want to keep the expenditure minimal.

- I'm also nervous that Airtable could change the terms later on, even if I do pay up.

- Finally I just wanted to figure out how to do it!

## Workflow notes

1. I find newly released popular history books by doing an Amazon books search every month and also checking out the big name publishers' catelogues for this genre.

2. After extracting the ISBN 10 (usually from the amazon link url), the data for the books initially comes from the Google Books API - queried by a google apps script.

3. However there are often errors and blanks in the data from this API. I correct these manually by looking up the books on Amazon. This is feasible because there are only about 15 new books per month. I then tag each book with the historical period, type of history, region, country and so on.

4. The data is then stored / inputted into google sheets. Unfortunately I couldn't find a better (cloud based and free) way of doing data entry that didn't severely curtail your amount of data. I'm hopeful that in the future I will improve on this bit, acknowledging that Airtable for manual data input is hard to beat.

5. I've got a bunch of things going on in the google sheet to make data entry easier and build a join table that I need for the tags (I have multiple tags per book).

6. When data is entered, I click a button in google sheets to call a google apps script to trigger a webhook linked to this repo. This triggers the 'Get csv data' github action in this repo.

7. The 'Get csv data' action pulls the data from my google spreadsheet and saves it to the repo.

8. The 'Build and deploy' github action has a trigger than is activated when the 'Get csv data' action is complete. The 'Build and deploy' action installs all the bits and pieces needed for Datasette, uses them to construct and SQLite database and deploys this automatically to Vercel.

9. This database can then be queried directly using the built-in Datasette front end, or used to create API endpoints, which is how my website consumes the data.

## Pain points

### Github actions - pain pt 1

It was tricky getting the github actions to work correctly.

The first thing I got wrong was not being precise in defining the paths used to store and access files, resulting in failed Vercel deploys. Defining the paths explicitly each time I interacted with files solved this.

### Github actions - pain pt 2

The second issue I faced was that I initially set up the 'Build and deploy' action to trigger on `push` (ie changes to files in the repo). However this didn't work when the files were changed by my 'Get csv data' action - ie when triggered by a `repository_dispatch` event.

Turns out that the `repository_dispatch` trigger doesn't result in a `push` that is detectable by another action.

I was pleasantly surprised to discover that the new action _can_ though be triggered by the old one on a `workflow_run` trigger, of `types: completed`. This solved this problem because I will never edit the github stored csv files directly - the google sheets spreadsheet being my source of truth.

### Datasette - pain pt 3

I originally messed around with Datasette on [glitch](https://glitch.com/) so I was fairly happy creating the database from my csv files. However deploying to Vercel was a problem because the official plugin no longer works [datasette-publish-vercel](https://datasette.io/plugins/datasette-publish-vercel). The problem appears to be that it tells Vercel to use an older version of python that Vercel rejects.

To fix this I had to use the plugin options to serve a manually create `vercel.json` file with the line `"use": "@vercel/python@4.3.1"` rather than the `3.0.7` than the plugin specifies. This is why I have this `vercel.json` file in the repo - ordinarily you wouldn't expect to need it as the plugin creates one automatically.

(There is an [Issue created on this plugin bug](https://github.com/simonw/datasette-publish-vercel/issues/67) with another suggested solution of changing the version of node used in the Vercel settings to `18.x`.)

### Note to future self...

__Datasette-publish-vercel and GitHub actions__

Need to include commands to install any additional plugins in the GitHub actions yml file itself, ___as arguments to the Datasette publish Vercel plugin___.

Just listing the plugins (eg Datasette block robots) in the requirements file and pip installing requirements.txt is a necessary step but does not by itself deploy the plugins.

Also noting that Vercel CLI stopped working when the Ubuntu image was updated by GitHub because Vercel CLI was no longer included in the image. So need to install manually as part of the yml file.
