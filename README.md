# dos_twitter

# Run tests
```mix test test/* --seed 0 --trace```

# These are the building blocks of this project:

- TwitterClasses.Supervisor: Supervisor
- TwitterClasses.Core: Client/ Twitter User
- TwitterClasses.Tracker: Server. It also keeps track fo number of tweets and is responsible for shutdown of the system
- TwitterClasses.Simulator: Genserver module is responsible for periodic triggering of tweets and retweets

proj4.exs: This is the module which accepts user arguments and can be used to trigger everything.

This accepts following arguments 
- Number of users
- Number of messages

The simualtor periodically triggers tweet sending from the users. A user can follow other twitter users and keep track fo their activity.
When a user sends out a tweet, the followers are notified,
- If the follower is connected, the tweet is delivered live
- If the follower is disconnected, the tweets are stored in a notifications table. When the user comes online they can view these tweets
 A user can query a
- hashtag: All the tweets containing that particular hashtag are delivered
- mention: All the tweets in which the user was mentioned are delivered

Exit condition:
When the specified number of tweets are sent, the tracker sends the terminate message and we stop the supervisor.

We have written tests for the following functionalities:
# Tests
- Add a user 
- Delete a user
- Follow a user
- Query using hashtag, mention
