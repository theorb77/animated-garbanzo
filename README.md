# Animated Garbanzo

Animated Garbanzo was just the name that Github suggested when I initialized the repo.

## Description

This README will probably get filled out as I work through building out CI/CD in Github Actions.

So far I've discovered the joy of WSL's "externally managed repo" when I want to use pip3. This would normally be fine as I probably want to use pyenv, but in this case I'm crunched for time and don't care either way.

I opted to use DynamoDB for my AWS database; it was simply the easiest choice. Given time I might have evaluated something else. I wrote the call outside of any of the Flask routes to avoid repeatedly pulling a static record. If it were necessary to check it regularly, I'd re-factor but it's not in the requirements.

I chose Flask even though I probably know Django a little better because it's faster and less bulky.

I intend to use the app on Fargate, not because I love Fargate but because I am aiming for relatively low overhead and fast "time to market".

---

I've completed most of the requirements at this point. I switched from gunicorn inside nginx to just gunicorn. I didn't see a need for both.

Autoscaling in ECS was new for me, but I think I got a working autoscaler.

I probably should have spent time setting up a local stack to not do my iterating in GHA, but I guess this makes things more transparent.

I did not set up a full monitoring pipeline, nor did I integrate with something like New Relic owing to a not-really-viable free tier.

These are the following metrics I'd monitor out of cloudwatch:

    ECS:CPUUtilization
    ECS:MemoryUtilization
    ECS:RegisterTaskDefinition
    ECS:DeregisterTaskDefinition
    ApplicationELB:TargetGroup:RequestCountPerTarget
    ApplicationELB:Per AppELB Metrics:TargetResponseTime
    ApplicationELB:Per AppELB Metrics:NewConnectionCount
    ApplicationELB:Per AppELB Metrics:HTTPCode_Target_4XX_Count

The idea is to follow the [Four Golden Signals](https://sre.google/sre-book/monitoring-distributed-systems/#xref_monitoring_golden-signals) per the Google SRE handbook.
