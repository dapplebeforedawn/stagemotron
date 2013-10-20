# The Pipeline

```
  THE FIRST FEATURE BRANCH        |   THE NEXT FEATURE BRANCH
  ------------------------        |   -----------------------
                                  |
  Test/Develop your code locally  |
            |                     |  Test/Develop your code locally
      git rebase master           |            |
            |                     |            |
      cap staging deploy          |            |
            |                     |            |
      Test in staging             |            |
            |                     |            |
    git checkout master           |            |
    git merge my-feature-branch   |            |
            |                     |      git rebase master    # rebase happpens after
    cap production deploy         |            |              # the first branch has been
                                  |      cap staging deploy   # merged into master this is
                                  |            |              # important, so staged code is
                                  |      Test in staging      # equivalent to future production
                                  |            |              # code.
                                  |    git checkout master
                                  |    git merge my-feature-branch
                                  |            |
                                  |    cap production deploy
```
## Notes:
 - "Staging" (aka navinet) is the final check of development code running in production-like environments with the future production codebase (all of the code base).  Nothing less, nothing more.
 - Staging is not to a "demo" environment.  If you need issue-owner sign-off before production, either arrange to have it done immediatly once staged, or get approval of the development code in a development environment.
 - No feature branch should be merged with master until master is in production
 - If your code has been merged with master and can not be deployed, you must `git revert` to allow the next branch to be deployed
 - Reguarding the last-stage-of-the-day(lsotd):  Since we try not to deploy in the late afternoon, this means that the entire pipeline must also stop in the late afternoon.  If you have a "demo", or need to hold the staging environment for a long time, try to be the lsotd.


# Deploymotron
> Deployment pipeline helper

## Talking to Deploymotron
```
  deploymotron, << name-of-feature-branch     # add your (tested) branch to the pipeline
  deploymotron, lsotd name-of-feature-branch  # request lsotd status, will alert if already taken.
  deploymotron, ls                            # list the contents of the pipeline
  deploymotron, ls | head                     # who's next for staging
  deploymotron, rm name-of-feature-branch     # remove a feature from the pipeline
```

## Listening to Deploymotron
  - `The staging environment is ready for name-of-feature-branch`

## last-stage-of-the-day
Deploymotron knows that the regression test suite takes about 90 minutes.  So the first time that staging becomes available after 1:30PM, if there's an lsotd request, it will be notified (instead of the next branch in queue).

## How It Works:
 - Deploymotron compares the SHAs of the master branch with the SHA of the feature branch (known by name-of-feature-branch).  When they match, the next feature owner is notified.
 - If the top feature branch (the result of `ls | head`) is removed (by `rm name-of-feature-branch`) the next feature owner is notified.

## What We're Not Handling Right Now:
It's not enough to just manage the staging/merging part of the pipeline, but the deployment part needs to be managed as well, to ensure feature branches are deployed one at time.  For now this should be managed with human-to-human communication.  In the future, deploymotron can be extended to include the deployment step as well.

## Impementation Note:

Getting a sha:
```
curl -i https://api.github.com/repos/:user/:repo/git/refs/heads/:name-of-feature-branch
```
