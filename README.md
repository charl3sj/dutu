# Dutu

Dutu is a multi-purpose app being developed for my personal use to keep track of mundane stuff like 
errands and chores. It consists of:
1. Todo app which supports fuzzy date inputs and recurring events to handle scenarios like
   - do Task X... 
     - "between 5th March and 10th March", or
     - "in the _first week of April_" (yet to be implemented), or
     - "every 3 days", or
     - "every week on Tuesday and Friday"
     
2. Diet Tracker to log food consumption and highlight lesser consumed foods by ranking them higher

Note: Features are developed as and when the use-cases arise, depending on my usage. The UI too 
has been designed for my convenience and workflow and not much effort has gone in to make it 
accessible or intuitive to a wider set of users. (See 
[sufficient design](https://www.industriallogic.com/blog/sufficient-design/)). If by chance you 
give this a spin and find it useful enough but would like feature modifications, please feel 
free to fork the repo.

### To set up locally

Step 1: `docker-compose build`

Step 2: `./mix deps.get`

Step 3: `./mix ecto.setup`

Step 4: `docker-compose up -d`

Visit [`localhost:9023`](http://localhost:9023) from your browser


### For production setup

[check out the Phoenix deployment guides](https://hexdocs.pm/phoenix/deployment.html)